import 'package:flutter/material.dart';

import '../utilities/funcion_parser.dart';
import '../utilities/theme/theme_color.dart';

class RolesModel {
  int? id;
  String nombre;
  IconData? icon;
  Color? color;
  int? tipo;
  DateTime? creacion;
  DateTime? actualizacion;

  RolesModel(
      {required this.id,
      required this.nombre,
      required this.icon,
      required this.color,
      required this.tipo,
      this.creacion,
      this.actualizacion});

  RolesModel copyWith(
          {int? id,
          String? nombre,
          IconData? icon,
          Color? color,
          int? tipo,
          DateTime? creacion,
          DateTime? actualizacion}) =>
      RolesModel(
          id: id ?? this.id,
          nombre: nombre ?? this.nombre,
          icon: icon ?? this.icon,
          color: color ?? this.color,
          tipo: tipo ?? this.tipo,
          creacion: creacion ?? this.creacion,
          actualizacion: actualizacion ?? this.actualizacion);

  factory RolesModel.fromJson(Map<String, dynamic> json) => RolesModel(
      id: json["id"],
      nombre: json["nombre"],
      icon: Parser.stringToIconData(json["icon"]),
      color: Color(int.tryParse(json["color"].toString()) ??
          ThemaMain.primary.toARGB32()),
      tipo: json["tipo"],
      creacion: DateTime.parse(json["creacion"]),
      actualizacion: DateTime.parse(json["actualizacion"]));

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "icon": '${icon?.codePoint}_${icon?.fontFamily}',
        "color": color?.toARGB32().toString(),
        "tipo": tipo,
        "creacion": creacion?.toIso8601String(),
        "actualizacion": actualizacion?.toIso8601String()
      };
}
