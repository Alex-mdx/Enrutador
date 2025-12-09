import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/dialogs/dialog_enrutamiento.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:badges/badges.dart' as bd;

import '../../../controllers/enrutar_controller.dart';

class MapAlternative extends StatefulWidget {
  const MapAlternative({super.key});

  @override
  State<MapAlternative> createState() => _MapAlternativeState();
}

class _MapAlternativeState extends State<MapAlternative> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return AnimatedPadding(
        padding: EdgeInsets.only(
            left: 1.w,
            bottom: provider.selectRefencia != null
                ? 6.h
                : provider.cargaDatos
                    ? 4.h
                    : 2.h),
        duration: Duration(milliseconds: 500),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: .5.h,
            mainAxisSize: MainAxisSize.min,
            children: [
              bd.Badge(
                  badgeStyle: bd.BadgeStyle(badgeColor: ThemaMain.primary),
                  badgeContent: FutureBuilder(
                      future: EnrutarController.getItems(),
                      builder: (context, data) {
                        return Text("${data.data?.length ?? 0}",
                            style: TextStyle(
                                color: ThemaMain.second,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.bold));
                      }),
                  child: InkWell(
                      onTap: () => showDialog(
                          context: context,
                          builder: (context) =>
                              DialogEnrutamiento(provider: provider)),
                      child: Container(
                          decoration: BoxDecoration(
                              color: ThemaMain.dialogbackground,
                              borderRadius:
                                  BorderRadius.circular(borderRadius)),
                          child: Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 2.w, vertical: .2.h),
                              child: Column(children: [
                                Icon(LineIcons.directions,
                                    color: ThemaMain.green, size: 25.sp),
                                Text("Enrutar",
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold))
                              ]))))),
              Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(borderRadius),
                      color: Colors.black38),
                  child: Row(
                      mainAxisSize: MainAxisSize.min,
                      spacing: 2.w,
                      children: [
                        IconButton.filledTonal(
                            iconSize: 22.sp,
                            onPressed: () async {
                              setState(() {
                                Preferences.grid = !Preferences.grid;
                              });

                              if (Preferences.grid) {
                                showToast("Cuadricula activada");
                              } else {
                                showToast("Cuadricula Desactivada");
                              }
                            },
                            icon: Icon(
                                Preferences.grid
                                    ? Icons.grid_on
                                    : Icons.grid_off,
                                color: Preferences.grid
                                    ? ThemaMain.primary
                                    : ThemaMain.red)),
                        IconButton.filledTonal(
                            iconSize: 22.sp,
                            onPressed: () async {
                              setState(() {
                                provider.mapaReal = !provider.mapaReal;
                              });
                              if (provider.mapaReal) {
                                showToast("Mapa Satelital");
                              } else {
                                showToast("Mapa Animado");
                              }
                            },
                            icon: Icon(Icons.map,
                                color: provider.mapaReal
                                    ? ThemaMain.red
                                    : ThemaMain.primary))
                      ]))
            ]));
  }
}
