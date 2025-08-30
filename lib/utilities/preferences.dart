import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _preferences;
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences? get instance => _preferences;

  static bool get thema => _preferences?.getBool('thema') ?? true;
  static set thema(bool value) => _preferences?.setBool('thema', value);

  static String get mapa => _preferences?.getString('mapa') ?? "";
  static set mapa(String value) => _preferences?.setString('mapa', value);
  static String get lada => _preferences?.getString('lada') ?? "";
  static set lada(String value) => _preferences?.setString('lada', value);
  
  static bool get version => _preferences?.getBool('version') ?? true;
  static set version(bool value) => _preferences?.setBool('version', value);
}
