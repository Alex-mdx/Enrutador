import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

class MapNavigation extends StatefulWidget {
  const MapNavigation({super.key});

  @override
  State<MapNavigation> createState() => _MapNavigationState();
}

class _MapNavigationState extends State<MapNavigation> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Padding(
        padding: EdgeInsets.only(right: 2.w, bottom: 4.h),
        child: Column(spacing: .5.h, mainAxisSize: MainAxisSize.min, children: [
          if (provider.contacto != null)
            IconButton.filled(
                iconSize: 24.sp,
                style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll(ThemaMain.green)),
                color: ThemaMain.green,
                onPressed: () async {
                  final availableMaps = await MapLauncher.installedMaps;
                  print(availableMaps);
                  await availableMaps.first.showMarker(
                      zoom: 15,
                      coords: Coords(provider.contacto!.latitud,
                          provider.contacto!.longitud),
                      title: "Ubicacion Seleccionada");
                },
                icon: Icon(LineIcons.directions, color: ThemaMain.white)),
          IconButton.filled(
              iconSize: 23.sp,
              onPressed: () async => await provider.animaMap.animatedZoomIn(),
              icon: Icon(Icons.zoom_in, color: ThemaMain.white)),
          IconButton.filled(
              iconSize: 23.sp,
              onPressed: () async => await provider.animaMap.animatedZoomOut(),
              icon: Icon(Icons.zoom_out, color: ThemaMain.white)),
          IconButton.filled(
              iconSize: 23.sp,
              onPressed: () async {
                provider.animaMap.animatedRotateReset();
                await provider.animaMap.centerOnPoint(
                    LatLng(
                        provider.local!.latitude!, provider.local!.longitude!),
                    zoom: 18);
              },
              icon: Icon(Icons.my_location_outlined, color: ThemaMain.white))
        ]));
  }
}
