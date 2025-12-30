import 'dart:developer';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:line_icons/line_icons.dart';

class Parser {
  static int? toInt(dynamic variableBool) {
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

  static IconData? stringToIconData(String iconString) {
    try {
      // Dividimos el string usando el delimitador
      final parts = iconString.split('_');
      if (parts.length != 2) {
        return LineIcons.question; // Retorna nulo si el formato es incorrecto
      }

      // Convertimos la primera parte (codePoint) a int
      final codePoint = int.parse(parts[0]);

      // La segunda parte es el fontFamily
      final fontFamily = parts[1];

      // Usamos el constructor de IconData para crear el objeto
      return IconData(codePoint,
          fontFamily: fontFamily, fontPackage: 'line_icons');
    } catch (e) {
      // Manejo de errores si la conversión falla
      debugPrint('Error converting string to IconData: $e');
      return LineIcons.question;
    }
  }
}
