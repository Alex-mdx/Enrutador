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
    return IconButton.filledTonal(
        iconSize: 24.sp,
        onPressed: () async => {
              Preferences.tipoNav == -1
                  ? await widget.mapas
                      .showMarker(
                          zoom: 15,
                          coords: Coords(widget.latitud, widget.longitud),
                          title: widget.word)
                      .whenComplete(() async => widget.launch != null? await widget.launch!(null) : null)
                  : await widget.mapas
                      .showDirections(
                          directionsMode: DirectionsMode.values
                              .where((e) => e.index == Preferences.tipoNav)
                              .first,
                          destinationTitle: widget.word,
                          destination: Coords(widget.latitud, widget.longitud))
                      .whenComplete(() async => widget.launch != null? await widget.launch!(null) : null)
            },
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
