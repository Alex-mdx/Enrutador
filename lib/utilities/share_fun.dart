import 'dart:convert';
import 'dart:io';

import 'package:enrutador/utilities/textos.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareFun {
  static var copiar =
      "//Ingrese este codigo en algun navegador de google para tener la ubicacion exacta";
  static Future<void> share(
      {required String titulo,
      required String mensaje,
      List<XFile>? files}) async {
    final params = ShareParams(title: titulo, text: mensaje, files: files);
    await SharePlus.instance.share(params);
  }

  static Future<List<File>> shareDatas(
      {required String nombre, required List<dynamic> datas}) async {
    showToast("Generando $nombre");
    //try {
    var chunck = 50;
    List<File> files = [];
    List<dynamic> json = [];
    for (var i = 0; i < datas.length; i++) {
      json.add(datas[i]);

      var paginado = int.tryParse((i / chunck).toString());
      final DateTime ahora = DateTime.now();
      debugPrint("$paginado");
      if (paginado != null) {
        final Map<String, dynamic> jsonMap = {
          nombre: json.map((e) => e.toJson()).toList()
        };
        final String jsonString = jsonEncode(jsonMap);
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath =
            '${tempDir.path}/${nombre}_${Textos.fechaYMD(fecha: ahora)}_${Textos.fechaHMS(fecha: ahora)}_${paginado}_${(datas.length / chunck).ceil()}.json';
        await _ensureDirectoryExists(tempDir.path);
        final File file = File(filePath);
        await file.writeAsString(jsonString);
        files.add(file);
        json.clear();
      }
      if (i == datas.length - 1) {
        final Map<String, dynamic> jsonMap = {
          nombre: json.map((e) => e.toJson()).toList()
        };
        final String jsonString = jsonEncode(jsonMap);
        final Directory tempDir = await getTemporaryDirectory();

        final String filePath =
            '${tempDir.path}/${nombre}_${Textos.fechaYMD(fecha: ahora)}_${Textos.fechaHMS(fecha: ahora)}_${(datas.length / chunck).ceil()}_${(datas.length / chunck).ceil()}.json';
        await _ensureDirectoryExists(tempDir.path);

        final File file = File(filePath);
        await file.writeAsString(jsonString);
        files.add(file);
        json.clear();
      }
    }

    return files;
    /* } catch (e) {
      debugPrint("error $e");
      showToast("error: $e");
      return [];
    } */
  }

  static Future<void> _ensureDirectoryExists(String path) async {
    try {
      final dir = Directory(path);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
        print('📂 Directorio creado: $path');
      }
    } catch (e) {
      print('❌ Error creando directorio: $e');
      rethrow;
    }
  }
}
