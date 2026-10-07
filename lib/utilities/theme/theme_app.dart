import 'package:flutter/material.dart';
import 'package:material_color_utilities/material_color_utilities.dart';
import 'package:sizer/sizer.dart';
import 'theme_color.dart';

const double borderRadius = 24.0;

/// Genera un [ColorScheme] usando la paleta dinámica expresiva de Material 3 Expressive
/// de [material_color_utilities], adaptándolo y respetando la paleta de colores del proyecto.
ColorScheme _buildExpressiveColorScheme({
  required Color seedColor,
  required bool isDark,
  required Color primaryColor,
  required Color secondaryColor,
  required Color backgroundColor,
  required Color dialogBackgroundColor,
  required Color textColor,
  required Color errorColor,
  required Color darkBlueColor,
}) {
  final hct = Hct.fromInt(seedColor.toARGB32());
  final expressiveScheme = SchemeExpressive(
    sourceColorHct: hct,
    isDark: isDark,
    contrastLevel: 0.0,
  );

  final baseScheme =
      isDark ? const ColorScheme.dark() : const ColorScheme.light();

  return baseScheme.copyWith(
    primary: primaryColor,
    onPrimary: isDark ? DarkTheme.second : LightTheme.second,
    primaryContainer: darkBlueColor,
    onPrimaryContainer: isDark ? DarkTheme.second : LightTheme.second,
    secondary: secondaryColor,
    onSecondary: isDark ? DarkTheme.second : LightTheme.second,
    secondaryContainer: dialogBackgroundColor,
    onSecondaryContainer: isDark ? DarkTheme.darkGrey : LightTheme.darkBlue,
    tertiary: Color(expressiveScheme.tertiary),
    onTertiary: Color(expressiveScheme.onTertiary),
    tertiaryContainer: Color(expressiveScheme.tertiaryContainer),
    onTertiaryContainer: Color(expressiveScheme.onTertiaryContainer),
    error: errorColor,
    onError: Colors.white,
    errorContainer: Color(expressiveScheme.errorContainer),
    onErrorContainer: Color(expressiveScheme.onErrorContainer),
    surface: secondaryColor,
    onSurface: textColor,
    surfaceContainerHighest: dialogBackgroundColor,
    onSurfaceVariant: isDark ? DarkTheme.darkGrey : LightTheme.darkGrey,
    outline: isDark ? DarkTheme.grey : LightTheme.grey,
    outlineVariant: isDark ? DarkTheme.darkGrey : LightTheme.darkGrey,
    shadow: Color(expressiveScheme.shadow),
    scrim: Color(expressiveScheme.scrim),
    inverseSurface: Color(expressiveScheme.inverseSurface),
    onInverseSurface: isDark ? LightTheme.second : DarkTheme.second,
    inversePrimary: Color(expressiveScheme.inversePrimary),
  );
}

ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: _buildExpressiveColorScheme(
        seedColor: LightTheme.primary,
        isDark: false,
        primaryColor: LightTheme.primary,
        secondaryColor: LightTheme.second,
        backgroundColor: LightTheme.background,
        dialogBackgroundColor: LightTheme.dialogbackground,
        textColor: LightTheme.darkBlue,
        errorColor: LightTheme.red,
        darkBlueColor: LightTheme.darkBlue),
    dividerColor: LightTheme.grey,
    fontFamily: "Roboto",
    textTheme: const TextTheme(
        bodyLarge: TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        bodyMedium: TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        bodySmall: TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        displaySmall:
            TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        displayMedium:
            TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        displayLarge:
            TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        headlineLarge:
            TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        headlineMedium:
            TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        headlineSmall:
            TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        titleMedium:
            TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto'),
        titleLarge: TextStyle(
            color: LightTheme.darkBlue,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto'),
        titleSmall:
            TextStyle(color: LightTheme.darkBlue, fontFamily: 'Roboto')),
    scaffoldBackgroundColor: LightTheme.background,
    cardTheme: CardThemeData(
        elevation: 2,
        color: LightTheme.second,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius)),
        shadowColor: LightTheme.darkGrey.withValues(alpha: 0.15)),
    iconTheme: const IconThemeData(color: LightTheme.primary),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return LightTheme.darkGrey.withValues(alpha: 0.38);
              }
              return LightTheme.darkBlue;
            }),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.hovered)) {
                return LightTheme.primary.withValues(alpha: 0.08);
              }
              if (states.contains(WidgetState.pressed)) {
                return LightTheme.primary.withValues(alpha: 0.12);
              }
              return null;
            }),
            iconSize: WidgetStateProperty.all<double>(24.sp),
            minimumSize: WidgetStateProperty.all<Size>(const Size(40, 40)),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(8)),
            splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
            shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))))),
    switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all<Color>(LightTheme.primary),
        trackColor:
            WidgetStateProperty.all<Color>(LightTheme.primary.withAlpha(50))),
    radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all<Color>(LightTheme.primary)),
    primaryIconTheme: const IconThemeData(color: LightTheme.primary),
    appBarTheme: AppBarTheme(
        elevation: 0,
        toolbarHeight: 6.h,
        actionsIconTheme: const IconThemeData(color: LightTheme.second),
        backgroundColor: ThemaMain.appbar,
        iconTheme: IconThemeData(color: LightTheme.second, size: 24.sp),
        titleTextStyle: TextStyle(
            color: LightTheme.second,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto')),
    scrollbarTheme: const ScrollbarThemeData(
        radius: Radius.circular(24),
        thumbColor: WidgetStatePropertyAll(LightTheme.darkBlue)),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return LightTheme.grey.withValues(alpha: 0.12);
              }
              return ThemaMain.darkBlue;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return LightTheme.darkGrey.withValues(alpha: 0.38);
              }
              return ThemaMain.second;
            }),
            elevation: WidgetStateProperty.resolveWith<double>((states) {
              if (states.contains(WidgetState.pressed)) return 3;
              if (states.contains(WidgetState.hovered)) return 2;
              return 1;
            }),
            shadowColor: WidgetStateProperty.all<Color>(LightTheme.darkGrey.withValues(alpha: 0.2)),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
            minimumSize: WidgetStateProperty.all<Size>(const Size(64, 44)),
            splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))))),
    filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(ThemaMain.darkBlue), foregroundColor: const WidgetStatePropertyAll(LightTheme.second), padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 24, vertical: 14)), minimumSize: WidgetStateProperty.all<Size>(const Size(64, 44)), splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory, shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(foregroundColor: const WidgetStatePropertyAll(LightTheme.primary), side: const WidgetStatePropertyAll(BorderSide(color: LightTheme.primary, width: 1.5)), padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 24, vertical: 14)), minimumSize: WidgetStateProperty.all<Size>(const Size(64, 44)), splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory, shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))))),
    inputDecorationTheme: InputDecorationTheme(prefixIconColor: LightTheme.darkGrey, suffixIconColor: LightTheme.primary, fillColor: LightTheme.second, filled: true, iconColor: LightTheme.primary, contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20), floatingLabelStyle: const TextStyle(color: LightTheme.primary, fontFamily: 'Roboto'), hintStyle: const TextStyle(fontSize: 14, fontFamily: 'Roboto'), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: Colors.transparent, width: 2)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: LightTheme.primary, width: 2)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: Colors.transparent, width: 2))),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)), elevation: 3, backgroundColor: LightTheme.dialogbackground),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: LightTheme.primary, foregroundColor: LightTheme.second, splashColor: LightTheme.primary, hoverColor: LightTheme.primary, focusColor: LightTheme.primary, elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))),
    splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
    splashColor: LightTheme.grey,
    highlightColor: LightTheme.grey,
    tooltipTheme: TooltipThemeData(textStyle: const TextStyle(color: LightTheme.second, fontSize: 18, fontFamily: 'Roboto'), decoration: BoxDecoration(color: LightTheme.primary, borderRadius: BorderRadius.circular(borderRadius))),
    dividerTheme: const DividerThemeData(color: LightTheme.grey, thickness: 2),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return LightTheme.darkGrey.withValues(alpha: 0.38);
              }
              return LightTheme.darkBlue;
            }),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            minimumSize: WidgetStateProperty.all<Size>(const Size(64, 40)),
            textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
            splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))))));

ThemeData dark = ThemeData(
    useMaterial3: true,
    colorScheme: _buildExpressiveColorScheme(
        seedColor: DarkTheme.primary,
        isDark: true,
        primaryColor: DarkTheme.primary,
        secondaryColor: DarkTheme.second,
        backgroundColor: DarkTheme.background,
        dialogBackgroundColor: DarkTheme.dialogbackground,
        textColor: DarkTheme.darkBlue,
        errorColor: DarkTheme.red,
        darkBlueColor: DarkTheme.darkBlue),
    dividerColor: DarkTheme.darkBlue,
    fontFamily: "Roboto",
    textTheme: const TextTheme(
        bodyLarge: TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        bodyMedium: TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        bodySmall: TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        displaySmall:
            TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        displayMedium:
            TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        displayLarge:
            TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        headlineLarge:
            TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        headlineMedium:
            TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        headlineSmall:
            TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        titleMedium: TextStyle(color: DarkTheme.darkBlue, fontFamily: 'Roboto'),
        titleLarge: TextStyle(
            color: DarkTheme.grey,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto'),
        titleSmall: TextStyle(color: DarkTheme.grey, fontFamily: 'Roboto')),
    scaffoldBackgroundColor: DarkTheme.background,
    cardTheme: CardThemeData(
        elevation: 2,
        color: DarkTheme.second,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius)),
        shadowColor: Colors.black.withValues(alpha: 0.46)),
    iconTheme: const IconThemeData(color: DarkTheme.primary),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
            iconColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return DarkTheme.darkGrey.withValues(alpha: 0.38);
              }
              return DarkTheme.darkBlue;
            }),
            backgroundColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.hovered)) {
                return DarkTheme.primary.withValues(alpha: 0.12);
              }
              if (states.contains(WidgetState.pressed)) {
                return DarkTheme.primary.withValues(alpha: 0.20);
              }
              return null;
            }),
            iconSize: WidgetStateProperty.all<double>(24.sp),
            minimumSize: WidgetStateProperty.all<Size>(const Size(40, 40)),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(
                const EdgeInsets.all(8)),
            splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
            shape: WidgetStateProperty.all<OutlinedBorder>(
                RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16))))),
    switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all<Color>(DarkTheme.primary),
        trackColor:
            WidgetStateProperty.all<Color>(DarkTheme.primary.withAlpha(50))),
    radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all<Color>(DarkTheme.primary)),
    primaryIconTheme: const IconThemeData(color: DarkTheme.primary),
    appBarTheme: AppBarTheme(
        elevation: 0,
        actionsIconTheme: const IconThemeData(color: DarkTheme.second),
        backgroundColor: ThemaMain.appbar,
        iconTheme: IconThemeData(color: DarkTheme.second, size: 24.sp),
        titleTextStyle: const TextStyle(
            color: DarkTheme.second,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            fontFamily: 'Roboto')),
    scrollbarTheme: const ScrollbarThemeData(
        radius: Radius.circular(24),
        thumbColor: WidgetStatePropertyAll(DarkTheme.darkBlue)),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return DarkTheme.grey.withValues(alpha: 0.12);
              }
              return ThemaMain.white;
            }),
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return DarkTheme.darkGrey.withValues(alpha: 0.38);
              }
              return DarkTheme.darkGrey;
            }),
            elevation: WidgetStateProperty.resolveWith<double>((states) {
              if (states.contains(WidgetState.pressed)) return 3;
              if (states.contains(WidgetState.hovered)) return 2;
              return 1;
            }),
            shadowColor: WidgetStateProperty.all<Color>(Colors.black.withValues(alpha: 0.4)),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 24, vertical: 14)),
            minimumSize: WidgetStateProperty.all<Size>(const Size(64, 44)),
            splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))))),
    filledButtonTheme: FilledButtonThemeData(style: ButtonStyle(backgroundColor: const WidgetStatePropertyAll(DarkTheme.darkBlue), foregroundColor: const WidgetStatePropertyAll(DarkTheme.second), padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 24, vertical: 14)), minimumSize: WidgetStateProperty.all<Size>(const Size(64, 44)), splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory, shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))))),
    outlinedButtonTheme: OutlinedButtonThemeData(style: ButtonStyle(foregroundColor: const WidgetStatePropertyAll(DarkTheme.primary), side: const WidgetStatePropertyAll(BorderSide(color: DarkTheme.primary, width: 1.5)), padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 24, vertical: 14)), minimumSize: WidgetStateProperty.all<Size>(const Size(64, 44)), splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory, shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))))),
    inputDecorationTheme: InputDecorationTheme(prefixIconColor: DarkTheme.darkGrey, suffixIconColor: DarkTheme.primary, fillColor: DarkTheme.second, filled: true, iconColor: DarkTheme.primary, contentPadding: const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20), floatingLabelStyle: const TextStyle(color: DarkTheme.primary, fontFamily: 'Roboto'), hintStyle: const TextStyle(fontSize: 14, fontFamily: 'Roboto'), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: Colors.transparent, width: 2)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: DarkTheme.primary, width: 2)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: Colors.transparent, width: 2))),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)), elevation: 3, backgroundColor: DarkTheme.dialogbackground),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: DarkTheme.primary, foregroundColor: DarkTheme.second, splashColor: DarkTheme.primary, hoverColor: DarkTheme.primary, focusColor: DarkTheme.primary, elevation: 3, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))),
    splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
    splashColor: DarkTheme.grey,
    highlightColor: DarkTheme.grey,
    tooltipTheme: TooltipThemeData(textStyle: const TextStyle(color: DarkTheme.second, fontSize: 18, fontFamily: 'Roboto'), decoration: BoxDecoration(color: DarkTheme.primary, borderRadius: BorderRadius.circular(borderRadius))),
    dividerTheme: const DividerThemeData(color: DarkTheme.grey, thickness: 2),
    textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
            foregroundColor: WidgetStateProperty.resolveWith<Color>((states) {
              if (states.contains(WidgetState.disabled)) {
                return DarkTheme.darkGrey.withValues(alpha: 0.38);
              }
              return DarkTheme.darkBlue;
            }),
            padding: WidgetStateProperty.all<EdgeInsetsGeometry>(const EdgeInsets.symmetric(horizontal: 16, vertical: 10)),
            minimumSize: WidgetStateProperty.all<Size>(const Size(64, 40)),
            textStyle: WidgetStateProperty.all<TextStyle>(const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'Roboto')),
            splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))))));
