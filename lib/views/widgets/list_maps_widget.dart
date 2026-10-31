import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:sizer/sizer.dart';

import 'map_widget/launch_map_icon.dart';

class ListMapsWidget extends StatefulWidget {
  final AvailableMap mapas;
  final double latitud;
  final double longitud;
  final Function(void) launch;
  final String word;
  const ListMapsWidget(
      {super.key,
      required this.mapas,
      required this.latitud,
      required this.longitud,
      required this.launch,
      required this.word});

  @override
  State<ListMapsWidget> createState() => _ListMapsWidgetState();
}

class _ListMapsWidgetState extends State<ListMapsWidget> {
  // Matriz de conversion a escala de grises
  static const List<double> _grayscaleMatrix = [
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final bool installed = widget.mapas.isInstalled;

    Widget tile = ListTile(
        onTap: installed
            ? () => Dialogs.showMorph(
                title: "Abrir por defecto",
                description:
                    "¿Desea usar esta aplicacion de navegacion cada que se intente navegar en algun mapa externo?",
                loadingTitle: "",
                onAcceptPressed: (context) async => setState(() {
                      Preferences.mapa = widget.mapas.name;
                    }))
            : null,
        dense: widget.mapas.name != Preferences.mapa,
        selectedTileColor: ThemaMain.dialogbackground,
        onLongPress: installed
            ? () {
                if (Preferences.mapa == widget.mapas.name) {
                  setState(() {
                    Preferences.mapa = "";
                  });
                }
              }
            : null,
        selected: widget.mapas.name == Preferences.mapa,
        leading: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              widget.mapas.iconBytes,
              height: 24.sp,
              width: 24.sp,
              errorBuilder: (context, error, stackTrace) => Icon(
                LineIcons.mapMarker,
                size: 24.sp,
                color: ThemaMain.darkBlue,
              ),
            )),
        title: Text(widget.mapas.name,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
        subtitle: installed
            ? (kDebugMode
                ? Text("${widget.mapas.isInstalled} - ${widget.mapas.name}",
                    style: TextStyle(fontSize: 14.sp))
                : null)
            : Text("No instalado",
                style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
        trailing: LaunchMapIcon(
            mapas: widget.mapas,
            latitud: widget.latitud,
            longitud: widget.longitud,
            launch: widget.launch,
            word: widget.word));

    if (!installed) {
      return Opacity(
        opacity: 0.45,
        child: ColorFiltered(
          colorFilter: const ColorFilter.matrix(_grayscaleMatrix),
          child: tile
        )
      );
    }

    return tile;
  }
}
