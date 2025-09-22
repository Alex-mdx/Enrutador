import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:latlong2/latlong.dart';
import 'package:oktoast/oktoast.dart';
import 'package:open_location_code/open_location_code.dart';
import 'package:sizer/sizer.dart';

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
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Column(children: [
            Row(children: [
              Expanded(
                  child: TextFormField(
                      enabled: psController.text.isEmpty &&
                          w3wController.text.isEmpty,
                      controller: latController,
                      onChanged: (value) => setState(() {
                            latController.text = value;
                          }),
                      keyboardType: TextInputType.numberWithOptions(),
                      style: TextStyle(fontSize: 18.sp),
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
                  child: TextFormField(
                      enabled: psController.text.isEmpty &&
                          w3wController.text.isEmpty,
                      controller: lngController,
                      onChanged: (value) => setState(() {
                            lngController.text = value;
                          }),
                      keyboardType: TextInputType.numberWithOptions(),
                      style: TextStyle(fontSize: 18.sp),
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
                              horizontal: 2.w, vertical: 1.h))))
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
                style: TextStyle(fontSize: 18.sp),
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
                  style: TextStyle(fontSize: 18.sp),
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
              widget.funLat(LatLng(double.parse(latController.text),
                  double.parse(lngController.text)));
            } else if (w3wController.text.isNotEmpty) {
            } else if (psController.text.isNotEmpty) {
              try {
                var ps = PlusCode(psController.text.removeAllWhitespace);
                var decode = ps.decode();
                widget.funLat(
                    LatLng(decode.center.latitude, decode.center.longitude));
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
