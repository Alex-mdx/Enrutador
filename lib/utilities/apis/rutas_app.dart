import 'package:enrutador/utilities/preferences.dart';
import 'package:enrutador/views/contactos_view.dart';
import 'package:enrutador/views/estado_view.dart';
import 'package:enrutador/views/lada_view.dart';
import 'package:enrutador/views/login_view.dart';
import 'package:enrutador/views/navegar_view.dart';
import 'package:enrutador/views/pendientes_home.dart';
import 'package:enrutador/views/regiones_mapa.dart';
import 'package:enrutador/views/tipos_view.dart';
import 'package:enrutador/views/widgets/extras/notas_builder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../views/account_view.dart';
import '../../views/home_view.dart';
import '../../views/roles_view.dart';

class AppRoutes {
  static String initialRoute =
      (FirebaseAuth.instance.currentUser?.emailVerified == false &&
                  !Preferences.login) ||
              (FirebaseAuth.instance.currentUser?.emailVerified == true &&
                  !Preferences.login)
          ? 'account'
          : FirebaseAuth.instance.currentUser == null
              ? 'loginState'
              : 'home';

  static final Map<String, Widget Function(BuildContext)> _routes = {
    home: (_) => const HomeView(),
    tipos: (_) => const TiposView(),
    estatus: (_) => const EstadoView(),
    contacto: (_) => const ContactosView(),
    navegar: (_) => const NavegarView(),
    lada: (_) => const LadaView(),
    roles: (_) => const RolesView(),
    loginState: (_) => const LoginView(),
    account: (_) => const AccountView(),
    regionesMapa: (_) => const RegionesMapa(),
    pendientes: (_) => const PendientesHome(),
    notasBuilder: (_) => const NotasBuilder()
  };
  static Map<String, Widget Function(BuildContext)> get routes => _routes;
  static String get home => 'home';
  static String get tipos => 'tipos';
  static String get contacto => 'contactos';
  static String get navegar => 'navegar';
  static String get lada => 'lada';
  static String get estatus => 'estatus';
  static String get roles => 'roles';
  static String get loginState => 'loginState';
  static String get account => 'account';
  static String get regionesMapa => 'regionesMapa';
  static String get pendientes => 'pendientes';
  static String get notasBuilder => 'notasBuilder';
}
