/* import 'package:flutter/material.dart';
import 'package:m3e_core/m3e_core.dart';

class MyWidget extends StatelessWidget {
  final bool condicion;
  final Text texto;
  final Widget icon;
  final bool showLabel
  const MyWidget(
      {super.key,
      required this.texto,
      required this.icon,
      this.condicion = false});

  @override
  Widget build(BuildContext context) {
    return M3EToggleButton(
        icon: icon,
        checkedLabel: Text(texto,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold)),
        checked: condicion,
        size: condicion ? M3EButtonSize.sm : M3EButtonSize.md,
        decoration: M3EToggleButtonDecoration(
            backgroundColor: WidgetStatePropertyAll(condicion
                ? ThemaMain.darkBlue.withAlpha(220)
                : ThemaMain.dialogbackground.withAlpha(220)),
            haptic: M3EHapticFeedback.light,
            motion: M3EMotion.expressiveSpatialDefault),
        onCheckedChange: (p) => fun(),
        onLongPress: delete);
  }
}
 */