import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/camara_fun.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/views/widgets/sliding_cards/tarjeta_contacto_detalle.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:widgets_to_image/widgets_to_image.dart';

import '../../utilities/pluscode_fun.dart';
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
                          "${ShareFun.copiar}\n*Plus Code*: ${PlusCodeFun.psCODE(contacto.latitud, contacto.longitud)}${contacto.nombreCompleto != null ? "\n*Nombre*: ${contacto.nombreCompleto}" : ""}${contacto.domicilio != null ? "\n*Domicilio*: ${contacto.domicilio}" : ""}${contacto.numero != null ? "\nTelefono: ${contacto.numero}" : ""}${contacto.otroNumero != null ? "\nTelefono alt: ${contacto.otroNumero}" : ""}${contacto.nota != null ? "\n*Notas*: ${contacto.nota}" : ""}"),
                  icon: Icon(Icons.text_snippet,
                      size: 32.sp, color: ThemaMain.primary)),
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
                            nombre: "contactos", datas: [contacto]))
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
                      size: 32.sp, color: ThemaMain.green)),
              Text("Archivo",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))
            ])),
            Card(
                child: Column(children: [
              IconButton(
                  onPressed: () async {
                    WidgetsToImageController controller =
                        WidgetsToImageController();
                    showDialog(
                        context: context,
                        builder: (context) => Dialog(
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                  WidgetsToImage(
                                      controller: controller,
                                      child: TarjetaContactoDetalle(
                                          contacto: contacto, compartir: true)),
                                  ElevatedButton.icon(
                                      onPressed: () async {
                                        var file = await controller.capturePng(
                                            pixelRatio: 2);
                                        if (file != null) {
                                          var imagen = await CamaraFun.imagen(
                                              nombre: contacto.nombreCompleto ??
                                                  "Nombre: Sin nombre",
                                              imagenBytes: file);
                                          var intBool = await ShareFun.share(
                                              titulo: "Objeto de contacto",
                                              mensaje: "Tarjeta de contacto",
                                              files: [XFile(imagen!.path)]);
                                          intBool == 0
                                              ? Navigation.popTwice()
                                              : null;
                                        }
                                      },
                                      label: Text("Compartir",
                                          style: TextStyle(
                                              fontSize: 14.sp,
                                              fontWeight: FontWeight.bold)),
                                      icon: Icon(Icons.share))
                                ])));
                  },
                  icon: Icon(Icons.image, size: 32.sp, color: ThemaMain.red)),
              Text("Imagen",
                  style:
                      TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold))
            ]))
          ])
    ]));
  }
}
