import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';

class UriFun {
  static Future<void> jsonUri(Uri uriString) async {
    try {
      
      final File file = File.fromUri(uriString);
      final String jsonContent = await file.readAsString();
      print('Contenido del archivo JSON:\n$jsonContent');
      final Map<String, dynamic> jsonMap = jsonDecode(jsonContent);
      print('JSON decodificado exitosamente. Claves: ${jsonMap.keys}');
      if (jsonMap.containsKey('contacto') && jsonMap['contacto'] is List) {
        final List<dynamic> contactos = jsonMap['contacto'];
        print('Primer contacto: ${contactos}');
      }
    } catch (e) {
      debugPrint('JSON: $e');
      showToast("Error al procesar el archivo JSON");
    }
  }
}
