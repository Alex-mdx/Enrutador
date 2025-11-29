import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';

import 'dialogs/dialog_nav.dart';
import 'widgets/list_maps_widget.dart';

class NavegarView extends StatelessWidget {
  const NavegarView({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            title: Text("Navegacion", style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton.filled(
                  iconSize: 22.sp,
                  onPressed: () => showDialog(
                      context: context, builder: (context) => DialogNav()),
                  icon: Preferences.tipoNav != -1
                      ? Icon(
                          Preferences.tipoNav == 0
                              ? LineIcons.car
                              : Preferences.tipoNav == 1
                                  ? LineIcons.walking
                                  : Preferences.tipoNav == 2
                                      ? LineIcons.busAlt
                                      : Preferences.tipoNav == 3
                                          ? LineIcons.bicycle
                                          : LineIcons.questionCircleAlt,
                          color: ThemaMain.green)
                      : Icon(Icons.auto_fix_off, color: ThemaMain.primary))
            ]),
        body: FutureBuilder(
            future: MapLauncher.installedMaps,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return snapshot.data!.isEmpty
                    ? Center(
                        child: Text(
                            "No tienes ninguna aplicacion de navegacion disponible",
                            style: TextStyle(
                                fontSize: 15.sp, fontWeight: FontWeight.bold)))
                    : ListView.builder(
                        padding: EdgeInsets.symmetric(horizontal: 2.w),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          AvailableMap mapas = snapshot.data![index];
                          return Padding(
                              padding: EdgeInsets.only(bottom: 1.h),
                              child: ListMapsWidget(
                                  word: "Mi direccion",
                                  mapas: mapas,
                                  latitud: provider.local!.latitude!,
                                  longitud: provider.local!.longitude!,
                                  launch: (p0) => showToast("Mapa lanzado")));
                        });
              } else if (snapshot.hasError) {
                return Center(
                    child: Text("Error: ${snapshot.error}",
                        style: TextStyle(fontSize: 14.sp)));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}
