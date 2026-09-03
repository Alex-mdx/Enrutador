import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/controllers/fireController/tip_fire.dart';
import 'package:enrutador/models/tip_model.dart';
import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

import 'widgets/extras/card_tip.dart';

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
      var filter = Filter.and(Filter("uuid", whereIn: Preferences.tipsReaded),
          Filter("estado_tip", isEqualTo: 1));
      var list = await TipFire.getItemPersonalizado(
          filters: [filter], orderBy: "fecha_creacion", descending: false);
      setState(() {
        if (list.isEmpty) {
          Preferences.tipsReaded = [];
        }
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
    final provider = Provider.of<MainProvider>(context);
    return Scaffold(
        appBar: AppBar(
            toolbarHeight: 6.h,
            title: Text("Historial de tips asignados",
                style: TextStyle(fontSize: 18.sp)),
            actions: [
              IconButton.filledTonal(
                  onPressed: () async => await TipFire.findTips(
                      empleadoId: provider.usuario!.empleadoId!.toString(),
                      estadoTip: true),
                  icon: Icon(LineIcons.syncIcon,
                      size: 18.sp, color: ThemaMain.green))
            ]),
        body: SafeArea(
            child: !find
                ? Center(
                    child: LoadingAnimationWidget.flickr(
                        leftDotColor: ThemaMain.yellow,
                        rightDotColor: ThemaMain.green,
                        size: 36.sp))
                : tips.isEmpty
                    ? Center(
                        child: Column(
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
                          ]))
                    : ListView.builder(
                        itemCount: tips.length,
                        itemBuilder: (context, index) {
                          return CardTip(
                              tip: tips[index], refresh: (p0) => findTips());
                        })));
  }
}
