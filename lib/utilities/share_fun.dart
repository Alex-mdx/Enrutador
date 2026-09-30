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
    String? name,
    String? nombre,
    List<String>? nombres,
    required dynamic datas,
  }) async {
    final List<String> keyNames =
        nombres ?? (nombre != null ? [nombre] : ["datos"]);
    final String fileName = name ?? (nombre ?? "export");

    List<List<dynamic>> dataLists = [];
    if (datas is List) {
      if (datas.isNotEmpty && datas.first is List) {
        dataLists = datas.map((e) => (e as List).cast<dynamic>()).toList();
      } else {
        dataLists = [datas.cast<dynamic>()];
      }
    }

    showToast("Generando ${keyNames.join(", ")}");
    try {
      const int chunkLimit = 50;
      List<File> files = [];

      int totalSum = 0;
      for (var list in dataLists) {
        totalSum += list.length;
      }
      if (totalSum == 0) return [];

      int totalChunks = (totalSum / chunkLimit).ceil();
      List<int> pointers = List<int>.filled(dataLists.length, 0);

      bool hasMoreData() {
        for (int j = 0; j < dataLists.length; j++) {
          if (pointers[j] < dataLists[j].length) return true;
        }
        return false;
      }

      int chunkIndex = 1;

      while (hasMoreData()) {
        final DateTime ahora = DateTime.now();
        Map<String, dynamic> jsonMap = {};
        int currentFileCount = 0;

        for (int j = 0; j < keyNames.length; j++) {
          if (j >= dataLists.length) {
            jsonMap[keyNames[j]] = [];
            continue;
          }

          final list = dataLists[j];
          int pointer = pointers[j];
          int spaceLeft = chunkLimit - currentFileCount;

          if (spaceLeft > 0 && pointer < list.length) {
            int available = list.length - pointer;
            int take = (available < spaceLeft) ? available : spaceLeft;
            final sublist = list.sublist(pointer, pointer + take);
            jsonMap[keyNames[j]] =
                sublist.map((e) => e is Map ? e : e.toJson()).toList();
            pointers[j] += take;
            currentFileCount += take;
          } else {
            jsonMap[keyNames[j]] = [];
          }
        }

        final String jsonString = jsonEncode(jsonMap);
        final Directory tempDir = await getTemporaryDirectory();
        final String filePath =
            '${tempDir.path}/${fileName}_${Textos.fechaYMD(fecha: ahora)}_${Textos.fechaHMS(fecha: ahora)}_${chunkIndex}_$totalChunks.json';
        await _ensureDirectoryExists(tempDir.path);
        final File file = File(filePath);
        await file.writeAsString(jsonString);
        files.add(file);
        chunkIndex++;
      }

      return files;
    } catch (e) {
      debugPrint("error $e");
      showToast("error: $e");
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
