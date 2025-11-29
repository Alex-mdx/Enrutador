import 'package:translator/translator.dart';

class TransFun {
  static var translator = GoogleTranslator();
  static Future<String> trad(String label) async {
    var st = await translator.translate(label, from: 'en', to: 'es');
    return st.text;
  }
}
