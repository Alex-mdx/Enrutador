import 'package:enrutador/utilities/share_fun.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:share_plus/share_plus.dart';
import 'package:sizer/sizer.dart';

import '../../utilities/theme/theme_color.dart';

class PdfViewer extends StatelessWidget {
  final String path;
  const PdfViewer({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title:
              Text("Visualizador de PDF", style: TextStyle(fontSize: 16.sp))),
      body: PDFView(
          filePath: path,
          enableSwipe: true,
          swipeHorizontal: true,
          autoSpacing: false,
          pageFling: false,
          showScrollIndicators: true,
          backgroundColor: Colors.grey,
          onError: (error) {
            debugPrint(error.toString());
          },
          onPageError: (page, error) {
            debugPrint('$page: ${error.toString()}');
          }),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await ShareFun.share(
              titulo: "Archivo",
              mensaje: "Archivo.pdf",
              files: [
                XFile(path, name: "Archivo.pdf", mimeType: "application/pdf")
              ]);
        },
        child: Icon(Icons.share, color: ThemaMain.green, size: 20.sp),
      ),
    );
  }
}
