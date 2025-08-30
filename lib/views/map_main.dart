import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

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
                onMapReady: () => provider.mapSeguir = true,
                onPointerDown: (event, point) => provider.mapSeguir = false,
                keepAlive: true,
                onTap: (tapPosition, point) async => await MapFun.touch(
                    provider: provider,
                    lat: point.latitude,
                    lng: point.longitude),
                initialZoom: 18,
                minZoom: 6,
                maxZoom: 20,
                initialCenter: LatLng(
                    provider.local!.latitude!, provider.local!.longitude!)),
            children: [
                provider.mapaReal
                    ? TileLayer(
                        retinaMode: false,
                        panBuffer: 2,
                        maxZoom: 20,
                        keepBuffer: 3,
                        maxNativeZoom: 19,
                        urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName:
                            'dev.fleaflet.flutter_map.example')
                    : TileLayer(
                        panBuffer: 2,
                        maxZoom: 20,
                        keepBuffer: 3,
                        maxNativeZoom: 19,
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        retinaMode: false,
                        userAgentPackageName: 'com.enrutador.app'),
                CurrentLocationLayer(
                    alignDirectionAnimationDuration: Durations.medium1,
                    alignPositionAnimationDuration: Durations.medium1,
                    moveAnimationDuration: Durations.short3,
                    style: LocationMarkerStyle(
                        showAccuracyCircle: true,
                        markerSize: Size(20.sp, 20.sp),
                        showHeadingSector: true,
                        accuracyCircleColor: ThemaMain.darkBlue.withAlpha(10),
                        marker: DefaultLocationMarker(
                            color: ThemaMain.darkBlue,
                            child: Icon(
                                size: 16.sp,
                                Icons.circle,
                                color: Colors.white)),
                        markerDirection: MarkerDirection.heading)),
                if (provider.contacto != null &&
                    provider.contacto!.contactoEnlances.isNotEmpty)
                  PolylineLayer(
                      polylines: provider.contacto!.contactoEnlances
                          .map((e) => Polyline(
                                  points: [
                                    LatLng(provider.contacto!.latitud,
                                        provider.contacto!.longitud),
                                    LatLng(
                                        e.contactoIdRLat ??
                                            provider.contacto!.latitud,
                                        e.contactoIdRLng ??
                                            provider.contacto!.longitud)
                                  ],
                                  borderColor: Colors.black,
                                  borderStrokeWidth: 5.sp,
                                  color: ThemaMain.green,
                                  strokeCap: StrokeCap.round,
                                  strokeWidth: 1.w,
                                  pattern: StrokePattern.dotted(
                                      spacingFactor: 6.sp)))
                          .toList()),
                FutureBuilder(
                    future: ContactoController.getItems(),
                    builder: (context, snapshot) => AnimatedMarkerLayer(
                        alignment: Alignment.center,
                        markers: !snapshot.hasData
                            ? []
                            : snapshot.data!.map((e) {
                                var tocable = (provider.contacto?.latitud ==
                                        e.latitud &&
                                    provider.contacto?.longitud == e.longitud);
                                return AnimatedMarker(
                                    width: tocable ? 24.sp : 22.sp,
                                    height: tocable ? 24.sp : 22.sp,
                                    rotate: true,
                                    point: LatLng(e.latitud, e.longitud),
                                    builder: (context, animation) => InkWell(
                                        onLongPress: () async {
                                          await ContactoController
                                              .deleteItemByltlng(
                                                  lat: e.latitud,
                                                  lng: e.longitud);
                                          provider.contacto = null;
                                        },
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
                                              "foto_referencia": "null"
                                            });
                                            await ContactoController.update(
                                                reparacion);
                                            provider.contacto =
                                                await ContactoController
                                                    .getItem(
                                                        lat: e.latitud,
                                                        lng: e.longitud);
                                            showToast(
                                                "No se pudo obtener sus fotos, intente de nuevo");
                                          }
                                          await provider.slide.open();
                                        },
                                        child: Stack(
                                            fit: StackFit.expand,
                                            alignment: Alignment.center,
                                            children: [
                                              Image.asset(tocable
                                                  ? "assets/mark_point2.png"
                                                  : "assets/mark_point.png"),
                                              Padding(
                                                  padding: EdgeInsets.only(
                                                      bottom:
                                                          tocable ? 6.sp : 0),
                                                  child: Icon(
                                                      provider.tipos
                                                              .firstWhereOrNull(
                                                                  (element) =>
                                                                      element
                                                                          .id ==
                                                                      e.tipo)
                                                              ?.icon ??
                                                          Icons.person,
                                                      size: tocable
                                                          ? 22.sp
                                                          : 20.sp,
                                                      color: provider.tipos
                                                              .firstWhereOrNull(
                                                                  (element) =>
                                                                      element
                                                                          .id ==
                                                                      e.tipo)
                                                              ?.color ??
                                                          ThemaMain.primary))
                                            ])));
                              }).toList())),
                AnimatedMarkerLayer(
                    alignment: Alignment.center, markers: [...provider.marker]),
                MapCompass.cupertino(
                    padding: EdgeInsets.only(top: 7.h, right: 4.w),
                    hideIfRotatedNorth: false)
              ]);
  }

  @override
  bool get wantKeepAlive => true;
}
