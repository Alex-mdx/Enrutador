import 'dart:convert';

import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';

class ZonasModel {
  final int? id;
  final String nombre;
  final String? notas;
  final Color? color;
  final int status;
  final List<List<String>> latlongs;

  ZonasModel(
      {this.id,
      required this.nombre,
      this.notas,
      this.color,
      required this.status,
      required this.latlongs});

  ZonasModel copyWith(
          {int? id,
          String? nombre,
          String? notas,
          Color? color,
          int? status,
          List<List<String>>? latlongs}) =>
      ZonasModel(
          id: id ?? this.id,
          nombre: nombre ?? this.nombre,
          notas: notas ?? this.notas,
          color: color ?? this.color,
          status: status ?? this.status,
          latlongs: latlongs ?? this.latlongs);

  factory ZonasModel.fromJson(Map<String, dynamic> json) {
    dynamic rawLatlongs = json["latlongs"];
    if (rawLatlongs is String) {
      rawLatlongs = jsonDecode(rawLatlongs);
    }

    return ZonasModel(
        id: json["id"],
        nombre: json["nombre"],
        notas: json["notas"],
        status: json["status"],
        color: Color(int.tryParse(json["color"].toString()) ??
            ThemaMain.primary.toARGB32()),
        latlongs: rawLatlongs == null
            ? []
            : (rawLatlongs as List<dynamic>)
                .map((x) => (x as List<dynamic>).map((y) => y.toString()).toList())
                .toList());
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "notas": notas,
        "color": color?.toARGB32().toString(),
        "status": status,
        "latlongs": latlongs.map((x) => jsonEncode(x)).toList().toString()
      };

  Map<String, dynamic> toFire() => {
        "id": id,
        "nombre": nombre,
        "notas": notas,
        "color": color?.toARGB32().toString(),
        "status": status,
        "latlongs": latlongs.map((x) => x.toString()).toList()
      };
}
