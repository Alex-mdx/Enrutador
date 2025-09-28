import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/enrutar_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'dart:math';
import 'package:sizer/sizer.dart';
import 'package:badges/badges.dart' as bd;
import '../models/enrutar_model.dart';
import 'theme/theme_color.dart';

class MapFun {
  static const tierraRadio = 6378;
  static Future<void> getUri(
      {required MainProvider provider, required String uri}) async {
    var newText = uri.replaceAll("q=", "");
    List<String> datas = newText.split(",");

    await sendInitUri(
        provider: provider,
        lat: double.parse(datas[0]),
        lng: double.parse(datas[1]));
  }

  static Future<void> sendInitUri(
      {required MainProvider provider,
      required double lat,
      required double lng}) async {
    provider.mapSeguir = false;
    var dir = await ContactoController.getItem(lat: lat, lng: lng);
    await provider.animaMap.centerOnPoint(
        LatLng(double.parse(lat.toStringAsFixed(6)),
            double.parse(lng.toStringAsFixed(6))),
        zoom: 18);
    if (dir != null) {
      provider.contacto = dir;
      await provider.slide.open();
    } else {
      await touch(provider: provider, lat: lat, lng: lng);
    }
  }

  // Versión optimizada que devuelve solo el índice del punto más cercano
  static ContactoModelo? puntoMasCercano(
      double originLat, double originLon, List<ContactoModelo> points) {
    if (points.isEmpty) showToast('La lista de puntos está vacía');

    ContactoModelo? nearestIndex;
    double minDistance = double.infinity;

    for (int i = 0; i < points.length; i++) {
      final point = points[i];
      double distance = _calculateDistance(
          originLat, originLon, point.latitud, point.longitud);

      if (distance < minDistance) {
        minDistance = distance;
        nearestIndex = point;
      }
    }

    return nearestIndex;
  }

  static double calcularDistancia(
      {required double lat1,
      required double lon1,
      required double lat2,
      required double lon2}) {
    double dLat = _degToRad(lat2 - lat1);
    double dLon = _degToRad(lon2 - lon1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degToRad(lat1)) *
            cos(_degToRad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return tierraRadio * c;
  }

  static double _degToRad(double deg) {
    return deg * (pi / 180);
  }

  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Implementar Haversine o euclidiana según necesites

    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return tierraRadio * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static Future<void> ordenamiento(MainProvider provider) async {
    try {
      var enrutar = await EnrutarController.getItems();
      var temp = enrutar.map((e) => e).toList();
      List<EnrutarModelo> enrutarList = [];
      EnrutarModelo? ruta;
      for (var i = 0; i < enrutar.length; i++) {
        if (i == 0) {
          var temp1 = MapFun.puntoMasCercano(
              provider.local?.latitude ?? 0,
              provider.local?.longitude ?? 0,
              enrutar.map((e) => e.buscar).toList());
          ruta = enrutar.firstWhereOrNull((element) =>
              (element.buscar.latitud == temp1?.latitud) &&
              (element.buscar.longitud == temp1?.longitud));
        } else {
          var temp1 = MapFun.puntoMasCercano(ruta?.buscar.latitud ?? 0,
              ruta?.buscar.longitud ?? 0, temp.map((e) => e.buscar).toList());
          ruta = enrutar.firstWhereOrNull((element) =>
              (element.buscar.latitud == temp1?.latitud) &&
              (element.buscar.longitud == temp1?.longitud));
        }
        if (ruta != null) {
          enrutarList.add(ruta);
        }
        temp.removeWhere((element) => element.id == ruta?.id);
        debugPrint("${temp.map((e) => e.buscar.nombreCompleto).toList()}");
      }

      debugPrint("${enrutarList.map((e) => e.buscar.nombreCompleto).toList()}");
      for (var i = 0; i < enrutarList.length; i++) {
        var enrutadorNew = enrutarList[i].copyWith(orden: i + 1);
        await EnrutarController.update(enrutadorNew);
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  static Future<void> touch(
      {required MainProvider provider,
      required double lat,
      required double lng}) async {
    var pc = Textos.psCODE(double.parse(lat.toStringAsFixed(6)),
        double.parse(lng.toStringAsFixed(6)));
    var newlocation = PlusCode(pc).decode().southWest;
    provider.contacto = ContactoModelo(
        id: null,
        nombreCompleto: null,
        latitud: newlocation.latitude,
        longitud: newlocation.longitude,
        domicilio: null,
        fechaDomicilio: null,
        numero: null,
        numeroFecha: null,
        otroNumero: null,
        otroNumeroFecha: null,
        agendar: null,
        contactoEnlances: [],
        tipo: null,
        tipoFecha: null,
        estado: null,
        estadoFecha: null,
        foto: null,
        fotoFecha: null,
        fotoReferencia: null,
        fotoReferenciaFecha: null,
        what3Words: null,
        nota: null);
    provider.marker = [
      AnimatedMarker(
          rotate: true,
          point: LatLng(newlocation.latitude, newlocation.longitude),
          builder: (context, animation) => InkWell(
              onTap: () async {
                provider.animaMap.centerOnPoint(
                    LatLng(double.parse(lat.toStringAsFixed(6)),
                        double.parse(lng.toStringAsFixed(6))),
                    zoom: 18);
                provider.contacto = ContactoModelo(
                    id: null,
                    nombreCompleto: null,
                    latitud: newlocation.latitude,
                    longitud: newlocation.longitude,
                    domicilio: null,
                    fechaDomicilio: null,
                    numero: null,
                    numeroFecha: null,
                    otroNumero: null,
                    otroNumeroFecha: null,
                    agendar: null,
                    contactoEnlances: [],
                    tipo: null,
                    tipoFecha: null,
                    estado: null,
                    estadoFecha: null,
                    foto: null,
                    fotoFecha: null,
                    fotoReferencia: null,
                    fotoReferenciaFecha: null,
                    what3Words: null,
                    nota: null);
                await provider.slide.open();
              },
              child: Stack(alignment: Alignment.center, children: [
                Image.asset("assets/mark_point2.png",
                    width: 28.sp, height: 28.sp),
                Padding(
                    padding: EdgeInsets.only(bottom: 6.sp),
                    child: Icon(
                        size: 21.sp, Icons.add_circle, color: ThemaMain.red))
              ])))
    ];
  }

  static AnimatedMarker marcadores(MainProvider provider, ContactoModelo e) {
    var tocable = (provider.contacto?.latitud == e.latitud &&
        provider.contacto?.longitud == e.longitud);
    return AnimatedMarker(
        width: tocable ? 24.sp : 22.sp,
        height: tocable ? 24.sp : 22.sp,
        rotate: true,
        point: LatLng(e.latitud, e.longitud),
        builder: (context, animation) => InkWell(
            onLongPress: () async => Dialogs.showMorph(
                title: "Eliminar",
                description:
                    "¿Esta seguro de eliminar este punteo?\nSe no habra manera de recuperar este dato",
                loadingTitle: "Eliminando",
                onAcceptPressed: (context) async {
                  await ContactoController.deleteItemByltlng(
                      lat: e.latitud, lng: e.longitud);
                  provider.contacto = null;
                }),
            onTap: () async {
              try {
                provider.animaMap
                    .centerOnPoint(LatLng(e.latitud, e.longitud), zoom: 18);
                provider.contacto = await ContactoController.getItem(
                    lat: e.latitud, lng: e.longitud);
              } catch (err) {
                debugPrint("$err");
                showToast("No se pudo obtener sus fotos, intente de nuevo");
              }
              await provider.slide.open();
            },
            child: bd.Badge(
                badgeStyle: bd.BadgeStyle(badgeColor: Colors.transparent),
                showBadge: true,
                badgeContent: OverflowBar(children: [
                  /* FutureBuilder(
                        future: EnrutarController.getItemContacto(
                            contactoId: e.id ?? -1),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return Icon(LineIcons.route, size: 18.sp);
                          } else {
                            return SizedBox();
                          }
                        }) */
                ]),
                child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Image.asset(tocable
                          ? "assets/mark_point2.png"
                          : "assets/mark_point.png"),
                      Padding(
                          padding: EdgeInsets.only(bottom: tocable ? 6.sp : 0),
                          child: Icon(
                              provider.tipos
                                      .firstWhereOrNull(
                                          (element) => element.id == e.tipo)
                                      ?.icon ??
                                  Icons.person,
                              size: tocable ? 22.sp : 20.sp,
                              color: provider.tipos
                                      .firstWhereOrNull(
                                          (element) => element.id == e.tipo)
                                      ?.color ??
                                  ThemaMain.primary))
                    ]))));
  }
}
