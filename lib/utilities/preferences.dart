import 'package:shared_preferences/shared_preferences.dart';

class Preferences {
  static SharedPreferences? _preferences;
  static Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  static SharedPreferences? get instance => _preferences;

  //*Login
  static bool get login => _preferences?.getBool('login') ?? false;
  static set login(bool value) => _preferences?.setBool('login', value);

  //*Temas
  static bool get thema => _preferences?.getBool('thema') ?? true;
  static set thema(bool value) => _preferences?.setBool('thema', value);

  //*Permisos
  static bool get ubicacion => _preferences?.getBool('ubicacion') ?? false;
  static set ubicacion(bool value) => _preferences?.setBool('ubicacion', value);

  static bool get camara => _preferences?.getBool('camara') ?? false;
  static set camara(bool value) => _preferences?.setBool('camara', value);

  static bool get galeria => _preferences?.getBool('galeria') ?? false;
  static set galeria(bool value) => _preferences?.setBool('galeria', value);

  static bool get contactos => _preferences?.getBool('contactos') ?? false;
  static set contactos(bool value) => _preferences?.setBool('contactos', value);

  static bool get notificaciones =>
      _preferences?.getBool('notificaciones') ?? false;
  static set notificaciones(bool value) =>
      _preferences?.setBool('notificaciones', value);

  //*Miscelaneos
  static List<String> get tipos => _preferences?.getStringList('tipos') ?? [];
  static set tipos(List<String> value) =>
      _preferences?.setStringList('tipos', value);

  static List<String> get status => _preferences?.getStringList('status') ?? [];
  static set status(List<String> value) =>
      _preferences?.setStringList('status', value);

  static List<String> get zonas => _preferences?.getStringList('zonas') ?? [];
  static set zonas(List<String> value) =>
      _preferences?.setStringList('zonas', value);

  //*Filtros
  static int get tiposFilt => _preferences?.getInt('tiposFilt') ?? 0;
  static set tiposFilt(int value) => _preferences?.setInt('tiposFilt', value);

  static int get agruparFilt => _preferences?.getInt('agruparFilt') ?? 0;
  static set agruparFilt(int value) =>
      _preferences?.setInt('agruparFilt', value);

  static bool get ordenFilt => _preferences?.getBool('ordenFilt') ?? false;
  static set ordenFilt(bool value) => _preferences?.setBool('ordenFilt', value);

  static bool get vaciosFilt => _preferences?.getBool('vaciosFilt') ?? false;
  static set vaciosFilt(bool value) =>
      _preferences?.setBool('vaciosFilt', value);

  //*Filtro buscador enrutador
  static bool get enrutados => _preferences?.getBool('enrutados') ?? false;
  static set enrutados(bool value) => _preferences?.setBool('enrutados', value);

  static int get tipoNav => _preferences?.getInt('tipo_nav') ?? -1;
  static set tipoNav(int value) => _preferences?.setInt('tipo_nav', value);

  static bool get visitados => _preferences?.getBool('visitados') ?? false;
  static set visitados(bool value) => _preferences?.setBool('visitados', value);

  //*Preferencias
  static String get mapa => _preferences?.getString('mapa') ?? "";
  static set mapa(String value) => _preferences?.setString('mapa', value);

  static String get lada => _preferences?.getString('lada') ?? "";
  static set lada(String value) => _preferences?.setString('lada', value);

  static bool get psCodeExt => _preferences?.getBool('psCodeExt') ?? true;
  static set psCodeExt(bool value) => _preferences?.setBool('psCodeExt', value);

  static bool get autoNav => _preferences?.getBool('autoNav') ?? false;
  static set autoNav(bool value) => _preferences?.setBool('autoNav', value);

  static bool get version => _preferences?.getBool('version') ?? true;
  static set version(bool value) => _preferences?.setBool('version', value);

  static bool get grid => _preferences?.getBool('grid') ?? true;
  static set grid(bool value) => _preferences?.setBool('grid', value);
}
