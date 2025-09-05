import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/theme/theme_color.dart';

class DialogCompartir extends StatelessWidget {
  final ContactoModelo contacto;
  const DialogCompartir({super.key, required this.contacto});

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Opciones al compartir",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
      Wrap(
          runAlignment: WrapAlignment.spaceAround,
          alignment: WrapAlignment.center,
          children: [
            Card(
                child: Column(children: [
              IconButton(
                  onPressed: () async => await ShareFun.share(
                      titulo: "Comparte este contacto",
                      mensaje:
                          "${ShareFun.copiar}\n*Plus Code*: ${Textos.psCODE(contacto.latitud, contacto.longitud)}${contacto.nombreCompleto != null ? "\n*Nombre*: ${contacto.nombreCompleto}" : ""}${contacto.domicilio != null ? "\n*Domicilio*: ${contacto.domicilio}" : ""}${contacto.numero != null ? "Telefono: ${contacto.numero}" : ""}${contacto.otroNumero != null ? "Telefono alt: ${contacto.otroNumero}" : ""}${contacto.nota != null ? "\n*Notas*: ${contacto.nota}" : ""}"),
                  icon: Icon(Icons.text_snippet,
                      size: 42.sp, color: ThemaMain.primary)),
              Text("Texto",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))
            ])),
            Card(
                child: Column(children: [
              IconButton(
                  onPressed: () async {
                    showToast("Generando archivo...");
                    var data = (await ShareFun.shareDatas(
                            nombre: contacto.nombreCompleto != null
                                ? "${contacto.nombreCompleto?.replaceAll(" ", "_")}"
                                : "contacto",
                            datas: [contacto]))
                        .firstOrNull;
                    if (data != null) {
                      XFile file = XFile(data.path);
                      await ShareFun.share(
                          titulo: "Objeto de contacto",
                          mensaje: "este archivo contiene datos de un contacto",
                          files: [file]);
                    }
                  },
                  icon: Icon(Icons.offline_share,
                      size: 42.sp, color: ThemaMain.green)),
              Text("Archivo",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))
            ])),
            Card(
                child: Column(children: [
              IconButton(
                  onPressed: () async {},
                  icon: Icon(Icons.image, size: 42.sp, color: ThemaMain.red)),
              Text("Imagen",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))
            ]))
          ])
    ]));
  }
}
