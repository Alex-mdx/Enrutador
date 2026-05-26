import 'package:enrutador/models/zona_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

class ListZonaWidget extends StatelessWidget {
  final ZonasModel zona;
  final Function() fun;
  final bool selectedVisible;
  final bool selected;
  final Function(bool?) onSelected;
  const ListZonaWidget(
      {super.key,
      required this.zona,
      required this.fun,
      required this.selectedVisible,
      required this.selected,
      required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () => fun(),
        child: Card(
            color: zona.color,
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
                          ])),
                      Expanded(
                          child: Padding(
                              padding: EdgeInsets.only(left: 2.w),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(zona.nombre,
                                        style: TextStyle(
                                            backgroundColor: ThemaMain.white,
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                        zona.notas == "" || zona.notas == null
                                            ? "No se incluyo ninguna nota"
                                            : zona.notas!,
                                        style: TextStyle(
                                            backgroundColor: ThemaMain.white,
                                            fontStyle: zona.notas == "" ||
                                                    zona.notas == null
                                                ? FontStyle.italic
                                                : FontStyle.normal,
                                            fontSize: 16.sp))
                                  ]))),
                      ElevatedButton.icon(
                          onPressed: () {},
                          label: Text(zona.latlongs.length.toString(),
                              style: TextStyle(fontSize: 16.sp)),
                          icon: Icon(LineIcons.mapMarked,
                              color: ThemaMain.red, size: 20.sp))
                    ]))));
  }
}
