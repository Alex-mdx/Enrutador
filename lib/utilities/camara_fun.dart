import 'dart:developer';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter_barcode_scanner_plus/flutter_barcode_scanner_plus.dart';
import 'package:flutter_doc_scanner/flutter_doc_scanner.dart';
import 'package:flutter/material.dart';
import 'package:insta_assets_picker/insta_assets_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:sizer/sizer.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class CamaraFun {
  static Future<List<XFile>> getGalleria(
      BuildContext context, String? nombre) async {
    try {
      List<XFile> cameraFiles = [];

      final dynamic result = await InstaAssetPicker.pickAssets(context,
          requestType: RequestType.image,
          pickerConfig: InstaAssetPickerConfig(
              title: nombre,
              specialItemPosition: SpecialItemPosition.prepend,
              specialItemBuilder: (context, p, length) {
                if (p?.isAll != true) {
                  return const SizedBox.shrink();
                }

                return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () async {
                      final image = await ImagePicker().pickImage(
                          source: ImageSource.camera,
                          requestFullMetadata: false);

                      if (image != null) {
                        final directory = await getTemporaryDirectory();
                        final targetPath = path.join(directory.path,
                            'cam_${DateTime.now().millisecondsSinceEpoch}.jpg');
                        final savedFile =
                            await File(image.path).copy(targetPath);
                        cameraFiles = [XFile(savedFile.path)];

                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      }
                    },
                    child: Center(child: Icon(Icons.camera_alt, size: 24.w)));
              },
              closeOnComplete: true,
              textDelegate: EnglishAssetPickerTextDelegate()),
          maxAssets: 1,
          onCompleted: (exportDetails) =>
              showToast("Se ha importado el archivo"));

      if (cameraFiles.isNotEmpty) {
        return cameraFiles;
      }

      List<XFile> xFiles = [];
      if (result != null && result is List && result.isNotEmpty) {
        final item = result.first;
        if (item is XFile) {
          xFiles.add(item);
        } else if (item is AssetEntity) {
          final file = await item.file;
          if (file != null) {
            xFiles.add(XFile(file.path));
          }
        }
      }

      return xFiles;
    } catch (e) {
      debugPrint("error al abrir galeria: $e");
      showToast("Error al abrir la galería");
      return <XFile>[];
    }
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

  static Future<String?> scanQr() async {
    try {
      var barcode = await FlutterBarcodeScanner.scanBarcode(
          "#ff6666", "Cancelar", false, ScanMode.QR);
      if (barcode != "-1") {
        return barcode;
      }
      return null;
    } catch (e) {
      log(e.toString());
      showToast("Error al escanear");
    }
    return null;
  }
}
