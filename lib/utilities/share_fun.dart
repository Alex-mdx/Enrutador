import 'package:share_plus/share_plus.dart';

class ShareFun {
  static Future<void> share(
      {required String titulo,
      required String mensaje, List<XFile>? files}) async {
    final params = ShareParams(title: titulo, text: mensaje,files: files);
    await SharePlus.instance.share(params);
  }
}
