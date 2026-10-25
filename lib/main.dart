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

  String? errorMessage;

  try {
    // 1. Firebase
    try {
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } catch (e) {
      errorMessage = 'Firebase: $e';
    }

    // 2. FMTC (ObjectBox)
    if (errorMessage == null) {
      try {
        await FMTCObjectBoxBackend().initialise();
      } catch (e) {
        try {
          var absPath = path.join(
              (await getApplicationDocumentsDirectory()).absolute.path, 'fmtc');
          final dir = Directory(absPath);
          await dir.delete(recursive: true);
          await FMTCObjectBoxBackend()
              .initialise(); // Reintentar después de borrar
        } catch (e2) {
          errorMessage = 'FMTC: $e2';
        }
      }
    }

    // 3. Notificaciones (no crítico, si falla seguimos)
    try {
      final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
          FlutterLocalNotificationsPlugin();
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const InitializationSettings initializationSettings =
          InitializationSettings(android: initializationSettingsAndroid);

      await flutterLocalNotificationsPlugin.initialize(
          settings: initializationSettings,
          onDidReceiveNotificationResponse: (NotificationResponse response) {
            debugPrint("Notificación presionada: ${response.payload}");
          });

      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidImplementation?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Notificaciones falló (no crítico): $e');
    }

    // 4. Crashlytics
    FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

    // 5. Google Sign In
    if (errorMessage == null) {
      try {
        await GoogleSignIn.instance
            .initialize(serverClientId: Firebase.app().options.androidClientId);
      } catch (e) {
        errorMessage = 'GoogleSignIn: $e';
      }
    }

    // 6. Preferences (SharedPreferences)
    if (errorMessage == null) {
      try {
        await Preferences.init();
      } catch (e) {
        errorMessage = 'Preferences: $e';
      }
    }
  } catch (e) {
    errorMessage = 'Error general: $e';
  }

  if (errorMessage != null) {
    runApp(MaterialApp(
        home: Scaffold(
            backgroundColor: Colors.red[50],
            body: Center(
                child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text('ERROR EN INICIO:\n$errorMessage',
                        style: const TextStyle(color: Colors.red, fontSize: 16),
                        textAlign: TextAlign.center))))));
    return;
  }

  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);

  runApp(ChangeNotifierProvider(
      create: (_) => MainProvider(), child: const Main()));
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
