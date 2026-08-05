import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/main_provider.dart';

class DialogSendTip extends StatefulWidget {
  final List<int> tips;
  final UsuarioModel user;
  const DialogSendTip({super.key, required this.tips, required this.user});

  @override
  State<DialogSendTip> createState() => _DialogSendTipState();
}

class _DialogSendTipState extends State<DialogSendTip> {
  late String currentTip;
  String? assignedTo;

  @override
  void initState() {
    super.initState();
    currentTip = widget.user.empleadoId.toString();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MainProvider>(context);
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      AppBar(
        title: Text("Generar Tips", style: TextStyle(fontSize: 16.sp)),
      ),
      Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            RiveAnimatedIcon(
                riveIcon: RiveIcon.bell,
                color: ThemaMain.yellow,
                loopAnimation: true,
                enableAbsorbPointer: true,
                width: 22.sp,
                height: 22.sp,
                strokeWidth: 12.sp),
            Text("Estas asignando ${widget.tips.length} tips",
                style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold))
          ]),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          ElevatedButton.icon(
              style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 1.w, vertical: 0))),
              onPressed: () {},
              icon: Icon(LineIcons.helpingHands,
                  size: 20.sp, color: ThemaMain.green),
              label: Text(
                  "Creado por: ${currentTip == provider.usuario?.empleadoId.toString() ? "Ti" : currentTip}",
                  style: TextStyle(fontSize: 14.sp))),
          ElevatedButton.icon(
              style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 1.w, vertical: 0))),
              onPressed: () {},
              icon: Icon(LineIcons.handHoldingHeart,
                  size: 20.sp, color: ThemaMain.pink),
              label: Text(
                  "Asignado a: ${assignedTo == provider.usuario?.empleadoId.toString() ? "Ti mismo" : assignedTo ?? "Nadie"}",
                  style: TextStyle(fontSize: 14.sp)))
        ],
      ),
      ElevatedButton(
          onPressed: () {},
          child: Text("Asignar Tip", style: TextStyle(fontSize: 15.sp)))
    ]));
  }
}
