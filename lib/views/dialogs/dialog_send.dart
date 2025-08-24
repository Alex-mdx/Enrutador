import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:sizer/sizer.dart';

class DialogSend extends StatelessWidget {
  final String cabeza;
  final Function(String?) fun;
  final TextInputType tipoTeclado;
  final String? entradaTexto;
  final DateTime? fecha;
  final int? lenght;
  const DialogSend(
      {super.key,
      required this.cabeza,
      required this.fun,
      required this.tipoTeclado,
      required this.fecha,
      required this.entradaTexto,
      this.lenght});

  @override
  Widget build(BuildContext context) {
    TextEditingController controller =
        TextEditingController(text: entradaTexto);
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Padding(
          padding: EdgeInsets.symmetric(horizontal: 1.w),
          child: Text(cabeza,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))),
      Divider(),
      Padding(
          padding: EdgeInsets.all(8.sp),
          child: Column(children: [
            if (fecha != null)
              Text("Ultima modificacion: ${Textos.fechaYMDHMS(fecha: fecha!)}",
                  style:
                      TextStyle(fontSize: 15.sp, fontStyle: FontStyle.italic)),
            TextField(
                textCapitalization: TextCapitalization.sentences,
                minLines: 1,
                maxLines: 4,
                maxLength: lenght,
                controller: controller,
                keyboardType: tipoTeclado,
                decoration: InputDecoration(
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.h))),
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              ElevatedButton.icon(
                  icon: Icon(Icons.close, size: 22.sp, color: ThemaMain.red),
                  onPressed: () => Navigation.pop(),
                  label: Text("Cerrar", style: TextStyle(fontSize: 16.sp))),
              ElevatedButton.icon(
                  icon: Icon(LineIcons.userCheck,
                      size: 22.sp, color: ThemaMain.green),
                  onPressed: () {
                    if (controller.text != "" || controller.text.isEmpty) {
                      fun(controller.text);
                    }
                    Navigation.pop();
                  },
                  label: Text("Aceptar", style: TextStyle(fontSize: 16.sp)))
            ])
          ]))
    ]));
  }
}
