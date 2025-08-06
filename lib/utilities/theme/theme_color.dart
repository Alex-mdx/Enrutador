import 'package:flutter/material.dart';

import '../preferences.dart';

class ThemaMain {
  static Color primary = LightTheme.primary;
  static Color appbar = const Color.fromARGB(255, 18, 107, 223);
  static Color second =
      (Preferences.thema ? LightTheme.second : DarkTheme.second);
  static Color white = Colors.white;
  static Color black = Colors.black;

  static Color green = (Preferences.thema ? LightTheme.green : DarkTheme.green);
  static Color red = (Preferences.thema ? LightTheme.red : DarkTheme.red);
  static Color yellow =
      (Preferences.thema ? LightTheme.yellow : DarkTheme.yellow);
  static Color pink = (Preferences.thema ? LightTheme.pink : DarkTheme.pink);
  static Color purple =
      (Preferences.thema ? LightTheme.purple : DarkTheme.purple);

  static Color background =
      (Preferences.thema ? LightTheme.background : DarkTheme.background);
  static Color dialogbackground = (Preferences.thema
      ? LightTheme.dialogbackground
      : DarkTheme.dialogbackground);
  static Color darkGrey =
      (Preferences.thema ? LightTheme.darkGrey : DarkTheme.darkGrey);
  static Color darkBlue =
      (Preferences.thema ? LightTheme.darkBlue : DarkTheme.darkBlue);

  static Color grey = (Preferences.thema ? LightTheme.grey : DarkTheme.grey);
}

class LightTheme {
  static const primary = Color.fromARGB(255, 4, 142, 223);
  static const second = Color.fromARGB(255, 246, 247, 247);

  static const green = Color.fromARGB(255, 1, 207, 53);
  static const red = Color.fromARGB(255, 231, 20, 20);
  static const yellow = Color.fromARGB(255, 235, 210, 4);
  static const pink = Color.fromARGB(255, 235, 4, 166);
  static const purple = Color.fromARGB(255, 106, 20, 218);

  static const background = Color.fromARGB(255, 231, 238, 240);
  static const dialogbackground = Color.fromARGB(255, 212, 235, 238);
  static const darkGrey = Color.fromARGB(255, 119, 122, 133);
  static const darkBlue = Color.fromARGB(255, 0, 36, 84);

  static const grey = Color.fromARGB(255, 206, 210, 212);
}

class DarkTheme {
  static const primary = Color.fromARGB(255, 53, 198, 255);
  static const second = Color.fromARGB(255, 40, 42, 43);

  static const green = Color.fromARGB(255, 70, 255, 116);
  static const red = Color.fromARGB(255, 255, 76, 70);
  static const yellow = Color.fromARGB(255, 241, 216, 73);
  static const pink = Color.fromARGB(255, 255, 86, 185);
  static const purple = Color.fromARGB(255, 156, 80, 255);

  static const background = Color.fromARGB(255, 17, 17, 17);
  static const dialogbackground = Color.fromARGB(255, 46, 49, 49);
  static const darkGrey = Color.fromARGB(255, 231, 235, 235);
  static const darkBlue = Color.fromARGB(255, 178, 206, 241);

  static const grey = Color.fromARGB(255, 208, 210, 212);
}
