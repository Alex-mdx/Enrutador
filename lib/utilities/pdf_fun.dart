import 'dart:io';

import 'package:enrutador/controllers/tipo_controller.dart';
import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/usuario_model.dart';
import 'package:enrutador/utilities/number_fun.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:get/get.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:sizer/sizer.dart';

import '../controllers/estado_controller.dart';

class PDFFun {
  static Future<File?> buildReporteVentas(
      {required String titular,
      required List<ContactoModelo> contactos,
      required UsuarioModel user}) async {
    try {
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
                pw.Table(
                    border: pw.TableBorder.symmetric(
                        outside: pw.BorderSide(), inside: pw.BorderSide.none),
                    children: [
                      pw.TableRow(
                          decoration: pw.BoxDecoration(
                              border: pw.Border(bottom: pw.BorderSide())),
                          children: [
                            pw.Text("Usuario",
                                textAlign: pw.TextAlign.center,
                                tightBounds: true,
                                style: pw.TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text("Nombre",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text("Teléfono",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text("Tipo",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text("Estado",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: pw.FontWeight.bold)),
                            pw.Text("Tip",
                                textAlign: pw.TextAlign.center,
                                style: pw.TextStyle(
                                    fontSize: 15.sp,
                                    fontWeight: pw.FontWeight.bold))
                          ]),
                      ...contactos.asMap().entries.map((entry) {
                        final index = entry.key;
                        final e = entry.value;

                        // Helper para envolver celdas en un Container con borde dashed inferior
                        pw.Widget cell(pw.Widget child,
                            {bool hasBorder = true, double? minWith}) {
                          return pw.Container(
                              width: minWith,
                              padding:
                                  const pw.EdgeInsets.symmetric(vertical: 4),
                              decoration: hasBorder
                                  ? const pw.BoxDecoration(
                                      border: pw.Border(
                                          top: pw.BorderSide(
                                              style: pw.BorderStyle.dashed,
                                              width: 0.5)))
                                  : null,
                              child: child);
                        }

                        return pw.TableRow(children: [
                          cell(
                              pw.Text(
                                  index == 0
                                      ? "${user.nombre ?? "Sin Nombre"}\n${user.empleadoId}"
                                      : "",
                                  style: pw.TextStyle(
                                      fontSize: 13.sp,
                                      fontWeight: pw.FontWeight.bold),
                                  tightBounds: true),
                              hasBorder: false,
                              minWith: 25.w),
                          cell(
                              pw.Text(
                                  "${e.nombreCompleto ?? "Sin nombre"}\n${e.domicilio ?? "Sin Domicilio"}",
                                  style: pw.TextStyle(
                                      fontSize: 14.sp,
                                      fontStyle: e.nombreCompleto != null
                                          ? pw.FontStyle.italic
                                          : null)),
                              minWith: 35.w),
                          cell(e.numero != null && e.numero != -1
                              ? pw.Text(
                                  NumberFun.formatNumberWithLadaAndParentheses(
                                      "${e.numero}"),
                                  style: pw.TextStyle(fontSize: 13.sp))
                              : pw.Text("Sin numero",
                                  style: pw.TextStyle(
                                      fontSize: 13.sp,
                                      fontStyle:
                                          e.numero != null && e.numero != -1
                                              ? null
                                              : pw.FontStyle.italic))),
                          cell(pw.Text(
                              tipos
                                      .firstWhereOrNull(
                                          (element) => element.id == e.tipo)
                                      ?.nombre ??
                                  "Tipo no asignado",
                              style: pw.TextStyle(
                                  fontSize: 13.sp,
                                  decoration: e.tipo != null && e.tipo != -1
                                      ? pw.TextDecoration.underline
                                      : null,
                                  decorationThickness: 5.sp,
                                  decorationColor: PdfColor.fromInt(
                                      (tipos.firstWhereOrNull((element) => element.id == e.tipo)?.color ??
                                              ThemaMain.primary)
                                          .toARGB32()),
                                  fontStyle: e.tipo != null && e.tipo != -1
                                      ? null
                                      : pw.FontStyle.italic))),
                          cell(pw.Text(
                              estados
                                      .firstWhereOrNull(
                                          (element) => element.id == e.estado)
                                      ?.nombre ??
                                  "Estado no asignado",
                              style: pw.TextStyle(
                                  fontSize: 13.sp,
                                  decoration: e.estado != null && e.estado != -1
                                      ? pw.TextDecoration.underline
                                      : null,
                                  decorationThickness: 5.sp,
                                  decorationColor: PdfColor.fromInt(
                                      (estados.firstWhereOrNull((element) => element.id == e.estado)?.color ??
                                              ThemaMain.primary)
                                          .toARGB32()),
                                  fontStyle: e.estado != null && e.estado != -1
                                      ? null
                                      : pw.FontStyle.italic))),
                          cell(
                              pw.Text("", style: pw.TextStyle(fontSize: 13.sp)))
                        ]);
                      })
                    ])
              ])));
      var savedFile = await pdf.save();
      Directory documentDirectory = await getApplicationDocumentsDirectory();
      String savePath = "${documentDirectory.path}/$titular.pdf";
      final file = File(savePath);
      await file.writeAsBytes(savedFile);
      return file;
    } catch (e) {
      showToast("Error: $e");
      return null;
    }
  }
}
