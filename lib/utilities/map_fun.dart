import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:latlong2/latlong.dart';
import 'package:open_location_code/open_location_code.dart';
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
                await provider.slide.open();
              },
              child:
                  Icon(size: 24.sp, Icons.add_location, color: ThemaMain.red)))
    ];
  }
}
