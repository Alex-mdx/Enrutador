import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:sizer/sizer.dart';

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
  @override
  Widget build(BuildContext context) {
    return ListTile(
        onTap: () => Dialogs.showMorph(
            title: "Abrir por defecto",
            description:
                "¿Desea usar esta aplicacion de navegacion cada que se intente navegar en algun mapa externo?",
            loadingTitle: "",
            onAcceptPressed: (context) async => setState(() {
                  Preferences.mapa = widget.mapas.mapType.name;
                })),
        dense: widget.mapas.mapType.name != Preferences.mapa,
        selectedTileColor: ThemaMain.dialogbackground,
        onLongPress: () {
          if (Preferences.mapa == widget.mapas.mapType.name) {
            setState(() {
              Preferences.mapa = "";
            });
          }
        },
        selected: widget.mapas.mapType.name == Preferences.mapa,
        leading: Icon(
            widget.mapas.mapType.name.toLowerCase().contains("google")
                ? LineIcons.mapMarker
                : widget.mapas.mapType.name.toLowerCase().contains("waze")
                    ? LineIcons.waze
                    : widget.mapas.mapType.name.toLowerCase().contains("uber")
                        ? LineIcons.uber
                        : widget.mapas.mapType.name
                                .toLowerCase()
                                .contains("didi")
                            ? LineIcons.taxi
                            : LineIcons.question,
            size: 24.sp,
            color: ThemaMain.darkBlue),
        title: Text(widget.mapas.mapName,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
        subtitle: (kDebugMode)
            ? Text("${widget.mapas.icon} - ${widget.mapas.mapType.name}",
                style: TextStyle(fontSize: 14.sp))
            : null,
        trailing: IconButton.filledTonal(
            iconSize: 24.sp,
            onPressed: () async => Preferences.tipoNav == -1
                ? widget.launch(await widget.mapas.showMarker(
                    zoom: 15,
                    coords: Coords(widget.latitud, widget.longitud),
                    title: widget.word))
                : widget.launch(await widget.mapas.showDirections(
                    directionsMode: DirectionsMode.values
                        .where((e) => e.index == Preferences.tipoNav)
                        .first,
                    destinationTitle: widget.word,
                    destination: Coords(widget.latitud, widget.longitud))),
            icon: Icon( Preferences.tipoNav == 0 ? LineIcons.car
                          : Preferences.tipoNav == 1 ? LineIcons.walking
                              : Preferences.tipoNav == 2 ? LineIcons.busAlt
                                  : Preferences.tipoNav == 3 ? LineIcons.bicycle :Icons.launch, color: ThemaMain.primary)));
  }
}
