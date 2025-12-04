import 'package:badges/badges.dart' as bd;
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/preferences.dart';
import '../../dialogs/dialog_mapas.dart';

class LauchMainIcon extends StatelessWidget {
  final String? words;
  final LatLng coordenadas;
  const LauchMainIcon({super.key, this.words, required this.coordenadas});

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
        iconSize: 22.sp,
        style: ButtonStyle(
            backgroundColor: WidgetStatePropertyAll(ThemaMain.green)),
        color: ThemaMain.green,
        onPressed: () async {
          final availableMaps = await MapLauncher.installedMaps;
          if (Preferences.mapa != "") {
            await availableMaps
                .firstWhere(
                    (element) => element.mapType.name == Preferences.mapa)
                .showMarker(
                    zoom: 16,
                    coords: Coords(coordenadas.latitude, coordenadas.longitude),
                    title: words ?? "Ubicacion Seleccionada");
          } else {
            showDialog(
                context: context,
                builder: (context) => DialogMapas(
                    words: words ?? "Ubicacion Seleccionada",
                    coordenadas: coordenadas));
          }
        },
        icon: Stack(alignment: Alignment.center, children: [
          bd.Badge(
              showBadge: Preferences.tipoNav != -1,
              badgeStyle: bd.BadgeStyle(badgeColor: ThemaMain.black),
              position: bd.BadgePosition.topStart(top: -10, start: -14),
              badgeContent: Icon(
                  Preferences.tipoNav == 0
                      ? LineIcons.car
                      : Preferences.tipoNav == 1
                          ? LineIcons.walking
                          : Preferences.tipoNav == 2
                              ? LineIcons.busAlt
                              : Preferences.tipoNav == 3
                                  ? LineIcons.bicycle
                                  : LineIcons.car,
                  color: ThemaMain.white,
                  size: 15.sp),
              child: Icon(
                  Preferences.mapa.contains("google")
                      ? LineIcons.mapMarker
                      : Preferences.mapa.contains("waze")
                          ? LineIcons.waze
                          : Preferences.mapa.contains("uber")
                              ? LineIcons.uber
                              : Preferences.mapa.contains("didi")
                                  ? LineIcons.taxi
                                  : Icons.launch_rounded,
                  color: ThemaMain.white))
        ]));
  }
}
