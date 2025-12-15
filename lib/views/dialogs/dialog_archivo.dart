import 'dart:convert';
import 'dart:typed_data';

import 'package:enrutador/controllers/archivo_controller.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';
import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import '../../models/archivo_model.dart';
import '../../models/contacto_model.dart';
import '../../utilities/theme/theme_color.dart';

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
      IconButton.filled(
          onPressed: () async {
            var data = (await CunningDocumentScanner.getPictures(
                isGalleryImportAllowed: true,
                noOfPages: 1,
                iosScannerOptions:
                    IosScannerOptions(jpgCompressionQuality: .8)));
            if (data?.isNotEmpty ?? false) {
              XFile(data!.first);
              ArchivoModel archivo = ArchivoModel(
                  nombre: "test",
                  archivo: "",
                  contactoId: widget.contacto.id ?? -1);
            }
          },
          icon: Icon(Icons.document_scanner,
              size: 20.sp, color: ThemaMain.green)),
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
            Divider(),
            FutureBuilder(
                future: ArchivoController.getAllByContactoId(
                    widget.contacto.id ?? -1),
                builder: (BuildContext context,
                    AsyncSnapshot<List<ArchivoModel>> snapshot) {
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
                    return ListView.builder(
                        shrinkWrap: true,
                        physics:
                            const NeverScrollableScrollPhysics(), // Para que no haya scroll anidado
                        itemCount: archivos.length,
                        itemBuilder: (context, index) {
                          final ArchivoModel archivo = archivos[index];
                          // Asumiendo que ArchivoModel tiene un campo 'contenidoBase64' y 'nombre'
                          if (archivo.archivo != null &&
                              archivo.archivo!.isNotEmpty) {
                            try {
                              final Uint8List imageBytes =
                                  base64Decode(archivo.archivo!);
                              return Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                                archivo.nombre ??
                                                    'Archivo sin nombre',
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14.sp)),
                                            Image.memory(imageBytes,
                                                fit: BoxFit.cover,
                                                width: double.infinity,
                                                height: 200)
                                          ])));
                            } catch (e) {
                              return Card(
                                  child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          'Error al decodificar imagen para ${archivo.nombre ?? "un archivo"}.')));
                            }
                          } else {
                            return Card(
                                child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                        'El archivo ${archivo.nombre ?? "sin nombre"} no tiene contenido válido.')));
                          }
                        });
                  }
                })
          ]))
    ]));
  }
}
