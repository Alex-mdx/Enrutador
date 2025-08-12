import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../utilities/uri_fun.dart';

class MapMain extends StatefulWidget {
  const MapMain({super.key});

  @override
  State<MapMain> createState() => _ViajeMapPageState();
}

class _ViajeMapPageState extends State<MapMain>
    with AutomaticKeepAliveClientMixin {
  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    super.build(context);
    return provider.local == null
        ? Center(
            child: Text("No se pudo acceder a su ubicacion",
                style: TextStyle(fontSize: 14.sp)))
        : FlutterMap(
            mapController: provider.animaMap.mapController,
            options: MapOptions(
                keepAlive: true,
                onTap: (tapPosition, point) async => MapFun.touch(
                    provider: provider,
                    lat: point.latitude,
                    lng: point.longitude),
                initialZoom: 17,
                minZoom: 2,
                maxZoom: 21,
                initialCenter: LatLng(
                    provider.local!.latitude!, provider.local!.longitude!)),
            children: [
                TileLayer(
                    maxZoom: 21,
                    keepBuffer: 3,
                    maxNativeZoom: 21,
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    retinaMode: false,
                    panBuffer: 1,
                    userAgentPackageName: 'com.enrutador.app'),
                /* TileLayer(retinaMode: false,
                    panBuffer: 2,
            // URL para las imágenes satelitales de Esri
            urlTemplate:
                'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
            // Es buena práctica incluir un userAgentPackageName
            userAgentPackageName: 'dev.fleaflet.flutter_map.example',
            // Opcional: añade una capa de etiquetas encima para ver los nombres de las calles
          ), */

                FutureBuilder(
                    future: ContactoController.getItems(),
                    builder: (context, snapshot) {
                      return AnimatedMarkerLayer(
                          alignment: Alignment.topCenter,
                          markers: !snapshot.hasData
                              ? []
                              : snapshot.data!
                                  .map((e) => AnimatedMarker(
                                      rotate: true,
                                      point: LatLng(e.latitud, e.longitud),
                                      builder: (context, animation) => InkWell(
                                          onTap: () async {
                                            try {
                                              provider.animaMap.centerOnPoint(
                                                  LatLng(e.latitud, e.longitud),
                                                  zoom: 18);
                                              provider.contacto =
                                                  await ContactoController
                                                      .getItem(
                                                          lat: e.latitud,
                                                          lng: e.longitud);
                                              
                                            } catch (err) {
                                              debugPrint("$err");
                                              var reparacion =
                                                  ContactoModelo.fromJson({
                                                "latitud": e.latitud,
                                                "longitud": e.longitud,
                                                "foto": "null",
                                                "fotoReferencia": "null"
                                              });
                                              await ContactoController.update(reparacion);
                                              provider.contacto =
                                                  await ContactoController
                                                      .getItem(
                                                          lat: e.latitud,
                                                          lng: e.longitud);
                                              showToast("No se pudo obtener sus fotos, intente de nuevo");
                                            }
                                            await provider.slide.open();
                                          },
                                          child: Icon(
                                              size: 24.sp,
                                              Icons.location_history,
                                              color: ThemaMain.primary))))
                                  .toList());
                    }),
                AnimatedMarkerLayer(
                    alignment: Alignment.topCenter,
                    markers: [...provider.marker]),
                CurrentLocationLayer(
                    alignDirectionAnimationDuration: Durations.extralong1,
                    alignPositionAnimationDuration: Durations.extralong3,
                    moveAnimationDuration: Durations.extralong3,
                    style: LocationMarkerStyle(
                        showAccuracyCircle: true,
                        markerSize: Size(20.sp, 20.sp),
                        showHeadingSector: true,
                        accuracyCircleColor: ThemaMain.darkBlue.withAlpha(10),
                        marker: DefaultLocationMarker(
                            color: ThemaMain.darkBlue,
                            child: Icon(
                                size: 17.sp,
                                Icons.navigation,
                                color: Colors.white)),
                        markerDirection: MarkerDirection.heading)),
                MapCompass.cupertino(
                    padding: EdgeInsets.only(top: 6.h, right: 3.w),
                    hideIfRotatedNorth: false)
              ]);
  }

  @override
  bool get wantKeepAlive => true;
}
