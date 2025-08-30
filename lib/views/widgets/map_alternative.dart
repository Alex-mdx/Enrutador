import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:enrutador/views/dialogs/dialog_enrutamiento.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'package:badges/badges.dart' as bd;

import '../../controllers/enrutar_controller.dart';

class MapAlternative extends StatefulWidget {
  const MapAlternative({super.key});

  @override
  State<MapAlternative> createState() => _MapAlternativeState();
}

class _MapAlternativeState extends State<MapAlternative> {
  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Padding(
        padding: EdgeInsets.only(left: 2.w, bottom: 4.h),
        child: Column(spacing: .5.h, mainAxisSize: MainAxisSize.min, children: [
          FutureBuilder(
              future: EnrutarController.getItems(),
              builder: (context, data) {
                if (data.hasData && (data.data?.isNotEmpty ?? false)) {
                  return bd.Badge(
                      badgeStyle: bd.BadgeStyle(badgeColor: ThemaMain.primary),
                      badgeContent: Text("${data.data?.length ?? 0}",
                          style: TextStyle(
                              color: ThemaMain.second,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold)),
                      child: InkWell(onTap: () => showDialog(context: context, builder: (context) => DialogEnrutamiento()),
                        child: Container(
                            decoration: BoxDecoration(
                                color: ThemaMain.dialogbackground,
                                borderRadius:
                                    BorderRadius.circular(borderRadius)),
                            child: Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 2.w, vertical: .2.h),
                                child: Column(children: [
                                  Icon(LineIcons.route,
                                      color: ThemaMain.green, size: 25.sp),
                                  Text("Enrutar",
                                      style: TextStyle(
                                          fontSize: 15.sp,
                                          fontWeight: FontWeight.bold))
                                ])))
                      ));
                } else {
                  return Text("");
                }
              }),
          IconButton.filledTonal(
              iconSize: 26.sp,
              onPressed: () async {
                provider.mapaReal = !provider.mapaReal;
              },
              icon: Icon(Icons.map,
                  color: provider.mapaReal ? ThemaMain.red : ThemaMain.primary))
        ]));
  }
}
