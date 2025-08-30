import 'package:enrutador/views/contactos_view.dart';
import 'package:enrutador/views/lada_view.dart';
import 'package:enrutador/views/navegar_view.dart';
import 'package:enrutador/views/tipos_view.dart';
import 'package:flutter/material.dart';
import '../../views/home_view.dart';

class AppRoutes {
  static const String initialRoute = 'home';

  static final Map<String, Widget Function(BuildContext)> _routes = {
    home: (_) => const HomeView(),
    tipos: (_) => const TiposView(),
    contacto: (_) => const ContactosView(),
    navegar: (_) => const NavegarView(),
    lada: (_) => const LadaView()
  };
  static get routes => _routes;
  static String get home => 'home';
  static String get tipos => 'tipos';
  static String get contacto => 'contactos';
  static String get navegar => 'navegar';
  static String get lada => 'lada';
}
