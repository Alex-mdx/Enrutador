import 'package:enrutador/models/estado_model.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:readmore/readmore.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/share_fun.dart';
import '../../utilities/theme/theme_color.dart';

class ListEstadoWidget extends StatelessWidget {
  final EstadoModel estado;
  final Function() fun;
  final bool share;
  final bool selectedVisible;
  final bool selected;
  final Function(bool?) onSelected;
  final bool dense;
  const ListEstadoWidget(
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
                padding: EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.h),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          constraints:
                              BoxConstraints(maxWidth: dense ? 18.w : 23.w),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (selectedVisible)
                              Checkbox.adaptive(
                                  value: selected,
                                  onChanged: (value) => onSelected(value)),
                            if (!dense)
                              Stack(alignment: Alignment.center, children: [
                                Icon(Icons.circle,
                                    color: ThemaMain.second,
                                    size: dense ? 23.sp : 26.sp),
                                Text("${estado.orden}",
                                    style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.bold))
                              ])
                          ])),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(left: 1.w),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(estado.nombre,
                                        style: TextStyle(
                                            backgroundColor: ThemaMain.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    ReadMoreText(
                                        estado.descripcion == "" ||
                                                estado.descripcion == null
                                            ? "No se incluyo descripcion"
                                            : estado.descripcion!,
                                        trimCollapsedText: " Leer mas",
                                        trimExpandedText: " .Leer menos",
                                        lessStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontStyle: FontStyle.italic,
                                            color: ThemaMain.darkBlue),
                                        moreStyle: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: ThemaMain.darkBlue),
                                        trimMode: TrimMode.Line,
                                        trimLines: 2,
                                        style: TextStyle(
                                            backgroundColor: ThemaMain.white,
                                            fontStyle: estado.descripcion ==
                                                        "" ||
                                                    estado.descripcion == null
                                                ? FontStyle.normal
                                                : FontStyle.italic,
                                            fontWeight: FontWeight.normal,
                                            fontSize: estado.descripcion ==
                                                        "" ||
                                                    estado.descripcion == null
                                                ? 16.sp
                                                : 15.sp))
                                  ]))),
                      if (share)
                        IconButton.filledTonal(
                            iconSize: 20.sp,
                            onPressed: () async {
                              showToast("Generando archivo...");
                              var data = (await ShareFun.shareDatas(
                                      nombre: "estados", datas: [estado]))
                                  .firstOrNull;
                              if (data != null) {
                                XFile file = XFile(data.path);
                                await ShareFun.share(
                                    titulo: "Objeto estados",
                                    mensaje:
                                        "este archivo contiene datos de estados generados",
                                    files: [file]);
                              }
                            },
                            icon: Icon(Icons.offline_share,
                                color: ThemaMain.green))
                    ]))));
  }
}
