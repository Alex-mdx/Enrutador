import 'package:auto_size_text/auto_size_text.dart';
import 'package:enrutador/utilities/number_fun.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:phone_state/phone_state.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

import '../../controllers/contacto_controller.dart';
import '../../utilities/main_provider.dart';

class PhoneStateWidget extends StatelessWidget {
  const PhoneStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return StreamBuilder<PhoneState>(
        stream: PhoneState.stream,
        builder: (context, snapshot) => snapshot.data?.status ==
                PhoneStateStatus.CALL_INCOMING
            ? AnimatedOpacity(
                opacity: snapshot.data?.status == PhoneStateStatus.CALL_INCOMING
                    ? 1
                    : 0,
                duration: Durations.medium3,
                child: FutureBuilder(
                    future: ContactoController.buscar(
                        (NumberFun.formatNumber(snapshot.data?.number ?? "-1"))
                            .replaceAll(" ", ""),
                        2),
                    builder: (context, contacto) => InkWell(
                        borderRadius: BorderRadius.circular(borderRadius),
                        onTap: () async {
                          if (contacto.hasData && contacto.data!.isNotEmpty) {
                            await provider.animaMap.centerOnPoint(
                                LatLng(contacto.data!.firstOrNull!.latitud,
                                    contacto.data!.firstOrNull!.longitud),
                                zoom: 18);
                          }
                        },
                        child: Card(
                            elevation: 2,
                            child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 1.w),
                                child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Stack(
                                          alignment: Alignment.center,
                                          children: [
                                            Icon(Icons.circle,
                                                color: ThemaMain.green,
                                                size: 28.sp),
                                            RiveAnimatedIcon(
                                                riveIcon: RiveIcon.call,
                                                strokeWidth: 2.h,
                                                height: 4.h,
                                                width: 4.h),
                                          ]),
                                      Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                                width: 30.w,
                                                child: AutoSizeText(
                                                    contacto.hasData
                                                        ? contacto.data!
                                                                .map((e) => e
                                                                    .nombreCompleto)
                                                                .toList()
                                                                .firstOrNull ??
                                                            "Llamando...\nDesconocido"
                                                        : "Llamando...\nDesconocido",
                                                    maxLines: 2,
                                                    minFontSize: 14,
                                                    textAlign: TextAlign.end,
                                                    overflow: TextOverflow.fade,
                                                    style: TextStyle(
                                                        fontSize: 16.sp,
                                                        fontWeight:
                                                            FontWeight.bold)))
                                          ])
                                    ]))))))
            : SizedBox());
  }
}
