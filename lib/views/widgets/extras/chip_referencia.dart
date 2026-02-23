import 'package:auto_size_text/auto_size_text.dart';
import 'package:enrutador/models/referencia_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:get/get_utils/src/extensions/export.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:enrutador/views/dialogs/dialog_referencia.dart';

class ChipReferencia extends StatelessWidget {
  const ChipReferencia(
      {super.key,
      required this.ref,
      required this.latlng,
      required this.origen,
      this.extended = false,
      this.tap = true});

  final ReferenciaModelo ref;
  final bool origen;
  final LatLng latlng;
  final bool? tap;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Container(
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: ThemaMain.darkGrey, width: 1.sp)),
        child: GestureDetector(
            onTap: () async {
              if (tap == true) {
                MapFun.sendInitUri(
                    provider: provider,
                    lat: latlng.latitude,
                    lng: latlng.longitude);
                await provider.slide.close();
              }
            },
            onLongPress: () async {
              if (tap == true) {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (context) =>
                        DialogReferencia(referencia: ref, origen: origen));
              }
            },
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Container(
                  constraints: BoxConstraints(maxWidth: extended ? 25.w : 18.w),
                  child: AutoSizeText(
                      (provider.roles
                                  .firstWhereOrNull(
                                      (element) => element.id == ref.rolId)
                                  ?.nombre ??
                              "Desconocido")
                          .replaceAll("Ref. ", ""),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      minFontSize: 8,
                      style: TextStyle(
                          fontSize: extended ? 18.sp : 15.sp,
                          fontWeight: FontWeight.bold))),
              SizedBox(width: .5.w),
              Icon(Icons.assistant_direction,
                  size: extended ? 26.sp : 21.sp,
                  color: origen
                      ? provider.roles
                              .firstWhereOrNull(
                                  (element) => element.id == ref.rolId)
                              ?.color ??
                          ThemaMain.green
                      : ThemaMain.primary)
            ])));
  }
}
