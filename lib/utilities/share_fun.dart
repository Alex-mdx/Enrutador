import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:enrutador/utilities/textos.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareFun {
  static var copiar =
      "//Ingrese este codigo en algun navegador de google para tener la ubicacion exacta";
  static Future<int?> share(
      {required String? titulo,
      required String? mensaje,
      List<XFile>? files}) async {
    final params = ShareParams(
        title: titulo, text: mensaje == "" ? null : mensaje, files: files);
    var share = await SharePlus.instance.share(params);
    return share.status.index;
  }

  static Future<List<File>> shareDatas({
    String? nombre,
    List<String>? nombres,
    required dynamic datas,
  }) async {
    final List<String> keyNames =
        nombres ?? (nombre != null ? [nombre] : ["datos"]);
    final String fileName = nombre ?? "archivo";

    List<List<dynamic>> dataLists = [];
    if (datas is List) {
      for (var item in datas) {
        if (item is List) {
          dataLists.add(item.cast<dynamic>());
        } else {
          dataLists.add([item]);
        }
      }
    } else {
      dataLists = [
        [datas]
      ];
    }

    log("shareDatas -> dataLists: ${dataLists.length} listas, items por lista: ${dataLists.map((e) => e.length).toList()}");
    showToast("Generando ${keyNames.join(", ")}");

    try {
      dynamic toEncodable(dynamic e) {
        if (e == null) return null;
        if (e is Map) return e;
        if (e is List) return e.map((item) => toEncodable(item)).toList();
        try {
          return (e as dynamic).toJson();
        } catch (_) {
          return e;
        }
      }

      Map<String, dynamic> jsonMap = {};
      for (int j = 0; j < dataLists.length; j++) {
        final String key = (j < keyNames.length) ? keyNames[j] : "datos_$j";
        final list = dataLists[j];
        jsonMap[key] = list.map((e) => toEncodable(e)).toList();
      }

      final DateTime ahora = DateTime.now();
      final String jsonString = jsonEncode(jsonMap);
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/${fileName}_${Textos.fechaYMD(fecha: ahora)}_${Textos.fechaHMS(fecha: ahora)}.json';

      await _ensureDirectoryExists(tempDir.path);
      final File file = File(filePath);
      await file.writeAsString(jsonString);

      log("Archivo JSON generado exitosamente en: $filePath");

      return [file];
    } catch (e) {
      log("Error en shareDatas: $e");
      showToast("Error: $e");
      return [];
    }
  }

  static Future<void> _ensureDirectoryExists(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        debugPrint('Directorio creado: $path');
      }
    } catch (e) {
      debugPrint('EHHH, esta mal, porque vergas esta mal: $e');
      rethrow;
    }
  }
}
