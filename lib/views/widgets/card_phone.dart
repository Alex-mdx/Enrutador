import 'package:auto_size_text/auto_size_text.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:phone_state/phone_state.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

import '../../controllers/contacto_controller.dart';

class PhoneStateWidget extends StatelessWidget {
  const PhoneStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PhoneState>(
        stream: PhoneState.stream,
        builder: (context, snapshot) => AnimatedOpacity(
            opacity:
                snapshot.data?.status == PhoneStateStatus.CALL_INCOMING ? 1 : 0,
            duration: Durations.medium3,
            child: Card(
                child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 0),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      AvatarGlow(
                          glowCount: 2,
                          glowColor: ThemaMain.primary,
                          duration: Duration(seconds: 5),
                          glowRadiusFactor: .5.w,
                          startDelay: Duration(seconds: 2),
                          child: RiveAnimatedIcon(
                              riveIcon: RiveIcon.call,
                              strokeWidth: 2.h,
                              height: 4.h,
                              width: 4.h)),
                      Column(mainAxisSize: MainAxisSize.min, children: [
                        SizedBox(
                            width: 30.w,
                            child: FutureBuilder(
                                future: ContactoController.buscar(
                                    (snapshot.data?.number ?? "-1")
                                        .replaceAll(" ", ""),
                                    2),
                                builder: (context, contacto) => AutoSizeText(
                                    contacto.hasData
                                        ? contacto.data!
                                                .map((e) => e.nombreCompleto)
                                                .toList()
                                                .firstOrNull ??
                                            "Desconocido"
                                        : "Llamando...\nDesconocido",
                                    maxLines: 2,
                                    minFontSize: 14,
                                    textAlign: TextAlign.end,
                                    overflow: TextOverflow.fade,
                                    style: TextStyle(
                                        fontSize: 16.sp,
                                        fontWeight: FontWeight.bold))))
                      ])
                    ])))));
  }
}
