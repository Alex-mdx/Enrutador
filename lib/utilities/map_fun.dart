import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/enrutar_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_math/flutter_geo_math.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:sizer/sizer.dart';
import 'package:badges/badges.dart' as bd;
import '../models/enrutar_model.dart';
import 'pluscode_fun.dart';
import 'theme/theme_color.dart';

class MapFun {
  static Future<void> getUri(
      {required MainProvider provider, required String uri}) async {
    var newindex = uri.indexOf("?q=");
    var newText = uri.replaceRange(0, newindex + 3, "");
    List<String> datas = newText.split(",");
    var pc = PlusCodeFun.psCODE(double.parse(datas[0]), double.parse(datas[1]));
    var newlocation = PlusCode(pc).decode().southWest;
    await sendInitUri(
        provider: provider,
        lat: double.parse(newlocation.latitude.toStringAsFixed(6)),
        lng: double.parse(newlocation.longitude.toStringAsFixed(6)));
  }

  static Future<void> sendInitUri(
      {required MainProvider provider,
      required double lat,
      required double lng}) async {
    provider.mapSeguir = false;

    debugPrint("$lat - $lng");
    var dir = await ContactoController.getItem(lat: lat, lng: lng);
    await provider.animaMap.centerOnPoint(LatLng(lat, lng), zoom: 18);
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
      double distance = calcularDistancia(
          lat1: originLat,
          lon1: originLon,
          lat2: point.latitud,
          lon2: point.longitud);

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
    return (FlutterMapMath.distanceBetween(lat1, lon1, lat2, lon2, '') == 0
        ? 0
        : FlutterMapMath.distanceBetween(lat1, lon1, lat2, lon2, '') / 10);
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
    var pc = PlusCodeFun.psCODE(double.parse(lat.toStringAsFixed(6)),
        double.parse(lng.toStringAsFixed(6)));
    var newlocation = PlusCodeFun.truncPlusCode(pc);
    provider.contacto = ContactoModelo(
        id: null,
        nombreCompleto: null,
        latitud: double.parse(newlocation.latitude.toStringAsFixed(6)),
        longitud: double.parse(newlocation.longitude.toStringAsFixed(6)),
        domicilio: null,
        fechaDomicilio: null,
        numero: null,
        numeroFecha: null,
        otroNumero: null,
        otroNumeroFecha: null,
        agendar: null,
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
    provider.marker = AnimatedMarker(
        width: 21.sp,
        height: 21.sp,
        rotate: true,
        point: LatLng(double.parse(newlocation.latitude.toStringAsFixed(6)),
            double.parse(newlocation.longitude.toStringAsFixed(6))),
        builder: (context, animation) => InkWell(
            onTap: () async {
              provider.animaMap.centerOnPoint(
                  LatLng(double.parse(newlocation.latitude.toStringAsFixed(6)),
                      double.parse(newlocation.longitude.toStringAsFixed(6))),
                  zoom: 18);
              if (!provider.descargarZona) {
                provider.contacto = ContactoModelo(
                    id: null,
                    nombreCompleto: null,
                    latitud:
                        double.parse(newlocation.latitude.toStringAsFixed(6)),
                    longitud:
                        double.parse(newlocation.longitude.toStringAsFixed(6)),
                    pendiente: 1,
                    status: 1,
                    domicilio: null,
                    fechaDomicilio: null,
                    numero: null,
                    numeroFecha: null,
                    otroNumero: null,
                    otroNumeroFecha: null,
                    agendar: null,
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
              }
            },
            child: Stack(alignment: Alignment.center, children: [
              Image.asset("assets/mark_point2.png"),
              Padding(
                  padding: EdgeInsets.only(bottom: 5.sp),
                  child: Icon(
                      size: 20.sp,
                      Icons.add_circle,
                      color: provider.descargarZona
                          ? ThemaMain.green
                          : ThemaMain.red))
            ])));
  }

  static AnimatedMarker marcadores(MainProvider provider, ContactoModelo e) {
    var tocable = (provider.contacto?.latitud == e.latitud &&
        provider.contacto?.longitud == e.longitud);
    return AnimatedMarker(
        width: tocable ? 23.sp : 18.sp,
        height: tocable ? 23.sp : 18.sp,
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
                badgeStyle: bd.BadgeStyle(
                    badgeColor: Colors.black, shape: bd.BadgeShape.twitter),
                showBadge: e.estado != null && (e.estado ?? -1) != -1,
                badgeAnimation: bd.BadgeAnimation.fade(),
                badgeContent: Icon(Icons.circle,
                    color: provider.estados
                        .firstWhereOrNull((element) => element.id == e.estado)
                        ?.color,
                    size: tocable ? 14.sp : 10.sp),
                child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Image.asset(tocable
                          ? "assets/mark_point2.png"
                          : "assets/mark_point.png"),
                      Padding(
                          padding: EdgeInsets.only(bottom: tocable ? 5.sp : 0),
                          child: Icon(
                              provider.tipos
                                      .firstWhereOrNull(
                                          (element) => element.id == e.tipo)
                                      ?.icon ??
                                  Icons.person,
                              size: tocable ? 21.sp : 17.sp,
                              color: provider.tipos
                                      .firstWhereOrNull(
                                          (element) => element.id == e.tipo)
                                      ?.color ??
                                  ThemaMain.primary))
                    ]))));
  }
}
