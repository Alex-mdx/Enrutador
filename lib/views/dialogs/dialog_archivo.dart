import 'dart:convert';
import 'dart:io';

import 'package:enrutador/controllers/archivo_controller.dart';
import 'package:enrutador/utilities/camara_fun.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/share_fun.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/utilities/theme/theme_app.dart';
import 'package:enrutador/views/widgets/visualizador_widget.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as bd;
import 'package:get/get.dart';
import 'package:line_icons/line_icons.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:oktoast/oktoast.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import '../../models/archivo_model.dart';
import '../../models/contacto_model.dart';
import '../../utilities/theme/theme_color.dart';
import '../widgets/galeria_widget.dart';

class DialogArchivo extends StatefulWidget {
  final ContactoModelo contacto;
  const DialogArchivo({super.key, required this.contacto});

  @override
  State<DialogArchivo> createState() => _DialogArchivoState();
}

class _DialogArchivoState extends State<DialogArchivo> {
  bool carga = false;
  List<int> share = [];
  List<ArchivoModel> archivos = [];
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setState(() => carga = true);
    archivos =
        await ArchivoController.getAllByContactoId(widget.contacto.id ?? -1);
    setState(() => carga = false);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text("Archivero del contacto", style: TextStyle(fontSize: 16.sp)),
      Text(
          "Agrega la documentacion del contacto necesaria, como INE, Recibo de Luz, respaldo del contrato, etc.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
      ElevatedButton.icon(
          onPressed: () async {
            if (archivos.length >= 6) {
              showToast(
                  "Se alcanzo el limite de archivos permitidos por contacto");
              return;
            }
            var data = await CamaraFun.scanner();
            if (data != null) {
              var base = base64Encode(data);
              ArchivoModel archivo = ArchivoModel(
                  nombre: "test",
                  archivo: base,
                  contactoId: widget.contacto.id ?? -1);
              await ArchivoController.insert(archivo);
              await init();
              setState(() {});
            }
          },
          label: Text("Agregar archivo", style: TextStyle(fontSize: 16.sp)),
          icon: Icon(Icons.document_scanner,
              size: 20.sp, color: ThemaMain.primary)),
      Text("${archivos.length}/6",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold)),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Divider(),
            if (carga)
              Center(
                  child: LoadingAnimationWidget.progressiveDots(
                      color: ThemaMain.primary, size: 24.sp))
            else if (archivos.isEmpty)
              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Icon(LineIcons.alternateFileAlt,
                    size: 22.sp, color: ThemaMain.pink),
                Text('No hay archivos adjuntos para este contacto',
                    style:
                        TextStyle(fontSize: 15.sp, fontStyle: FontStyle.italic))
              ])
            else
              Scrollbar(
                  child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                          mainAxisSize: MainAxisSize.max,
                          spacing: .5.w,
                          children: [
                            for (var archivo in archivos)
                              bd.Badge(
                                  onTap: () async => Dialogs.showMorph(
                                      title: "Eliminar archivo",
                                      description:
                                          "¿Estas seguro de eliminar el archivo?",
                                      loadingTitle: "Eliminando archivo",
                                      onAcceptPressed: (context) async {
                                        await ArchivoController.delete(
                                            archivo.id ?? -1);
                                        await init();
                                      }),
                                  badgeContent: Icon(Icons.delete,
                                      size: 15.sp,
                                      color: ThemaMain.dialogbackground),
                                  badgeStyle:
                                      bd.BadgeStyle(badgeColor: ThemaMain.red),
                                  child: Container(
                                      decoration: share.firstWhereOrNull(
                                                  (e) => e == archivo.id) !=
                                              null
                                          ? BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      borderRadius),
                                              border: Border.all(
                                                  color: ThemaMain.green,
                                                  width: 1.w))
                                          : null,
                                      child: GaleriaWidget(
                                          onLongPress: () {
                                            debugPrint(
                                                "share: ${share.firstWhereOrNull((e) => e == archivo.id) != null}");
                                            setState(() {
                                              if (share.firstWhereOrNull(
                                                      (e) => e == archivo.id) !=
                                                  null) {
                                                share.remove(archivo.id!);
                                                showToast("Archivo removido");
                                              } else {
                                                share.add(archivo.id!);
                                                showToast("Archivo agregado");
                                              }
                                            });
                                          },
                                          image64: archivo.archivo,
                                          ontap: () => showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  VisualizadorWidget(
                                                      image64: archivo.archivo,
                                                      carrusel:
                                                          "Fecha Creacion: ${Textos.fechaYMDHMS(fecha: archivo.actualizacion!)}")),
                                          onDoubleTap: () async {
                                            var data =
                                                await CamaraFun.scanner();
                                            if (data != null) {
                                              var base = base64Encode(data);
                                              ArchivoModel archivoNew =
                                                  archivo.copyWith(
                                                      archivo: base,
                                                      actualizacion:
                                                          DateTime.now());
                                              ArchivoModel(
                                                  nombre: "test",
                                                  archivo: base,
                                                  contactoId:
                                                      widget.contacto.id ?? -1);
                                              await ArchivoController.update(
                                                  archivoNew);
                                              await init();
                                            }
                                          },
                                          compartir: false,
                                          minFit: 17.w)))
                          ])))
          ])),
      if (share.isNotEmpty)
        IconButton.filled(
            onPressed: () async {
              List<File> imagenBytes = [];
              for (var element in share) {
                var value = (await ArchivoController.getId(element))!.archivo;
                var file = await CamaraFun.imagen(
                    nombre: "", imagenBytes: base64Decode(value!));
                imagenBytes.add(file!);
              }

              await ShareFun.share(
                  titulo: "Archivos",
                  mensaje: "T",
                  files: imagenBytes.map((e) => XFile(e.path)).toList());
            },
            icon: Icon(Icons.share, color: ThemaMain.background, size: 24.sp)),
      ElevatedButton.icon(
          onPressed: () => Navigation.pop(),
          icon: Icon(Icons.close, color: ThemaMain.red, size: 20.sp),
          label: Text("Cerrar", style: TextStyle(fontSize: 16.sp)))
    ]));
  }
}
