import 'package:cloud_firestore/cloud_firestore.dart';

class TipModel {
  final int id;
  final String uuid;
  final String empleadoCreado;
  final String empleadoBy;
  final String empleadoTo;
  final String? contexto;
  final String? respuesta;
  final int abierto;
  final int estadoTip;
  final DateTime fechaCreacion;
  final DateTime? fechaUpdate;
  final DateTime? fechaCerrado;

  TipModel(
      {required this.id,
      required this.uuid,
      required this.empleadoCreado,
      required this.empleadoBy,
      required this.empleadoTo,
      required this.contexto,
      required this.respuesta,
      required this.abierto,
      required this.estadoTip,
      required this.fechaCreacion,
      required this.fechaUpdate,
      required this.fechaCerrado});

  TipModel copyWith(
          {int? id,
          String? uuid,
          String? empleadoCreado,
          String? empleadoBy,
          String? empleadoTo,
          String? contexto,
          String? respuesta,
          int? abierto,
          int? estadoTip,
          DateTime? fechaCreacion,
          DateTime? fechaUpdate,
          DateTime? fechaCerrado}) =>
      TipModel(
          id: id ?? this.id,
          uuid: uuid ?? this.uuid,
          empleadoCreado: empleadoCreado ?? this.empleadoCreado,
          empleadoBy: empleadoBy ?? this.empleadoBy,
          empleadoTo: empleadoTo ?? this.empleadoTo,
          contexto: contexto ?? this.contexto,
          respuesta: respuesta ?? this.respuesta,
          abierto: abierto ?? this.abierto,
          estadoTip: estadoTip ?? this.estadoTip,
          fechaCreacion: fechaCreacion ?? this.fechaCreacion,
          fechaUpdate: fechaUpdate ?? this.fechaUpdate,
          fechaCerrado: fechaCerrado ?? this.fechaCerrado);
  factory TipModel.fromJson(Map<String, dynamic> json) => TipModel(
      id: json["id"],
      uuid: json["uuid"],
      empleadoCreado: json["empleado_creado"],
      empleadoBy: json["empleado_by"],
      empleadoTo: json["empleado_to"],
      contexto: json["contexto"],
      respuesta: json["respuesta"],
      abierto: json["abierto"],
      estadoTip: json["estado_tip"],
      fechaCreacion: DateTime.parse(json["fecha_creacion"]),
      fechaUpdate: DateTime.parse(json["fecha_update"]),
      fechaCerrado: DateTime.parse(json["fecha_cerrado"]));

  Map<String, dynamic> toFire() => {
        "id": id,
        "uuid": uuid,
        "empleado_creado": empleadoCreado,
        "empleado_by": empleadoBy,
        "empleado_to": empleadoTo,
        "contexto": contexto,
        "respuesta": respuesta,
        "abierto": abierto,
        "estado_tip": estadoTip,
        "fecha_creacion": Timestamp.fromDate(fechaCreacion),
        "fecha_update":
            fechaUpdate == null ? null : Timestamp.fromDate(fechaUpdate!),
        "fecha_cerrado":
            fechaCerrado == null ? null : Timestamp.fromDate(fechaCerrado!)
      };
}
