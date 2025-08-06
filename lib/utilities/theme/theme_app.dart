import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'theme_color.dart';

const double borderRadius = 24.0;
ThemeData light = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: LightTheme.primary),
    dividerColor: LightTheme.grey,
    textTheme: const TextTheme(
        bodyLarge: TextStyle(color: LightTheme.darkBlue),
        bodyMedium: TextStyle(color: LightTheme.darkBlue),
        bodySmall: TextStyle(color: LightTheme.darkBlue),
        displaySmall: TextStyle(color: LightTheme.darkBlue),
        displayMedium: TextStyle(color: LightTheme.darkBlue),
        displayLarge: TextStyle(color: LightTheme.darkBlue),
        headlineLarge: TextStyle(color: LightTheme.darkBlue),
        headlineMedium: TextStyle(color: LightTheme.darkBlue),
        headlineSmall: TextStyle(color: LightTheme.darkBlue),
        titleMedium: TextStyle(color: LightTheme.darkBlue),
        titleLarge: TextStyle(
            color: LightTheme.darkBlue,
            fontSize: 36,
            fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: LightTheme.darkBlue)),
    scaffoldBackgroundColor: LightTheme.background,
    cardTheme: const CardThemeData(elevation: 2, color: LightTheme.second),
    iconTheme: const IconThemeData(color: LightTheme.primary),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
            iconColor: WidgetStateProperty.all<Color>(LightTheme.primary),
            iconSize: WidgetStateProperty.all<double>(24.sp),
            splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory)),
    switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.all<Color>(LightTheme.primary),
        trackColor:
            WidgetStateProperty.all<Color>(LightTheme.primary.withAlpha(50))),
    radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.all<Color>(LightTheme.primary)),
    primaryIconTheme: const IconThemeData(color: LightTheme.primary),
    appBarTheme: AppBarTheme(
        elevation: 0,
        actionsIconTheme: const IconThemeData(color: LightTheme.second),
        backgroundColor: ThemaMain.appbar,
        iconTheme: IconThemeData(color: LightTheme.second, size: 24.sp),
        titleTextStyle: const TextStyle(
            color: LightTheme.second,
            fontSize: 32,
            fontWeight: FontWeight.bold)),
    scrollbarTheme: const ScrollbarThemeData(
        radius: Radius.circular(24),
        thumbColor: WidgetStatePropertyAll(LightTheme.second)),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(LightTheme.second),
            elevation: WidgetStateProperty.all<double>(0),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius))))),
    inputDecorationTheme: InputDecorationTheme(
        prefixIconColor: LightTheme.darkGrey,
        suffixIconColor: LightTheme.primary,
        fillColor: LightTheme.second,
        filled: true,
        iconColor: LightTheme.primary,
        contentPadding:
            const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        floatingLabelStyle: const TextStyle(color: LightTheme.primary),
        hintStyle: const TextStyle(fontSize: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.transparent, width: 2)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.transparent, width: 2)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: Colors.transparent, width: 2))),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)), elevation: 1, backgroundColor: LightTheme.dialogbackground),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: LightTheme.primary, foregroundColor: LightTheme.second, splashColor: LightTheme.primary, hoverColor: LightTheme.primary, focusColor: LightTheme.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))),
    splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
    splashColor: LightTheme.grey,
    highlightColor: LightTheme.grey,
    tooltipTheme: TooltipThemeData(textStyle: const TextStyle(color: LightTheme.second, fontSize: 18), decoration: BoxDecoration(color: LightTheme.primary, borderRadius: BorderRadius.circular(borderRadius))),
    dividerTheme: const DividerThemeData(color: LightTheme.grey, thickness: 2),
    textButtonTheme: TextButtonThemeData(style: ButtonStyle(splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory, shape: WidgetStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius)))))));
ThemeData dark = ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: DarkTheme.primary),
    dividerColor: DarkTheme.darkBlue,
    textTheme: const TextTheme(
        bodyLarge: TextStyle(color: DarkTheme.darkBlue),
        bodyMedium: TextStyle(color: DarkTheme.darkBlue),
        bodySmall: TextStyle(color: DarkTheme.darkBlue),
        displaySmall: TextStyle(color: DarkTheme.darkBlue),
        displayMedium: TextStyle(color: DarkTheme.darkBlue),
        displayLarge: TextStyle(color: DarkTheme.darkBlue),
        headlineLarge: TextStyle(color: DarkTheme.darkBlue),
        headlineMedium: TextStyle(color: DarkTheme.darkBlue),
        headlineSmall: TextStyle(color: DarkTheme.darkBlue),
        titleMedium: TextStyle(color: DarkTheme.darkBlue),
        titleLarge: TextStyle(
            color: DarkTheme.grey, fontSize: 36, fontWeight: FontWeight.bold),
        titleSmall: TextStyle(color: DarkTheme.grey)),
    scaffoldBackgroundColor: DarkTheme.background,
    cardTheme: const CardThemeData(elevation: 2, color: DarkTheme.second),
    iconTheme: const IconThemeData(color: DarkTheme.primary),
    iconButtonTheme: IconButtonThemeData(
        style: ButtonStyle(
            iconColor: WidgetStateProperty.all<Color>(DarkTheme.primary),
            iconSize: WidgetStateProperty.all<double>(24.sp),
            splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory)),
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
            fontWeight: FontWeight.bold)),
    scrollbarTheme: const ScrollbarThemeData(
        radius: Radius.circular(24),
        thumbColor: WidgetStatePropertyAll(DarkTheme.grey)),
    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            backgroundColor: const WidgetStatePropertyAll(DarkTheme.darkBlue),
            elevation: WidgetStateProperty.all<double>(0),
            shape: WidgetStateProperty.all<RoundedRectangleBorder>(RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(borderRadius))))),
    inputDecorationTheme: InputDecorationTheme(
        prefixIconColor: DarkTheme.darkGrey,
        suffixIconColor: DarkTheme.primary,
        fillColor: DarkTheme.second,
        filled: true,
        iconColor: DarkTheme.primary,
        contentPadding:
            const EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 20),
        floatingLabelStyle: const TextStyle(color: DarkTheme.primary),
        hintStyle: const TextStyle(fontSize: 14),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: const BorderSide(color: Colors.transparent, width: 2)),
        focusedBorder:
            OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: Colors.transparent, width: 2)),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(borderRadius), borderSide: const BorderSide(color: Colors.transparent, width: 2))),
    dialogTheme: DialogThemeData(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)), elevation: 1, backgroundColor: DarkTheme.dialogbackground),
    floatingActionButtonTheme: FloatingActionButtonThemeData(backgroundColor: DarkTheme.primary, foregroundColor: DarkTheme.second, splashColor: DarkTheme.primary, hoverColor: DarkTheme.primary, focusColor: DarkTheme.primary, elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius))),
    splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory,
    splashColor: DarkTheme.grey,
    highlightColor: DarkTheme.grey,
    tooltipTheme: TooltipThemeData(textStyle: const TextStyle(color: DarkTheme.second, fontSize: 18), decoration: BoxDecoration(color: DarkTheme.primary, borderRadius: BorderRadius.circular(borderRadius))),
    dividerTheme: const DividerThemeData(color: DarkTheme.grey, thickness: 2),
    textButtonTheme: TextButtonThemeData(style: ButtonStyle(splashFactory: InkSparkle.constantTurbulenceSeedSplashFactory, shape: WidgetStateProperty.all<RoundedRectangleBorder>(const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius)))))));
