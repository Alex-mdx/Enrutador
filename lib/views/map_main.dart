import 'package:avatar_glow/avatar_glow.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/utilities/w3w_fun.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_map_compass/flutter_map_compass.dart';
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
                onTap: (tapPosition, point) async {
                  await W3wFun.coorTo3(point.latitude, point.longitude);
                  provider.contacto = ContactoModel(
                      id: 1,
                      nombreCompleto: null,
                      latitud: point.latitude,
                      longitud: point.longitude,agendar: null,
                      contactoEnlances: [],
                      domicilio: null,
                      numero: null,
                      tipo: null,
                      estado: null,
                      foto: null,
                      fotoReferencia: null,
                      what3Words: null,
                      nota: null);
                  provider.marker = [
                    AnimatedMarker(
                        rotate: true,
                        point: point,
                        builder: (context, animation) => InkWell(
                            onTap: () async {
                              provider.animaMap.centerOnPoint(point, zoom: 18);
                              await provider.slide.open();
                            },
                            child: Icon(
                                size: 24.sp,
                                Icons.location_history,
                                color: ThemaMain.primary)))
                  ];
                },
                initialZoom: 17,
                minZoom: 3,
                maxZoom: 19,
                initialCenter: LatLng(
                    provider.local!.latitude!, provider.local!.longitude!)),
            children: [
                TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.enrutador.app'),
                /* MapCompass(
                    icon: Icon(Icons.arrow_upward), hideIfRotatedNorth: true), */

                AnimatedMarkerLayer(alignment: Alignment.topCenter, markers: [
                  AnimatedMarker(
                      point: LatLng(provider.local!.latitude!,
                          provider.local!.longitude!),
                      builder: (_, animation) => AvatarGlow(
                          glowCount: 2,
                          glowRadiusFactor: 2.sp,
                          startDelay: const Duration(seconds: 4),
                          glowColor: ThemaMain.primary,
                          duration: Duration(seconds: 4),
                          glowShape: BoxShape.circle,
                          animate: true,
                          curve: Curves.easeOut,
                          child: InkWell(
                              onTap: () async {
                                await provider.slide.open();
                              },
                              child: Icon(
                                  size: 22.sp,
                                  Icons.my_location_rounded,
                                  color: ThemaMain.primary)))),
                  ...provider.marker
                ]),
                MapCompass.cupertino(
                    padding: EdgeInsets.all(12.sp), hideIfRotatedNorth: false)
              ]);
  }

  @override
  bool get wantKeepAlive => true;
}
