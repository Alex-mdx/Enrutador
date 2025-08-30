import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';
import 'dart:math';
import 'package:sizer/sizer.dart';

import 'theme/theme_color.dart';

class MapFun {
  static getUri({required MainProvider provider, required String uri}) async {
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

  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    // Implementar Haversine o euclidiana según necesites
    const earthRadius = 6378;
    double dLat = (lat2 - lat1) * pi / 180;
    double dLon = (lon2 - lon1) * pi / 180;

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);

    return earthRadius * 2 * atan2(sqrt(a), sqrt(1 - a));
  }

  static Future<void> touch(
      {required MainProvider provider,
      required double lat,
      required double lng}) async {
    provider.contacto = ContactoModelo(
        id: null,
        nombreCompleto: null,
        latitud: double.parse(lat.toStringAsFixed(6)),
        longitud: double.parse(lng.toStringAsFixed(6)),
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
          point: LatLng(double.parse(lat.toStringAsFixed(6)),
              double.parse(lng.toStringAsFixed(6))),
          builder: (context, animation) => InkWell(
              onTap: () async {
                provider.animaMap.centerOnPoint(
                    LatLng(double.parse(lat.toStringAsFixed(6)),
                        double.parse(lng.toStringAsFixed(6))),
                    zoom: 18);
                provider.contacto = ContactoModelo(
                    id: null,
                    nombreCompleto: null,
                    latitud: double.parse(lat.toStringAsFixed(6)),
                    longitud: double.parse(lng.toStringAsFixed(6)),
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
}
