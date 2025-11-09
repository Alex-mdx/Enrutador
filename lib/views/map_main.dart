import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

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
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: ThemaMain.primary, size: 24.sp))
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
                initialZoom: 17,
                minZoom: 10,
                maxZoom: 20,
                initialCenter: LatLng(
                    provider.local!.latitude!, provider.local!.longitude!)),
            children: [
                Stack(children: [
                  provider.mapaReal
                      ? TileLayer(
                          maxZoom: 20,
                          maxNativeZoom: 18,
                          retinaMode: false,
                          urlTemplate:
                              'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                          userAgentPackageName:
                              'dev.fleaflet.flutter_map.example')
                      : TileLayer(
                          maxZoom: 20,
                          maxNativeZoom: 19,
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          retinaMode: false,
                          userAgentPackageName: 'com.enrutador.app'),
                  if (Preferences.grid)
                    TileLayer(
                        tms: true,
                        urlTemplate:
                            'https://grid.plus.codes/grid/tms/{z}/{x}/{y}.png${provider.mapaReal ? "?col=white" : ""}',
                        userAgentPackageName: 'com.enrutador.app')
                ]),
                CurrentLocationLayer(
                    alignDirectionAnimationDuration: Durations.short3,
                    alignPositionAnimationDuration: Durations.short3,
                    moveAnimationDuration: Durations.short3,
                    style: LocationMarkerStyle(
                        showAccuracyCircle: true,
                        markerSize: Size(19.sp, 19.sp),
                        showHeadingSector: true,
                        accuracyCircleColor: ThemaMain.darkBlue.withAlpha(10),
                        marker: DefaultLocationMarker(
                            color: ThemaMain.darkBlue,
                            child: Icon(
                                size: 15.sp,
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
                            : snapshot.data!
                                .map((e) => MapFun.marcadores(provider, e))
                                .toList())),
                AnimatedMarkerLayer(
                    alignment: Alignment.center, markers: [...provider.marker]),
                MapCompass.cupertino(
                    padding: EdgeInsets.only(top: 12.h, right: 4.w),
                    hideIfRotatedNorth: false)
              ]);
  }

  @override
  bool get wantKeepAlive => true;
}
