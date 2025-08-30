import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class UriFun {
  static const _channel =
      MethodChannel('com.example.enrutador/content_uri_reader');

  static Future<String?> readContentUriSafe(String uriString) async {
    try {
      // Paso 1: Obtener tamaño
      final fileSize = await _getFileSizeSafe(uriString);
      if (fileSize > 100 * 1024 * 1024) return null;

      // Paso 2: Leer contenido
      final content = await _getContentSafe(uriString);
      if (content == null) return null;

      // Paso 3: Parsear JSON
      return _parseJsonSafe(content);
    } catch (e) {
      debugPrint('❌ Error seguro: $e');
      return null;
    }
  }

  static Future<int> _getFileSizeSafe(String uriString) async {
    try {
      final result =
          await _channel.invokeMethod<int>('getFileSize', {'uri': uriString});
      return result ?? 0;
    } catch (e) {
      debugPrint("$e");
      return 0;
    }
  }

  static Future<String?> _getContentSafe(String uriString) async {
    try {
      final result = await _channel
          .invokeMethod<String>('readContentUri', {'uri': uriString});
      return result;
    } catch (e) {
      return null;
    }
  }

  static String? _parseJsonSafe(String content) {
    debugPrint("datas $content");
    try {
      return content;
    } catch (e) {
      debugPrint("$e");
      return null;
    }
  }
}
