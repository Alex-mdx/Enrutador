import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';

import 'package:advanced_media_picker/advanced_media_picker.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:sizer/sizer.dart';
import 'theme/theme_color.dart';

class CamaraFun {
  static Future<List<XFile>> getGalleria(
      BuildContext context, String? nombre) async {
    return await AdvancedMediaPicker.openPicker(
            context: context,
            isNeedVideoCamera: false,
            style: PickerStyle(
                crossAxisCount: 4,
                backgroundColor: ThemaMain.second,
                titleWidget: Text(nombre ?? "Seleccionar imagen",
                    style: TextStyle(
                        fontSize: 16.sp, fontWeight: FontWeight.bold))),
            cameraStyle: CameraStyle(),
            fileSelectorAllowedTypes: ["png", "jpg", "jpeg"],
            allowedTypes: PickerAssetType.image,
            maxVideoDuration: 60,
            selectionLimit: 1)
        .catchError((e) {
      debugPrint("error al abrir galeria: $e");
      showToast("Error al abrir la galería");
      return <XFile>[];
    });
  }

  static Future<File?> imagen(
      {required String nombre, required Uint8List imagenBytes}) async {
    try {
      final directory = await getTemporaryDirectory();
      final nombreFoto = '$nombre.jpg';
      final filePath = path.join(directory.path, nombreFoto);
      final file = File(filePath);

      await file.writeAsBytes(imagenBytes);
      return file;
    } catch (e) {
      debugPrint("$e");
      return null;
    }
  }


  static Future<Uint8List?> getScanner() async {
    try {
      final scanner = FlutterDocScanner();
      final data =
          await scanner.getScannedDocumentAsImages(page: 1, quality: .6);

      if (data != null && data.images.isNotEmpty) {
        final imagePath = data.images.first;
        // Convertir URI (file:///...) a ruta del sistema si es necesario
        final filePath = imagePath.startsWith('file://')
            ? Uri.parse(imagePath).toFilePath()
            : imagePath;
        return await XFile(filePath).readAsBytes();
      }
    } catch (e) {
      log(e.toString());
      showToast("Error al escanear");
    }
    return null;
  }
}
