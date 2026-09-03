import 'package:enrutador/models/tip_model.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import '../../../utilities/theme/theme_app.dart';
import '../../dialogs/dialog_tip_info.dart';

class CardTip extends StatelessWidget {
  final TipModel tip;
  final Function(void) refresh;
  const CardTip({super.key, required this.tip, required this.refresh});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => showDialog(
            context: context,
            builder: (context) => DialogTipInfo(tip: tip, refresh: refresh)),
        borderRadius: BorderRadius.circular(borderRadius),
        child: Stack(children: [
          Card(
              elevation: tip.fechaCerrado != null ? 0 : null,
              color:
                  tip.fechaCerrado != null ? ThemaMain.dialogbackground : null,
              child: Column(children: [
                TextButton(
                    style: TextButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(horizontal: 1.w, vertical: 0)),
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: tip.uuid));
                      showToast("UUID copiado al portapapeles");
                    },
                    child: Text(tip.uuid,
                        style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.bold,
                            color: ThemaMain.darkBlue))),
                Padding(
                    padding: EdgeInsets.symmetric(horizontal: 2.w),
                    child: Row(
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Contiene ${tip.contactosIds.length} Tip(s).",
                              style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold)),
                          Text("De: ${tip.empleadoBy}",
                              style: TextStyle(
                                  fontSize: 15.sp, fontWeight: FontWeight.bold))
                        ])),
                Divider(indent: 8.w, endIndent: 8.w),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text(
                          "Fecha: ${Textos.fechaYMDHMS(fecha: tip.fechaCreacion)}",
                          style: TextStyle(fontSize: 14.sp)),
                      Text(
                          "Cerrado: ${tip.fechaCerrado == null ? "Pendiente" : Textos.fechaYMDHMS(fecha: tip.fechaCerrado!)}",
                          style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: tip.fechaCerrado == null
                                  ? FontWeight.normal
                                  : FontWeight.bold))
                    ])
              ])),
          Positioned(
              top: 2.w,
              left: 2.w,
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                tip.abierto == 0
                    ? Icon(LineIcons.eyeSlash,
                        size: 20.sp, color: ThemaMain.darkGrey)
                    : Icon(LineIcons.eye, size: 20.sp, color: ThemaMain.green),
                if (tip.estadoTip == 0)
                  Icon(LineIcons.bellSlash,
                      size: 20.sp, color: ThemaMain.purple)
              ]))
        ]));
  }
}
