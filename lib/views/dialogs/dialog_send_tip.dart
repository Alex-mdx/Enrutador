import 'package:enrutador/models/tip_model.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:sizer/sizer.dart';

import '../../controllers/fireController/tip_fire.dart';
import '../../utilities/main_provider.dart';
import '../widgets/extras/card_user_select.dart';

class DialogSendTip extends StatefulWidget {
  final List<String> tips;
  final UsuarioModel user;
  const DialogSendTip({super.key, required this.tips, required this.user});

  @override
  State<DialogSendTip> createState() => _DialogSendTipState();
}

class _DialogSendTipState extends State<DialogSendTip> {
  bool _isLoading = false;
  late String currentTip;
  String? assignedTo;
  TextEditingController controller = TextEditingController();

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
          toolbarHeight: 6.h),
      Column(children: [
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
                  style:
                      TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold))
            ]),
        Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          ElevatedButton.icon(
              style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 1.w, vertical: 0))),
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => Dialog(
                      child: CardUserSelect(
                          empleadoSelected: currentTip,
                          onTap: (e) {
                            setState(() {
                              currentTip = e.empleadoId!;
                            });
                            Navigation.pop();
                          }))),
              icon: Icon(LineIcons.helpingHands,
                  size: 20.sp, color: ThemaMain.green),
              label: Text(
                  "Creado por: ${currentTip == provider.usuario?.empleadoId ? "Ti" : currentTip}",
                  style: TextStyle(fontSize: 14.sp))),
          ElevatedButton.icon(
              style: ButtonStyle(
                  padding: WidgetStatePropertyAll(
                      EdgeInsets.symmetric(horizontal: 1.w, vertical: 0))),
              onPressed: () => showDialog(
                  context: context,
                  builder: (context) => Dialog(
                      child: CardUserSelect(
                          empleadoSelected:
                              assignedTo ?? provider.usuario?.empleadoId,
                          onTap: (e) {
                            setState(() {
                              assignedTo = e.empleadoId;
                            });
                            Navigation.pop();
                          },
                          onlyOwn: true))),
              icon: Icon(LineIcons.handHoldingHeart,
                  size: 20.sp, color: ThemaMain.pink),
              label: Text(
                  "Asignado a: ${assignedTo == provider.usuario?.empleadoId ? "Ti mismo" : assignedTo ?? "Nadie"}",
                  style: TextStyle(fontSize: 14.sp)))
        ]),
        Padding(
            padding: EdgeInsets.all(8.sp),
            child: TextField(
                minLines: 1,
                maxLines: 4,
                controller: controller,
                decoration: InputDecoration(
                    hintText: "Contexto del tip",
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: ThemaMain.darkGrey)),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 1.w, vertical: 1.w)))),
        ElevatedButton(
            onPressed: () async {
              if (assignedTo == null) {
                showToast("Debes asignar un tip a alguien");
                return;
              }
              setState(() {
                _isLoading = true;
              });

              await Future.delayed(const Duration(seconds: 2), () async {
                setState(() {
                  _isLoading = false;
                });
              });

              var tipModel = TipModel(
                  uuid: Textos.randomWord(10),
                  contactosIds: widget.tips,
                  empleadoCreado: provider.usuario!.empleadoId!.toString(),
                  empleadoBy: currentTip,
                  empleadoTo: assignedTo!,
                  contexto: controller.text,
                  abierto: 1,
                  estadoTip: 1,
                  fechaCreacion: DateTime.now());
              var result = await TipFire.sendItem(data: tipModel);
              if (result) {
                showToast("Tip enviado correctamente");
                //Navigation.pop();
              } else {
                showToast("Error al enviar tip");
              }
            },
            child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text("Asignar Tip", style: TextStyle(fontSize: 15.sp))))
      ])
    ]));
  }
}
