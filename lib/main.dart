import 'package:enrutador/utilities/main_provider.dart';
import 'package:enrutador/views/home_view.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:oktoast/oktoast.dart';
import 'package:provider/provider.dart';
import 'package:sizer/sizer.dart';
import 'utilities/apis/rutas_app.dart';
import 'utilities/preferences.dart';
import 'utilities/services/navigation_key.dart';
import 'utilities/theme/theme_app.dart';
import 'firebase_options.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) =>
      super.createHttpClient(context)
        ..badCertificateCallback =
            (X509Certificate cert, String host, int port) => true;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  HttpOverrides.global = MyHttpOverrides();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  final analitic = FirebaseAnalytics.instance;
  await analitic.logEvent(
      name: "abierto_bitch",
      parameters: {"version": "1.0.0", "platform": "android"});
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  await Preferences.init();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]).then((_) {
    runApp(MultiProvider(
        providers: [ChangeNotifierProvider(create: (_) => MainProvider())],
        child: const Main()));
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
              routes: AppRoutes.routes,
              onGenerateRoute: (settings) {
                if (settings.name == '/') {
                  return MaterialPageRoute(builder: (_) => const HomeView());
                }
                return null;
              })));
}
