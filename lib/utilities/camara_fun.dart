import 'dart:io';
import 'dart:typed_data';

import 'package:advanced_media_picker/advanced_media_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as path;
import 'package:sizer/sizer.dart';
import 'theme/theme_color.dart';

class CamaraFun {
  static Future<List<XFile>> getGalleria(
      BuildContext context, String? nombre) async {
    var status = await [Permission.camera, Permission.photos].request();
    debugPrint("$status");
    return await AdvancedMediaPicker.openPicker(
        context: context,
        isNeedVideoCamera: false,
        style: PickerStyle(
            crossAxisCount: 4,
            backgroundColor: ThemaMain.second,
            titleWidget: Text(nombre ?? "Seleccionar imagen",style: TextStyle(fontSize: 16.sp),)),
        cameraStyle: CameraStyle(),
        allowedTypes: PickerAssetType.image,
        maxVideoDuration: 60,
        selectionLimit: 1);
  }

  static Future<File?> imagen(
      {required String nombre, required Uint8List imagenBytes}) async {
    try {
      final directory = await getTemporaryDirectory();
      final nombre = 'nombre.png';
      final filePath = path.join(directory.path, nombre);
      final file = File(filePath);

      await file.writeAsBytes(imagenBytes);
      return file;
    } catch (e) {
      debugPrint("$e");
      return null;
    }
  }
}
