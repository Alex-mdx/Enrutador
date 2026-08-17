import 'dart:async';

import 'package:enrutador/utilities/main_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_map_tile_caching/flutter_map_tile_caching.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'utilities/apis/rutas_app.dart';
import 'utilities/preferences.dart';
import 'utilities/services/navigation_key.dart';
import 'utilities/theme/theme_app.dart';
import 'firebase_options.dart';

import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  try {
    await FMTCObjectBoxBackend().initialise(); // The default/built-in backend
  } catch (error) {
    var absPath = path.join(
        (await getApplicationDocumentsDirectory()).absolute.path, 'fmtc');
    debugPrint(absPath);
    final dir = Directory(absPath);

    await dir.delete(recursive: true);
  }

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Inicialización de las notificaciones locales
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        debugPrint("Notificación presionada con payload: ${response.payload}");
      });

  // Obtener implementación de Android del plugin
  final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
      flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  // Solicitar permiso de notificaciones (requerido para Android 13+)
  await androidImplementation?.requestNotificationsPermission();

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await GoogleSignIn.instance
      .initialize(serverClientId: Firebase.app().options.androidClientId);
  await Preferences.init();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    runApp(ChangeNotifierProvider(
        create: (_) => MainProvider(), child: const Main()));
  });
}

class Main extends StatelessWidget {
  const Main({super.key});

  @override
  Widget build(BuildContext context) => Sizer(
      builder: (context, orientation, deviceType) => OKToast(
          dismissOtherOnShow: true,
          position: ToastPosition.bottom,
          duration: const Duration(seconds: 4),
          backgroundColor: Preferences.thema ? Colors.black : Colors.white,
          textStyle: TextStyle(
              fontSize: 15.sp,
              color: Preferences.thema ? Colors.white : Colors.black),
          child: MaterialApp(
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate
              ],
              supportedLocales: const [
                Locale('es')
              ],
              debugShowCheckedModeBanner: false,
              title: 'Enrutador',
              themeMode: Preferences.thema ? ThemeMode.light : ThemeMode.dark,
              theme: Preferences.thema ? light : dark,
              navigatorKey: NavigationKey.navigatorKey,
              initialRoute: AppRoutes.initialRoute,
              routes: AppRoutes.routes)));
}
