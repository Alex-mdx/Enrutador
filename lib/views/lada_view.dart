import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_libphonenumber/flutter_libphonenumber.dart';
import 'package:sizer/sizer.dart';

import '../utilities/theme/theme_color.dart';

class LadaView extends StatelessWidget {
  const LadaView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("Lada", style: TextStyle(fontSize: 18.sp))),
        body: FutureBuilder(
            future: getAllSupportedRegions(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Scrollbar(
                    thickness: 3.w,
                    child: ListView.builder(
                        shrinkWrap: true,
                        padding: EdgeInsets.all(0),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          final data = snapshot.data!.values.toList()[index];
                          return ListTile(
                              dense: Preferences.lada != "+${data.phoneCode}",
                              selectedTileColor: ThemaMain.green.withAlpha(100),
                              selected:
                                  Preferences.lada == "+${data.phoneCode}",
                              onTap: () => Dialogs.showMorph(
                                  title: "Seleccionar lada por defecto",
                                  description:
                                      "Al guardar la lada, cuando guarde un numero telefonico, este se colocara de manera automatica a menos que lo personalice",
                                  loadingTitle: "guardando",
                                  onAcceptPressed: (context) async =>
                                      Preferences.lada = "+${data.phoneCode}"),
                              leading: Text("+${data.phoneCode}",
                                  style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold)),
                              title: Text(
                                  "${data.countryName} - ${data.countryCode}",
                                  style: TextStyle(fontSize: 16.sp)),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 1.w, vertical: 0));
                        }));
              } else if (snapshot.hasError) {
                return Text("${snapshot.error}",
                    style: TextStyle(fontSize: 14.sp));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            }));
  }
}
