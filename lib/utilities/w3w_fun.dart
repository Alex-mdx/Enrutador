import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:what3words/what3words.dart';

class W3wFun {
  static var api = What3WordsV3('G84K5TFB');
  static Future<void> coorTo3(double lat, double lng) async {
    var len = await api.availableLanguages().execute();
    log("${len.data()?.toJson()}");
    var word =
        await api.convertTo3wa(Coordinates(lat, lng)).language('es').execute();
    debugPrint("${word.data()?.toJson()}");
  }
}
