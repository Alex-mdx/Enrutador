import 'package:cloud_firestore/cloud_firestore.dart';

class CarteraModel {
  final int codigo;
  final String uuid;
  final String empleadoBy;
  final String empleadoTo;
  final int activo;
  final DateTime fechaCreado;
  final DateTime fechaActualizado;
  final List<String> contactos;

  CarteraModel(
      {required this.codigo,
      required this.uuid,
      required this.empleadoBy,
      required this.empleadoTo,
      required this.activo,
      required this.fechaCreado,
      required this.fechaActualizado,
      required this.contactos});

  CarteraModel copyWith(
          {int? codigo,
          String? uuid,
          String? empleadoBy,
          String? empleadoTo,
          int? activo,
          DateTime? fechaCreado,
          DateTime? fechaActualizado,
          List<String>? contactos}) =>
      CarteraModel(
          codigo: codigo ?? this.codigo,
          uuid: uuid ?? this.uuid,
          empleadoBy: empleadoBy ?? this.empleadoBy,
          empleadoTo: empleadoTo ?? this.empleadoTo,
          activo: activo ?? this.activo,
          fechaCreado: fechaCreado ?? this.fechaCreado,
          fechaActualizado: fechaActualizado ?? this.fechaActualizado,
          contactos: contactos ?? this.contactos);

  factory CarteraModel.fromJson(Map<String, dynamic> json) => CarteraModel(
      codigo: json["codigo"],
      uuid: json["uuid"],
      empleadoBy: json["empleado_by"],
      empleadoTo: json["empleado_to"],
      activo: json["activo"],
      fechaCreado: DateTime.parse(json["fecha_creado"]),
      fechaActualizado: DateTime.parse(json["fecha_actualizado"]),
      contactos: List<String>.from(json["contactos"].map((x) => x)));

  Map<String, dynamic> toJson() => {
        "codigo": codigo,
        "uuid": uuid,
        "empleado_by": empleadoBy,
        "empleado_to": empleadoTo,
        "activo": activo,
        "fecha_creado": Timestamp.fromDate(fechaCreado),
        "fecha_actualizado": Timestamp.fromDate(fechaActualizado),
        "contactos": contactos
      };
}
