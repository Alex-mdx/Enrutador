import 'package:enrutador/models/tipos_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/share_fun.dart';

class ListTipoWidget extends StatelessWidget {
  final TiposModelo tipo;
  final Function() fun;
  final bool share;
  final bool selectedVisible;
  final bool selected;
  final Function(bool?) onSelected;
  const ListTipoWidget(
      {super.key,
      required this.tipo,
      required this.fun,
      required this.share,
      required this.selectedVisible,
      required this.selected,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => fun(),
        child: Card(
            color: tipo.color,
            child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                          constraints: BoxConstraints(maxWidth: 25.w),
                          child: Row(mainAxisSize: MainAxisSize.min, children: [
                            if (selectedVisible)
                              Checkbox.adaptive(
                                  value: selected,
                                  onChanged: (value) => onSelected(value)),
                            Stack(alignment: Alignment.center, children: [
                              Icon(Icons.circle,
                                  color: ThemaMain.second, size: 26.sp),
                              Icon(tipo.icon,
                                  color: ThemaMain.primary, size: 24.sp)
                            ])
                          ])),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(left: 2.w),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(tipo.nombre,
                                        style: TextStyle(
                                            backgroundColor: ThemaMain.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        tipo.descripcion == "" ||
                                                tipo.descripcion == null
                                            ? "No se incluyo descripcion"
                                            : tipo.descripcion!,
                                        style: TextStyle(
                                            backgroundColor: ThemaMain.white,
                                            fontStyle: tipo.descripcion == "" ||
                                                    tipo.descripcion == null
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            fontSize: 16.sp))
                                  ]))),
                      Container(
                          constraints: BoxConstraints(maxWidth: 25.w),
                          child: OverflowBar(
                              alignment: MainAxisAlignment.end,
                              overflowAlignment: OverflowBarAlignment.center,
                              children: [
                                IconButton.filledTonal(
                                    iconSize: 20.sp,
                                    onPressed: () async {
                                      showToast("Generando archivo...");
                                      var data = await ShareFun.shareDatas(
                                          nombre: "tipos", datas: [tipo]);
                                      if (data != null) {
                                        XFile file = XFile(data.path);
                                        await ShareFun.share(
                                            titulo: "Objeto tipos",
                                            mensaje:
                                                "este archivo contiene datos de tipos generados",
                                            files: [file]);
                                      }
                                    },
                                    icon: Icon(Icons.offline_share,
                                        color: ThemaMain.green))
                              ]))
                    ]))));
  }
}
