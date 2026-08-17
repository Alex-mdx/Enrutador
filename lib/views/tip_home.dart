import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/controllers/fireController/tip_fire.dart';
import 'package:enrutador/models/tip_model.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

import 'dialogs/dialog_tip_info.dart';

class TipHome extends StatefulWidget {
  const TipHome({super.key});

  @override
  State<TipHome> createState() => _TipHomeState();
}

class _TipHomeState extends State<TipHome> {
  bool find = false;
  List<TipModel> tips = [];

  @override
  void initState() {
    super.initState();
    findTips();
  }

  Future<void> findTips() async {
    try {
      var filter = Filter("uuid", whereIn: Preferences.tipsReaded);
      var list = await TipFire.getItemPersonalizado(
          filters: [], orderBy: "fecha_creacion", descending: false);
      setState(() {
        tips = list;
        find = true;
      });
    } catch (e) {
      setState(() {
        find = true;
      });
      showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 6.h,
            title: Text("Historial de tips asignados",
                style: TextStyle(fontSize: 18.sp))),
        body: SafeArea(
            child: !find
                ? Center(
                    child: LoadingAnimationWidget.flickr(
                        leftDotColor: ThemaMain.yellow,
                        rightDotColor: ThemaMain.green,
                        size: 36.sp))
                : tips.isEmpty
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          RiveAnimatedIcon(
                              riveIcon: RiveIcon.bell,
                              color: ThemaMain.yellow,
                              height: 32.sp,
                              width: 32.sp,
                              strokeWidth: 12.sp),
                          Text("No hay tips asignados",
                              style: TextStyle(fontSize: 16.sp))
                        ],
                      )
                    : ListView.builder(
                        itemCount: tips.length,
                        itemBuilder: (context, index) {
                          return tipCard(tip: tips[index]);
                        })));
  }

  Widget tipCard({required TipModel tip}) {
    return InkWell(
        onTap: () => showDialog(
            context: context, builder: (context) => DialogTipInfo(tip: tip)),
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
              child: tip.estadoTip == 0
                  ? Icon(LineIcons.eyeSlash,
                      size: 20.sp, color: ThemaMain.darkGrey)
                  : Icon(LineIcons.eye, size: 20.sp, color: ThemaMain.green))
        ]));
  }
}
