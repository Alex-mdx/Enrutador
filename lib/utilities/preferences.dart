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

  static bool get enrutados => _preferences?.getBool('enrutados') ?? false;
  static set enrutados(bool value) => _preferences?.setBool('enrutados', value);
  static bool get psCodeExt => _preferences?.getBool('psCodeExt') ?? true;
  static set psCodeExt(bool value) => _preferences?.setBool('psCodeExt', value);

  static bool get autoNav => _preferences?.getBool('autoNav') ?? false;
  static set autoNav(bool value) => _preferences?.setBool('autoNav', value);

  static int get tipoNav => _preferences?.getInt('tiposFilt') ?? -1;
  static set tipoNav(int value) => _preferences?.setInt('tiposFilt', value);

  static bool get grid => _preferences?.getBool('grid') ?? true;
  static set grid(bool value) => _preferences?.setBool('grid', value);

  static List<String> get tipos => _preferences?.getStringList('tipos') ?? [];
  static set tipos(List<String> value) =>
      _preferences?.setStringList('tipos', value);

  static List<String> get status => _preferences?.getStringList('status') ?? [];
  static set status(List<String> value) =>
      _preferences?.setStringList('status', value);

  static List<String> get zonas => _preferences?.getStringList('zonas') ?? [];
  static set zonas(List<String> value) =>
      _preferences?.setStringList('zonas', value);

  static int get tiposFilt => _preferences?.getInt('tiposFilt') ?? 0;
  static set tiposFilt(int value) => _preferences?.setInt('tiposFilt', value);

  static int get agruparFilt => _preferences?.getInt('agruparFilt') ?? 0;
  static set agruparFilt(int value) => _preferences?.setInt('agruparFilt', value);

  static bool get ordenFilt => _preferences?.getBool('ordenFilt') ?? false;
  static set ordenFilt(bool value) =>
      _preferences?.setBool('ordenFilt', value);

      static bool get vaciosFilt => _preferences?.getBool('vaciosFilt') ?? false;
  static set vaciosFilt(bool value) =>
      _preferences?.setBool('vaciosFilt', value);

      static bool get visitados => _preferences?.getBool('visitados') ?? false;
  static set visitados(bool value) =>
      _preferences?.setBool('visitados', value);
}
