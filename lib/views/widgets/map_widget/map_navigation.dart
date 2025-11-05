import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MapNavigation extends StatefulWidget {
  const MapNavigation({super.key});

  @override
  State<MapNavigation> createState() => _MapNavigationState();
}

class _MapNavigationState extends State<MapNavigation> {
  bool container = false;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Padding(
        padding: EdgeInsets.only(right: 1.w, bottom: 4.h),
        child: Column(spacing: .5.h, mainAxisSize: MainAxisSize.min, children: [
          if (provider.contacto != null)
            IconButton.filled(
                iconSize: 24.sp,
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(ThemaMain.primary)),
                onPressed: () async {
                  provider.mapSeguir = false;
                  container = !container;
                  if (container) {
                    CameraFit camara = CameraFit.bounds(
                        maxZoom: 19,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20.w, vertical: 10.h),
                        bounds: LatLngBounds(
                            LatLng(provider.local?.latitude ?? -1,
                                provider.local?.longitude ?? -1),
                            LatLng(provider.contacto!.latitud,
                                provider.contacto!.longitud)));
                    await provider.animaMap
                        .animatedFitCamera(cameraFit: camara);
                  } else {
                    await provider.animaMap.centerOnPoint(
                        LatLng(provider.contacto!.latitud,
                            provider.contacto!.longitud),
                        zoom: 18);
                  }
                },
                icon: Icon(
                    container
                        ? Icons.border_outer_rounded
                        : Icons.border_inner_rounded,
                    color: ThemaMain.white)),
          IconButton.filled(
              iconSize: 24.sp,
              onPressed: () async => await provider.animaMap.animatedZoomIn(
                  duration: Durations.medium3, cancelPreviousAnimations: true),
              icon: Icon(Icons.zoom_in, color: ThemaMain.white)),
          IconButton.filled(
              iconSize: 24.sp,
              onPressed: () async => await provider.animaMap.animatedZoomOut(
                  duration: Durations.medium3, cancelPreviousAnimations: true),
              icon: Icon(Icons.zoom_out, color: ThemaMain.white)),
          IconButton.filled(
              iconSize: 24.sp,
              onPressed: () async {
                provider.mapSeguir = !provider.mapSeguir;
                if (provider.mapSeguir) {
                  provider.animaMap.animatedRotateReset();
                  await provider.animaMap.centerOnPoint(
                      LatLng(provider.local!.latitude!,
                          provider.local!.longitude!),
                      zoom: 18);
                }
              },
              icon: Icon(
                  provider.mapSeguir
                      ? Icons.my_location_outlined
                      : Icons.location_searching,
                  color: ThemaMain.white))
        ]));
  }
}
