import 'package:enrutador/utilities/preferences.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:sizer/sizer.dart';

class DialogNav extends StatefulWidget {
  const DialogNav({super.key});

  @override
  State<DialogNav> createState() => _DialogNavState();
}

class _DialogNavState extends State<DialogNav> {
  List<String> tipos = DirectionsMode.values.map((e) => e.name).toList();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Automatizacion de navegacion",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
      Divider(),
      Text("Tipos de navegacion",
          style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold)),
      Text("Seleccione 2 veces la misma opcion para desactivar",
          style: TextStyle(fontSize: 14.sp)),
      Wrap(
          spacing: 1.w,
          runSpacing: 0,
          alignment: WrapAlignment.spaceAround,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: tipos
              .map((e) => ChoiceChip.elevated(
                  onSelected: (value) {
                    setState(() {
                      if (Preferences.tipoNav ==
                          DirectionsMode.values
                              .firstWhere((element) => element.name.contains(e))
                              .index) {
                        Preferences.tipoNav = -1;
                      } else {
                        Preferences.tipoNav = DirectionsMode.values
                            .firstWhere((element) => element.name.contains(e))
                            .index;
                      }
                    });
                  },
                  showCheckmark: false,
                  avatar: Icon(
                      e.toLowerCase().contains("driving")
                          ? LineIcons.car
                          : e.toLowerCase().contains("walking")
                              ? LineIcons.walking
                              : e.toLowerCase().contains("transit")
                                  ? LineIcons.busAlt
                                  : e.toLowerCase().contains("bicycling")
                                      ? LineIcons.bicycle
                                      : LineIcons.questionCircleAlt,
                      size: 19.sp),
                  label: Text(e, style: TextStyle(fontSize: 14.sp)),
                  selected: Preferences.tipoNav ==
                      DirectionsMode.values
                          .firstWhere((element) => element.name.contains(e))
                          .index))
              .toList()),
      Text(
          "Al activar una opción, las indicaciones de navegación se mostrarán automáticamente en el tipo de vehiculo seleccionado",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14.sp, fontStyle: FontStyle.italic))
    ]));
  }
}
