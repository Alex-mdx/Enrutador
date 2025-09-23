import 'package:flutter/material.dart';

import '../utilities/theme/theme_color.dart';

class EstadoModel {
  int? id;
  String nombre;
  String? descripcion;
  int orden;
  Color? color;

  EstadoModel(
      {required this.id,
      required this.nombre,
      required this.descripcion,
      required this.orden,
      required this.color});

  EstadoModel copyWith(
          {int? id,
          String? nombre,
          String? descripcion,
          int? orden,
          Color? color}) =>
      EstadoModel(
          id: id ?? this.id,
          nombre: nombre ?? this.nombre,
          descripcion: descripcion ?? this.descripcion,
          orden: orden ?? this.orden,
          color: color ?? this.color);

  factory EstadoModel.fromJson(Map<String, dynamic> json) => EstadoModel(
      id: json["id"],
      nombre: json["nombre"],
      descripcion: json["descripcion"],
      orden: json["orden"],
      color: Color(int.tryParse(json["color"].toString()) ??
          ThemaMain.primary.toARGB32()));

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "descripcion": descripcion,
        "orden": orden,
        "color": color?.toARGB32().toString()
      };
}
