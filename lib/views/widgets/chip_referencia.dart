import 'package:enrutador/controllers/roles_controller.dart';
import 'package:enrutador/models/referencia_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/map_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
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
    return GestureDetector(
        onLongPress: () async {
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) =>
                  DialogReferencia(referencia: ref, origen: origen));
        },
        child: Chip(
            deleteIcon: Icon(Icons.assistant_direction,
                size: 20.sp,
                color: origen ? ThemaMain.green : ThemaMain.primary),
            onDeleted: () async {
              MapFun.sendInitUri(
                  provider: provider,
                  lat: latlng.latitude,
                  lng: latlng.longitude);
              await provider.slide.close();
            },
            padding: EdgeInsets.all(0),
            labelPadding: EdgeInsets.all(4.sp),
            label: FutureBuilder(
                future: RolesController.getId(ref.rolId ?? -1),
                builder: (context, snapshot) {
                  return Text(
                      snapshot.connectionState == ConnectionState.waiting &&
                              !snapshot.hasData
                          ? "..."
                          : snapshot.data?.nombre ?? "Ref. ?",
                      style: TextStyle(fontSize: 14.sp));
                })));
  }
}
