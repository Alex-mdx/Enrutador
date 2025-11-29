import 'dart:convert';
import 'dart:developer';
import 'package:enrutador/models/what_3_words_model.dart';
import 'package:flutter/material.dart';
import 'package:oktoast/oktoast.dart';
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

  static Future<List<What3WordsModel>> suggets(String word) async {
    var isw3w = api.isPossible3wa(word);
    if (isw3w) {
      AutosuggestOptions opciones = AutosuggestOptions().setNResults(3);
      try {
        var len = await api.autosuggest(word, options: opciones).execute();
        log(jsonEncode(len.data()?.toJson()["suggestions"] as List<Map<String, dynamic>>));
        return (len.data()?.toJson()["suggestions"]
                as List<Map<String, dynamic>>)
            .map((e) => What3WordsModel.fromJson(e))
            .toList();
      } catch (e) {
        debugPrint("error: $e");
        return [];
      }
    } else {
      debugPrint("$isw3w");
      return [];
    }
  }

  static Future<void> wordtocoor(String word) async {
    try {
      var len = await api.convertToCoordinates(word).execute();
      log("${len.data()} - ${len.error()?.message ?? "No"}");
      if (len.data() != null) {
      } else {
        showToast("Error: ${len.error()?.message ?? "Desconocido"}");
      }
    } catch (e) {
      debugPrint("error: $e");
    }
  }
}
