import 'package:auto_size_text/auto_size_text.dart';
import 'package:enrutador/models/referencia_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:latlong2/latlong.dart';
import 'package:sizer/sizer.dart';
import 'package:enrutador/views/dialogs/dialog_referencia.dart';

class ChipReferencia extends StatelessWidget {
  const ChipReferencia(
      {super.key,
      required this.ref,
      required this.latlng,
      required this.provider,
      required this.origen});

  final ReferenciaModelo ref;
  final MainProvider provider;
  final bool origen;
  final LatLng latlng;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ThemaMain.darkGrey, width: 1.sp)),
        child: GestureDetector(
            onTap: () async {
              MapFun.sendInitUri(
                  provider: provider,
                  lat: latlng.latitude,
                  lng: latlng.longitude);
              await provider.slide.close();
            },
            onLongPress: () async {
              showDialog(
                  barrierDismissible: false,
                  context: context,
                  builder: (context) =>
                      DialogReferencia(referencia: ref, origen: origen));
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              SizedBox(
                  width: 16.w,
                  child: AutoSizeText(
                      provider.roles
                              .firstWhereOrNull(
                                  (element) => element.id == ref.rolId)
                              ?.nombre ??
                          "Ref. ?",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 8,
                      style: TextStyle(
                          fontSize: 16.sp, fontWeight: FontWeight.bold))),
              SizedBox(width: 1.w),
              Icon(Icons.assistant_direction,
                  size: 22.sp,
                  color: origen ? ThemaMain.green : ThemaMain.primary)
            ])));
  }
}
