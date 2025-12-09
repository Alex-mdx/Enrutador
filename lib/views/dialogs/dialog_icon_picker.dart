import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

class DialogIconPicker extends StatefulWidget {
  final Function(IconData) iconFun;
  const DialogIconPicker({super.key, required this.iconFun});

  @override
  State<DialogIconPicker> createState() => _DialogIconPickerState();
}

class _DialogIconPickerState extends State<DialogIconPicker> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Seleccione un icono", style: TextStyle(fontSize: 16.sp)),
      Container(
          constraints: BoxConstraints(maxHeight: 85.h),
          child: SingleChildScrollView(
              child: Scrollbar(
                  child: Wrap(
                      spacing: .5.w,
                      runSpacing: 0,
                      children: LineIcons.values.values
                          .map((e) => GestureDetector(
                              onTap: () {
                                widget.iconFun(e);
                                Navigation.pop();
                              },
                              child: Icon(e,
                                  color: ThemaMain.darkBlue, size: 11.w)))
                          .toList()))))
    ]));
  }
}
