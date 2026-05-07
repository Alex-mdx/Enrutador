import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/widgets/map_widget/map_custer_widget.dart'
    show ClusterMarkerWidget;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import '../../../controllers/contacto_controller.dart';
import '../../../controllers/referencias_controller.dart';
import '../../../utilities/map_fun.dart';

class MapCuster extends StatefulWidget {
  const MapCuster({super.key});

  @override
  State<MapCuster> createState() => MapCusterState();
}

class MapCusterState extends State<MapCuster>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    super.build(context);

    return provider.local == null
        ? Center(
            child: LoadingAnimationWidget.staggeredDotsWave(
                color: ThemaMain.primary, size: 30.sp))
        : FlutterMap(
            mapController: provider.animaMap.mapController,
            options: MapOptions(
                onMapReady: () => provider.mapSeguir = true,
                onPointerDown: (event, point) => provider.mapSeguir = false,
                keepAlive: true,
                onTap: (tapPosition, point) async => await MapFun.touchCuster(
                    provider: provider,
                    lat: double.parse(point.latitude.toStringAsFixed(7)),
                    lng: double.parse(point.longitude.toStringAsFixed(7))),
                initialZoom: 17,
                minZoom: 10,
                maxZoom: 20,
                initialCenter: LatLng(
                    provider.local!.latitude, provider.local!.longitude)),
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
                              'dev.fleaflet.flutter_map.example',
                          tileProvider: NetworkTileProvider())
                      : TileLayer(
                          maxZoom: 20,
                          maxNativeZoom: 19,
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          retinaMode: false,
                          userAgentPackageName: 'com.enrutador.app',
                          tileProvider: NetworkTileProvider()),
                  if (Preferences.grid)
                    TileLayer(
                        tms: true,
                        urlTemplate:
                            'https://grid.plus.codes/grid/tms/{z}/{x}/{y}.png${provider.mapaReal ? "?col=white" : ""}',
                        userAgentPackageName: 'com.enrutador.app',
                        tileProvider: NetworkTileProvider()),
                  if (!provider.descargarZona)
                    if (provider.contacto != null &&
                        !provider.descargarZona &&
                        provider.animaMap.mapController.camera.zoom > 14)
                      FutureBuilder(
                          future: ReferenciasController.getIdR(
                              idRContacto: provider.contacto!.id,
                              lat: provider.contacto!.latitud,
                              lng: provider.contacto!.longitud),
                          builder: (context, snapshot) {
                            final polylines = snapshot.data
                                    ?.map((e) => Polyline(
                                            points: [
                                              LatLng(e.contactoIdLat,
                                                  e.contactoIdLng),
                                              LatLng(
                                                  e.contactoIdRLat ??
                                                      provider
                                                          .contacto!.latitud,
                                                  e.contactoIdRLng ??
                                                      provider
                                                          .contacto!.longitud)
                                            ],
                                            borderColor: Colors.black,
                                            borderStrokeWidth: .3.w,
                                            color: ThemaMain.primary,
                                            strokeCap: StrokeCap.round,
                                            strokeWidth: .8.w,
                                            pattern: StrokePattern.dotted(
                                                spacingFactor: 6.sp)))
                                    .toList() ??
                                [Polyline(points: [])];
                            return (polylines.firstOrNull?.points.isEmpty ??
                                    true)
                                ? SizedBox()
                                : PolylineLayer(polylines: polylines);
                          }),
                  if (provider.contacto != null && !provider.descargarZona)
                    FutureBuilder(
                        future: ReferenciasController.getIdPrin(
                            idContacto: provider.contacto!.id,
                            lat: provider.contacto!.latitud,
                            lng: provider.contacto!.longitud),
                        builder: (context, snapshot) {
                          final polylines = snapshot.data
                                  ?.map((e) => Polyline(
                                          points: [
                                            LatLng(e.contactoIdLat,
                                                e.contactoIdLng),
                                            LatLng(
                                                e.contactoIdRLat ??
                                                    provider.contacto!.latitud,
                                                e.contactoIdRLng ??
                                                    provider.contacto!.longitud)
                                          ],
                                          borderColor: Colors.black,
                                          borderStrokeWidth: .3.w,
                                          color: ThemaMain.green,
                                          strokeWidth: .6.w))
                                  .toList() ??
                              [Polyline(points: [])];
                          return (polylines.firstOrNull?.points.isEmpty ?? true)
                              ? SizedBox()
                              : PolylineLayer(polylines: polylines);
                        }),
                  CurrentLocationLayer(
                      alignDirectionAnimationDuration: Durations.short3,
                      alignPositionAnimationDuration: Durations.extralong2,
                      moveAnimationDuration: Durations.long3,
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
                  if (provider.custerMarker != null)
                    MarkerLayer(
                        alignment: Alignment.center,
                        markers: [provider.custerMarker!]),
                  FutureBuilder(
                      future: ContactoController.getItems(null),
                      builder: (context, snapshot) => MarkerClusterLayerWidget(
                          options: MarkerClusterLayerOptions(
                              maxClusterRadius: 50,
                              disableClusteringAtZoom: 18,
                              spiderfyCircleRadius: 40,
                              spiderfySpiralDistanceMultiplier: 1,
                              size: Size(25.sp, 25.sp),
                              alignment: Alignment.center,
                              animationsOptions: const AnimationsOptions(
                                  zoom: Duration(milliseconds: 900),
                                  fitBound: Duration(milliseconds: 350),
                                  centerMarker: Duration(milliseconds: 300),
                                  spiderfy: Duration(milliseconds: 300)),
                              onClusterTap: (cluster) async =>
                                  provider.animaMap.animatedRotateReset(),
                              markers: !snapshot.hasData
                                  ? []
                                  : snapshot.data!
                                      .map((e) =>
                                          MapFun.marcadoresCuster(provider, e))
                                      .toList(),
                              markerChildBehavior: true,
                              rotate: true,
                              builder: (context, clusterMarkers) =>
                                  ClusterMarkerWidget(
                                      count: clusterMarkers.length),
                              showPolygon: true))),
                  MapCompass.cupertino(
                      padding: EdgeInsets.only(top: 12.h, right: 4.w),
                      hideIfRotatedNorth: false)
                ])
              ]);
  }

  @override
  bool get wantKeepAlive => true;
}
