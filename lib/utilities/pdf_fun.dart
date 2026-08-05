import 'dart:io';

import 'package:enrutador/controllers/tipo_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/number_fun.dart';
import 'package:enrutador/utilities/textos.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sizer/sizer.dart';

import '../controllers/estado_controller.dart';

class PDFFun {
  Future<File> buildReporteVentas(
      {required String titular,
      required List<ContactoModelo> contactos}) async {
    var tipos = await TipoController.getItems();
    var estados = await EstadoController.getItems();
    final pdf = pw.Document();
    pdf.addPage(pw.Page(
        pageFormat: PdfPageFormat.a4,
        orientation: pw.PageOrientation.landscape,
        build: (context) => pw.Column(children: [
              pw.Text("Reporte de ventas",
                  style: pw.TextStyle(
                      fontSize: 24.sp, fontWeight: pw.FontWeight.bold)),
              pw.Table(border: pw.TableBorder.all(), children: [
                pw.TableRow(children: [
                  pw.Text("Nombre"),
                  pw.Text("Teléfono"),
                  pw.Text("Tipo"),
                  pw.Text("Estado"),
                  pw.Text("Tip")
                ]),
                ...contactos.map((e) => pw.TableRow(children: [
                      pw.Text(e.nombreCompleto!),
                      pw.Text(
                          NumberFun.formatNumberWithLada(
                              "${e.numero ?? "-1"}")),
                      pw.Text(
                          tipos.firstWhereOrNull(
                                  (element) => element.id == e.tipo)
                              ?.nombre ??
                              ""),
                      pw.Text(
                          estados.firstWhereOrNull(
                                  (element) => element.id == e.estado)
                              ?.nombre ??
                              "")
                    ]))
              ])
            ])));
    var savedFile = await pdf.save();
    Directory documentDirectory = await getApplicationDocumentsDirectory();
    String savePath = "${documentDirectory.path}/$titular.pdf";
    final file = File(savePath);
    await file.writeAsBytes(savedFile);
    return file;
  }
}
