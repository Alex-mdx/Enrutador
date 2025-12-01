import 'dart:convert';
import 'package:enrutador/models/geo_names_model.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/geo_postal_model.dart';

class GeoFun {
  static String username = "kmodx";
  static Future<List<GeoPostalModel>> searchPostalCode(
      String postalCode, int? maxRows) async {
    try {
      var url = Uri.parse(
          "http://api.geonames.org/postalCodeSearchJSON?postalcode=$postalCode&maxRows=${maxRows ?? 6}&username=$username");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<GeoPostalModel> postalCodes = [];
        for (var element in data["postalCodes"]) {
          postalCodes.add(GeoPostalModel.fromJson(element));
        }
        return postalCodes;
      } else {
        debugPrint("${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("$e");
      return [];
    }
  }

  static Future<List<GeoNamesModel>> searchCity(
      String city, int? maxRows) async {
    try {
      var url = Uri.parse(
          "http://api.geonames.org/searchJSON?q=$city&maxRows=${maxRows ?? 6}&lang=es&username=$username");
      var response = await http.get(url);
      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        List<GeoNamesModel> names = [];
        for (var element in data["geonames"]) {
          names.add(GeoNamesModel.fromJson(element));
        }
        return names;
      } else {
        debugPrint("${response.statusCode} - ${response.body}");
        return [];
      }
    } catch (e) {
      debugPrint("$e");
      return [];
    }
  }
}
