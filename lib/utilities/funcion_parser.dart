import 'dart:developer';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class Parser {
  static int? toInt(var variableBool) {
    if (variableBool != null) {
      int parseo = variableBool == true
          ? 1
          : variableBool == false
              ? 0
              : variableBool;
      return parseo;
    }
    return null;
  }

  static Uint8List? toUint8List(String? byte8list) {
    if (byte8list != null &&
        byte8list != "null" &&
        byte8list != "" &&
        byte8list != "[]") {
      byte8list = byte8list.replaceAll("[", "").replaceAll("]", "");

      List<String> stringValues = byte8list.split(", ");

      Uint8List uint8List =
          Uint8List.fromList(stringValues.map(int.parse).toList());
      return uint8List;
    } else {
      return null;
    }
  }

  static Uint8List? reducirUint8List(
      {required Uint8List imgBytes, int? relacion, int? calidad}) {
    try {
      final img.Image image = img.decodeImage(imgBytes)!;

      final img.Image resizedImage = img.copyResize(image,
          width: relacion == null
              ? image.width
              : (image.width * (relacion / 100)).toInt(),
          height: relacion == null
              ? image.height
              : (image.height * (relacion / 100)).toInt());

      // Codificar la imagen redimensionada a un nuevo array de bytes
      final Uint8List newImgBytes =
          img.encodeJpg(resizedImage, quality: calidad ?? 100);

      // Guardar o utilizar los nuevos bytes de la imagen
      return newImgBytes;
    } catch (e) {
      log('error: $e');
      return null;
    }
  }
}
