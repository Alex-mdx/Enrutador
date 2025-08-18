import 'dart:convert';
import 'dart:io';

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

  static Future<File?> shareDatas(
      {required String nombre, required List<dynamic> datas}) async {
    showToast("Generando $nombre");
    try {
      final Map<String, dynamic> jsonMap = {
        nombre: datas.map((e) => e.toJson()).toList()
      };

      final String jsonString = jsonEncode(jsonMap);

      // 3. Obtiene el directorio temporal del sistema.
      // getTemporaryDirectory() nos da una ruta segura para guardar archivos temporales.
      final Directory tempDir = await getTemporaryDirectory();
      final String tempPath = tempDir.path;
      final String filePath = '$tempPath/$nombre.json';

      // 5. Guarda la cadena JSON en el archivo.
      final File file = File(filePath);
      var data = await file.writeAsString(jsonString);
      return data;
    } catch (e) {
      showToast("error: $e");
      return null;
    }
  }
}
