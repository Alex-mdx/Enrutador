import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/preferences.dart';
import '../../../utilities/theme/theme_color.dart';

class LaunchMapIcon extends StatefulWidget {
  final AvailableMap mapas;
  final double latitud;
  final double longitud;
  final Function(void)? launch;
  final String word;
  const LaunchMapIcon(
      {super.key,
      required this.mapas,
      required this.latitud,
      required this.longitud,
      required this.launch,
      required this.word});

  @override
  State<LaunchMapIcon> createState() => _LaunchMapIconState();
}

class _LaunchMapIconState extends State<LaunchMapIcon> {
  @override
  Widget build(BuildContext context) {
    final bool installed = widget.mapas.isInstalled;

    return IconButton.filledTonal(
        iconSize: 24.sp,
        onPressed: installed
            ? () async {
                final coords = Location.coords(widget.latitud, widget.longitud,
                    title: widget.word);
                if (Preferences.tipoNav == -1) {
                  await MapLauncher.marker(
                    coords,
                    zoom: 15,
                  ).show(map: widget.mapas.map);
                } else {
                  final modes = TravelMode.values;
                  final mode = (Preferences.tipoNav >= 0 &&
                          Preferences.tipoNav < modes.length)
                      ? modes[Preferences.tipoNav]
                      : TravelMode.driving;

                  await MapLauncher.directions(
                    coords,
                    mode: mode,
                  ).show(map: widget.mapas.map);
                }
                if (widget.launch != null) {
                  await widget.launch!(null);
                }
              }
            : null,
        icon: Icon(
            Preferences.tipoNav == 0
                ? LineIcons.car
                : Preferences.tipoNav == 1
                    ? LineIcons.walking
                    : Preferences.tipoNav == 2
                        ? LineIcons.busAlt
                        : Preferences.tipoNav == 3
                            ? LineIcons.bicycle
                            : Icons.launch,
            color: ThemaMain.primary));
  }
}
