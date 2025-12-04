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
  bool followFix = false;
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return AnimatedPadding(
        padding: EdgeInsets.only(
            right: 2.w,
            bottom: provider.selectRefencia != null
                ? 6.h
                : provider.cargaDatos
                    ? 4.h
                    : 2.h),
        duration: Duration(seconds: 1),
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
              iconSize: 26.sp,
              onPressed: () async {
                if (provider.mapSeguir) {
                  setState(() {
                    followFix = true;
                  });

                  if (followFix) {
                    await provider.animaMap.centerOnPoint(
                        LatLng(provider.local!.latitude!,
                            provider.local!.longitude!),
                        zoom: 18);
                  }
                } else {
                  followFix = false;
                  provider.mapSeguir = true;
                  provider.animaMap.animatedRotateReset();
                  await provider.animaMap.centerOnPoint(LatLng(
                      provider.local!.latitude!, provider.local!.longitude!));
                }
              },
              icon: Icon(
                  provider.mapSeguir
                      ? followFix
                          ? Icons.my_location
                          : Icons.location_searching
                      : Icons.location_disabled,
                  color: ThemaMain.white))
        ]));
  }
}
