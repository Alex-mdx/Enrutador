import 'package:enrutador/utilities/share_fun.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../models/roles_model.dart';
import '../../utilities/theme/theme_color.dart';

class ListRolesWidget extends StatelessWidget {
  final RolesModel estado;
  final Function() fun;
  final bool share;
  final bool selectedVisible;
  final bool selected;
  final Function(bool?) onSelected;
  final bool dense;
  const ListRolesWidget(
      {super.key,
      required this.estado,
      required this.fun,
      required this.share,
      required this.selectedVisible,
      required this.selected,
      required this.onSelected,
      required this.dense});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => fun(),
        child: Card(
            color: estado.color,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        if (selectedVisible)
                          Checkbox.adaptive(
                              value: selected,
                              onChanged: (value) => onSelected(value)),
                      ]),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(left: 2.w),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(estado.icon,
                                        color: ThemaMain.white, size: 25.sp),
                                    Text(estado.nombre,
                                        style: TextStyle(
                                            backgroundColor: ThemaMain.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold))
                                  ]))),
                      if (share)
                        IconButton.filledTonal(
                            iconSize: 20.sp,
                            onPressed: () async {
                              showToast("Generando archivo...");
                              var data = (await ShareFun.shareDatas(
                                      nombre: "roles", datas: [estado]))
                                  .firstOrNull;
                              if (data != null) {
                                XFile file = XFile(data.path);
                                await ShareFun.share(
                                    titulo: "Objeto roles",
                                    mensaje:
                                        "este archivo contiene datos de roles generados",
                                    files: [file]);
                              }
                            },
                            icon: Icon(Icons.offline_share,
                                color: ThemaMain.green))
                    ]))));
  }
}
