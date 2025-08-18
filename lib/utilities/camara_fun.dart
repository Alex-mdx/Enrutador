import 'package:advanced_media_picker/advanced_media_picker.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import 'theme/theme_color.dart';

class CamaraFun {
  static Future<List<XFile>> getGalleria(
    BuildContext context,
  ) async {
    var status = await [
      Permission.camera,
      Permission.photos,
    ].request();
    debugPrint("${status}");
    return await AdvancedMediaPicker.openPicker(
        context: context,
        isNeedVideoCamera: false,
        style: PickerStyle(
            crossAxisCount: 3,
            backgroundColor: ThemaMain.second,
            titleWidget: Text("Seleccionar imagen")),
        cameraStyle: CameraStyle(),
        allowedTypes: PickerAssetType.image,
        maxVideoDuration: 60,
        selectionLimit: 1);
  }
}
