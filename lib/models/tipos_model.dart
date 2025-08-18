import 'package:enrutador/utilities/funcion_parser.dart';
import 'package:enrutador/utilities/theme/theme_color.dart';
import 'package:flutter/material.dart';

class TiposModelo {
  int? id;
  String nombre;
  String? descripcion;
  IconData? icon;
  Color? color;

  TiposModelo(
      { this.id,
      required this.nombre,
      required this.descripcion,
      required this.icon,
      required this.color});

  TiposModelo copyWith(
          {int? id,
          String? nombre,
          String? descripcion,
          IconData? icon,
          Color? color}) =>
      TiposModelo(
          id: id ?? this.id,
          nombre: nombre ?? this.nombre,
          descripcion: descripcion ?? this.descripcion,
          icon: icon ?? this.icon,
          color: color ?? this.color);

  factory TiposModelo.fromJson(Map<String, dynamic> json) => TiposModelo(
      id: json["id"],
      nombre: json["nombre"],
      descripcion: json["descripcion"],
      icon: Parser.stringToIconData(json["icon"]) ,
      color: Color(int.tryParse(json["color"].toString()) ?? ThemaMain.primary.toARGB32() ));

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "descripcion": descripcion,
        "icon": '${icon?.codePoint}_${icon?.fontFamily}',
        "color": color?.toARGB32().toString()
      };
}
