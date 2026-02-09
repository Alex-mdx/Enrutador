import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/controllers/referencias_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
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
                minZoom: 8,
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
                              'dev.fleaflet.flutter_map.example')
                      : TileLayer(
                          maxZoom: 20,
                          maxNativeZoom: 19,
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png?layers=SN',
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
                if (!provider.descargarZona)
                  if (provider.contacto != null && !provider.descargarZona)
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
                                                    provider.contacto!.latitud,
                                                e.contactoIdRLng ??
                                                    provider.contacto!.longitud)
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
                          return (polylines.firstOrNull?.points.isEmpty ?? true)
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
                                          LatLng(
                                              e.contactoIdLat, e.contactoIdLng),
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
                if (!provider.descargarZona)
                  FutureBuilder(
                      future: ContactoController.getItems(),
                      builder: (context, snapshot) => AnimatedMarkerLayer(
                          alignment: Alignment.center,
                          markers: !snapshot.hasData
                              ? []
                              : snapshot.data!
                                  .map((e) => MapFun.marcadores(provider, e))
                                  .toList())),
                if (provider.marker != null)
                  AnimatedMarkerLayer(
                      alignment: Alignment.center, markers: [provider.marker!]),
                AnimatedMarkerLayer(
                    markers: provider.zona
                        .map((e) => AnimatedMarker(
                            point: e,
                            builder: (context, marker) => InkWell(
                                onLongPress: () => Dialogs.showMorph(
                                    title: "Eliminar punto",
                                    description:
                                        "Deseas eliminare este punto de la zona\nSe eliminar los puntos creados luego de este",
                                    loadingTitle: "Eliminando",
                                    onAcceptPressed: (context) async {
                                      var indexed = provider.zona.indexOf(e);
                                      for (var i = indexed;
                                          i < provider.zona.length;
                                          i++) {
                                        provider.zona.removeAt(i);
                                      }
                                    }),
                                onTap: () async {
                                  await provider.animaMap
                                      .centerOnPoint(e, zoom: 18);
                                },
                                child: Container(
                                    width: 6.w,
                                    height: 6.w,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            strokeAlign:
                                                BorderSide.strokeAlignInside,
                                            color: ThemaMain.darkGrey,
                                            width: .5.w),
                                        color: ThemaMain.green,
                                        shape: BoxShape.circle)))))
                        .toList()),
                if (provider.descargarZona && provider.zona.isNotEmpty)
                  PolylineLayer(polylines: [
                    Polyline(
                        points: [
                          ...provider.zona.map((e) => e),
                          if (provider.zona.length == 4) provider.zona.first
                        ],
                        borderColor: Colors.black,
                        borderStrokeWidth: .4.w,
                        color: ThemaMain.green,
                        strokeCap: StrokeCap.butt,
                        strokeWidth: 1.w,
                        pattern: StrokePattern.dotted(spacingFactor: 6.sp))
                  ]),
                MapCompass.cupertino(
                    padding: EdgeInsets.only(top: 12.h, right: 4.w),
                    hideIfRotatedNorth: false)
              ]);
  }

  @override
  bool get wantKeepAlive => true;
}
