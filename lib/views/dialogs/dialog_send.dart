import 'package:enrutador/utilities/number_fun.dart';
import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:oktoast/oktoast.dart';
import 'package:sizer/sizer.dart';

import 'dialog_lada.dart';

class DialogSend extends StatefulWidget {
  final String cabeza;
  final Function(String?) fun;
  final TextInputType tipoTeclado;
  final String? entradaTexto;
  final DateTime? fecha;
  final int? lenght;
  final String? lada;
  final TextInputAction? input;
  const DialogSend(
      {super.key,
      required this.cabeza,
      required this.fun,
      required this.tipoTeclado,
      required this.fecha,
      required this.entradaTexto,
      this.lenght,
      this.lada,
      this.input});

  @override
  State<DialogSend> createState() => _DialogSendState();
}

class _DialogSendState extends State<DialogSend> {
  String? ladaFinal;
  bool send = false;
  TextEditingController controller = TextEditingController();
  @override
  void initState() {
    ladaFinal = widget.lada;
    controller.text = widget.entradaTexto ?? "";
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: !send,
        child: Dialog(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
          Padding(
              padding: EdgeInsets.symmetric(horizontal: 1.w),
              child: Text(widget.cabeza,
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))),
          Divider(),
          Padding(
              padding: EdgeInsets.all(8.sp),
              child: Column(children: [
                if (widget.fecha != null)
                  Text(
                      "Ultima modificacion: ${Textos.fechaYMDHMS(fecha: widget.fecha!)}",
                      style: TextStyle(
                          fontSize: 15.sp, fontStyle: FontStyle.italic)),
                TextField(
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 1,
                    maxLines: 5,
                    enabled: !send,
                    maxLength: widget.lenght,
                    controller: controller,
                    textInputAction: widget.input,
                    keyboardType: widget.tipoTeclado,
                    decoration: InputDecoration(
                        prefixIcon: widget.lenght != null
                            ? Preferences.lada == "" && ladaFinal == null
                                ? IconButton.filled(
                                    iconSize: 20.sp,
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => DialogLada(
                                            ladaGet: (p0) => setState(() {
                                                  ladaFinal = p0;
                                                }))),
                                    icon: Icon(Icons.numbers_rounded,
                                        color: ThemaMain.primary))
                                : TextButton(
                                    onPressed: () => showDialog(
                                        context: context,
                                        builder: (context) => DialogLada(
                                            ladaGet: (p0) => setState(() {
                                                  ladaFinal = p0;
                                                }))),
                                    child: Text(ladaFinal ?? Preferences.lada,
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            fontWeight: FontWeight.bold)))
                            : null,
                        suffixIcon: widget.lenght != null
                            ? IconButton.filledTonal(
                                iconSize: 20.sp,
                                onPressed: () async {
                                  var number = (await Clipboard.getData(
                                          Clipboard.kTextPlain))
                                      ?.text
                                      ?.removeAllWhitespace;
                                  debugPrint("pegar: $number");
                                  if (number != null) {
                                    setState(() {
                                      ladaFinal = NumberFun.onlyLada(number) ==
                                              null
                                          ? Preferences.lada == ""
                                              ? null
                                              : "+${Preferences.lada}"
                                          : "+${NumberFun.onlyLada(number)}";
                                      controller.text =
                                          NumberFun.formatNumber(number)
                                              .removeAllWhitespace;
                                    });
                                  } else {
                                    showToast(
                                        "No hay numero en el portapapeles");
                                  }
                                },
                                icon: Icon(Icons.content_paste_go,
                                    color: ThemaMain.primary))
                            : null,
                        contentPadding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 1.h))),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                          icon: Icon(Icons.close,
                              size: 22.sp,
                              color: send ? ThemaMain.darkGrey : ThemaMain.red),
                          onPressed: () => send ? null : Navigation.pop(),
                          label: Text("Cerrar",
                              style: TextStyle(fontSize: 16.sp))),
                      ElevatedButton.icon(
                          icon: Icon(LineIcons.userCheck,
                              size: 22.sp,
                              color:
                                  send ? ThemaMain.darkGrey : ThemaMain.green),
                          onPressed: () async {
                            if (!send) {
                              if (controller.text != "" ||
                                  controller.text.isEmpty) {
                                if (widget.lenght != null) {
                                  if (controller.text.length == widget.lenght) {
                                    setState(() {
                                      send = true;
                                    });
                                    await widget.fun(
                                        "${widget.lenght == null ? "" : ladaFinal ?? Preferences.lada}${controller.text}");
                                    Navigation.pop();
                                  } else {
                                    showToast(
                                        "Se necesitan 10 digitos para que sea un numero telefonico valido");
                                  }
                                } else {
                                  setState(() {
                                    send = true;
                                  });
                                  await widget.fun(
                                      "${widget.lenght == null ? "" : ladaFinal ?? Preferences.lada}${controller.text}");
                                  Navigation.pop();
                                }
                              }
                            }
                          },
                          label: Text("Aceptar",
                              style: TextStyle(fontSize: 16.sp)))
                    ])
              ]))
        ])));
  }
}
