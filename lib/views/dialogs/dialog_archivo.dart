import 'dart:convert';

import 'package:enrutador/controllers/archivo_controller.dart';
import 'package:enrutador/utilities/services/dialog_services.dart';
import 'package:enrutador/utilities/services/navigation_services.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:enrutador/views/widgets/visualizador_widget.dart';
import 'package:flutter/material.dart';
import 'package:badges/badges.dart' as bd;
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
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
            var data = (await CunningDocumentScanner.getPictures(
                isGalleryImportAllowed: true,
                noOfPages: 1,
                iosScannerOptions:
                    IosScannerOptions(jpgCompressionQuality: 1)));
            if (data?.isNotEmpty ?? false) {
              var archivoTemp = XFile(data!.first);
              var base = base64Encode(await archivoTemp.readAsBytes());
              ArchivoModel archivo = ArchivoModel(
                  nombre: "test",
                  archivo: base,
                  contactoId: widget.contacto.id ?? -1);
              await ArchivoController.insert(archivo);
              setState(() {});
            }
          },
          label: Text("Agregar archivo", style: TextStyle(fontSize: 16.sp)),
          icon: Icon(Icons.document_scanner,
              size: 20.sp, color: ThemaMain.primary)),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Divider(),
            FutureBuilder(
                future: ArchivoController.getAllByContactoId(
                    widget.contacto.id ?? -1),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                        child: Text(
                            'Error al cargar archivos: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(
                        child: Text(
                            'No hay archivos adjuntos para este contacto.'));
                  } else {
                    final List<ArchivoModel> archivos = snapshot.data!;
                    return Scrollbar(
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
                                            }),
                                        badgeContent: Icon(Icons.delete,
                                            size: 15.sp,
                                            color: ThemaMain.dialogbackground),
                                        badgeStyle: bd.BadgeStyle(
                                            badgeColor: ThemaMain.red),
                                        child: GaleriaWidget(
                                            image64: archivo.archivo,
                                            ontap: () => showDialog(
                                                context: context,
                                                builder: (context) =>
                                                    VisualizadorWidget(
                                                        image64:
                                                            archivo.archivo,
                                                        carrusel:
                                                            "Fecha Creacion: ${Textos.fechaYMDHMS(fecha: archivo.actualizacion!)}")),
                                            onDoubleTap: () async {
                                              var data =
                                                  (await CunningDocumentScanner
                                                      .getPictures(
                                                          isGalleryImportAllowed:
                                                              true,
                                                          noOfPages: 1,
                                                          iosScannerOptions:
                                                              IosScannerOptions(
                                                                  jpgCompressionQuality:
                                                                      1)));
                                              if (data?.isNotEmpty ?? false) {
                                                var archivoTemp =
                                                    XFile(data!.first);
                                                var base = base64Encode(
                                                    await archivoTemp
                                                        .readAsBytes());
                                                ArchivoModel archivoNew =
                                                    archivo.copyWith(
                                                        archivo: base,
                                                        actualizacion:
                                                            DateTime.now());
                                                ArchivoModel(
                                                    nombre: "test",
                                                    archivo: base,
                                                    contactoId:
                                                        widget.contacto.id ??
                                                            -1);
                                                await ArchivoController.update(
                                                    archivoNew);
                                                setState(() {});
                                              }
                                            },
                                            compartir: false,
                                            minFit: 16.w))
                                ])));
                  }
                })
          ])),
      ElevatedButton.icon(
          onPressed: () => Navigation.pop(),
          icon: Icon(Icons.close, color: ThemaMain.red, size: 20.sp),
          label: Text("Cerrar", style: TextStyle(fontSize: 16.sp)))
    ]));
  }
}
