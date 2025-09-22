import 'package:enrutador/controllers/contacto_controller.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:latlong2/latlong.dart';
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
                initialZoom: 17,
                minZoom: 6,
                maxZoom: 19,
                initialCenter: LatLng(
                    provider.local!.latitude!, provider.local!.longitude!)),
            children: [
                provider.mapaReal
                    ? TileLayer(
                        retinaMode: false,
                        panBuffer: 2,
                        maxZoom: 19,
                        keepBuffer: 3,
                        maxNativeZoom: 19,
                        urlTemplate:
                            'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
                        userAgentPackageName:
                            'dev.fleaflet.flutter_map.example')
                    : TileLayer(
                        panBuffer: 2,
                        maxZoom: 19,
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
