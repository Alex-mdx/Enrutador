import 'dart:convert';

import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/utilities/funcion_parser.dart';

class EnrutarModelo {
  int? id;
  int? visitado;
  int contactoId;
  int orden;
  ContactoModelo buscar;

  EnrutarModelo(
      {this.id,
      required this.visitado,
      required this.contactoId,
      required this.orden,
      required this.buscar});

  EnrutarModelo copyWith(
          {int? id,
          int? visitado,
          int? orden,
          int? contactoId,
          ContactoModelo? buscar}) =>
      EnrutarModelo(
          id: id ?? this.id,
          visitado: visitado ?? this.visitado,
          orden: orden ?? this.orden,
          contactoId: contactoId ?? this.contactoId,
          buscar: buscar ?? this.buscar);

  factory EnrutarModelo.fromJson(Map<String, dynamic> json) => EnrutarModelo(
      id: json["id"],
      visitado: Parser.toInt(json["visitado"]),
      orden: json["orden"],
      contactoId: json["contacto_id"],
      buscar: ContactoModelo.fromJson(jsonDecode(json["buscar"])));

  Map<String, dynamic> toJson() => {
        "id": id,
        "visitado": visitado,
        "orden": orden,
        "contacto_id": contactoId,
        "buscar": jsonEncode(buscar)
      };
}
