import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:latlong2/latlong.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/theme/theme_app.dart';
import '../../utilities/theme/theme_color.dart';

class DialogUbicacion extends StatefulWidget {
  final Function(LatLng?) funLat;
  const DialogUbicacion({super.key, required this.funLat});

  @override
  State<DialogUbicacion> createState() => _DialogUbicacionState();
}

class _DialogUbicacionState extends State<DialogUbicacion> {
  TextEditingController latController = TextEditingController();
  TextEditingController lngController = TextEditingController();
  TextEditingController psController = TextEditingController();
  TextEditingController w3wController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Cambio de ubicacion", style: TextStyle(fontSize: 16.sp)),
      Text("Ver ubicacion",
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
      Container(
          decoration: BoxDecoration(
              color: ThemaMain.background,
              borderRadius: BorderRadius.circular(borderRadius)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text("Plus Code", style: TextStyle(fontSize: 15.sp)),
            DefaultTextStyle(
                style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: ThemaMain.darkBlue),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text("Detallado"),
                  Switch.adaptive(
                      value: Preferences.psCodeExt,
                      onChanged: (value) => setState(() {
                            Preferences.psCodeExt = value;
                          })),
                  Text("Simple")
                ]))
          ])),
      Divider(),
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Column(children: [
            Row(children: [
              Expanded(
                  flex: 3,
                  child: TextFormField(
                      enabled: psController.text.isEmpty &&
                          w3wController.text.isEmpty,
                      controller: latController,
                      onChanged: (value) => setState(() {
                            latController.text = value;
                          }),
                      keyboardType: TextInputType.numberWithOptions(),
                      style: TextStyle(fontSize: 16.sp),
                      decoration: InputDecoration(
                          fillColor: ThemaMain.second,
                          label: Text("Latitud",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16.sp,
                                  color: ThemaMain.darkGrey)),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h)))),
              Expanded(
                  flex: 3,
                  child: TextFormField(
                      enabled: psController.text.isEmpty &&
                          w3wController.text.isEmpty,
                      controller: lngController,
                      onChanged: (value) => setState(() {
                            lngController.text = value;
                          }),
                      keyboardType: TextInputType.numberWithOptions(),
                      style: TextStyle(fontSize: 16.sp),
                      decoration: InputDecoration(
                          fillColor: ThemaMain.second,
                          label: Text("Longitud",
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontStyle: FontStyle.italic,
                                  fontSize: 16.sp,
                                  color: ThemaMain.darkGrey)),
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 2.w, vertical: 1.h)))),
              Expanded(
                  flex: 1,
                  child: IconButton.filled(
                      iconSize: 18.sp,
                      onPressed: () async {
                        try {
                          var string =
                              (await Clipboard.getData(Clipboard.kTextPlain))!
                                  .text
                                  ?.removeAllWhitespace;
                          latController.text = string!.split(",")[0];
                          lngController.text = string.split(",")[1];
                        } catch (e) {
                          showToast("No se detecto coordenadas");
                        }
                      },
                      icon: Icon(LineIcons.paste, color: ThemaMain.yellow)))
            ]),
            Divider(),
            TextFormField(
                enabled: latController.text.isEmpty &&
                    lngController.text.isEmpty &&
                    w3wController.text.isEmpty,
                controller: psController,
                onChanged: (value) => setState(() {
                      psController.text = value;
                    }),
                keyboardType: TextInputType.name,
                style: TextStyle(fontSize: 16.sp),
                decoration: InputDecoration(
                    fillColor: ThemaMain.second,
                    label: Text("Plus Code",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontStyle: FontStyle.italic,
                            fontSize: 16.sp,
                            color: ThemaMain.darkGrey)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h))),
            Divider(),
            if (kDebugMode)
              TextFormField(
                  enabled: latController.text.isEmpty &&
                      lngController.text.isEmpty &&
                      psController.text.isEmpty,
                  controller: w3wController,
                  onChanged: (value) => setState(() {
                        w3wController.text = value;
                      }),
                  keyboardType: TextInputType.text,
                  style: TextStyle(fontSize: 16.sp),
                  decoration: InputDecoration(
                      fillColor: ThemaMain.second,
                      label: Text("What 3 Words",
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 16.sp,
                              color: ThemaMain.darkGrey)),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h)))
          ])),
      ElevatedButton.icon(
          onPressed: () {
            if (latController.text.isNotEmpty &&
                lngController.text.isNotEmpty) {
              try {
                var ps = Textos.psCODE(double.parse(latController.text),
                    double.parse(lngController.text));
                var coord = Textos.truncPlusCode(PlusCode(ps));
                widget.funLat(coord);
              } catch (e) {
                showToast("No se pudo convertir en coordenadas");
              }
            } else if (w3wController.text.isNotEmpty) {
            } else if (psController.text.isNotEmpty) {
              try {
                widget.funLat(Textos.truncPlusCode(
                    PlusCode(psController.text.removeAllWhitespace)));
              } catch (e) {
                debugPrint("error: $e");
                showToast("Plus Code ingresado no valido");
              }
            }
          },
          label: Text("Cambiar ubicacion", style: TextStyle(fontSize: 15.sp)),
          icon: Icon(Icons.change_circle,
              size: 22.sp,
              color: (latController.text.isEmpty &&
                      lngController.text.isEmpty &&
                      psController.text.isEmpty)
                  ? ThemaMain.darkGrey
                  : ThemaMain.pink))
    ]));
  }
}
