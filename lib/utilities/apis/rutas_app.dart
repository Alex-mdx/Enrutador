import 'package:flutter/material.dart';
import '../../views/home_view.dart';

class AppRoutes {
  static const String initialRoute = 'home';

  static final Map<String, Widget Function(BuildContext)> _routes = {
    home: (_) => const HomeView()
  };
  static get routes => _routes;
  static String get home => 'home';
  static String get opciones => 'opciones';
}
