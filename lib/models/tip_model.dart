import 'package:cloud_firestore/cloud_firestore.dart';

import '../utilities/textos.dart';

class TipModel {
  final String uuid;
  final List<String> contactosIds;
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
      {required this.uuid,
      required this.contactosIds,
      required this.empleadoCreado,
      required this.empleadoBy,
      required this.empleadoTo,
      required this.contexto,
      this.respuesta,
      required this.abierto,
      required this.estadoTip,
      required this.fechaCreacion,
      this.fechaUpdate,
      this.fechaCerrado});

  TipModel copyWith(
          {String? uuid,
          List<String>? contactosIds,
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
          uuid: uuid ?? this.uuid,
          contactosIds: contactosIds ?? this.contactosIds,
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
      uuid: json["uuid"],
      contactosIds: json["contactos_ids"] == null
          ? []
          : List<String>.from(json["contactos_ids"]),
      empleadoCreado: json["empleado_creado"],
      empleadoBy: json["empleado_by"],
      empleadoTo: json["empleado_to"],
      contexto: json["contexto"],
      respuesta: json["respuesta"],
      abierto: json["abierto"],
      estadoTip: json["estado_tip"],
      fechaCreacion: Textos.parseoDateFire(json["fecha_creacion"])!,
      fechaUpdate: Textos.parseoDateFire(json["fecha_update"]),
      fechaCerrado: Textos.parseoDateFire(json["fecha_cerrado"]));

  Map<String, dynamic> toFire() => {
        "uuid": uuid,
        "contactos_ids": contactosIds.map((e) => e).toList(),
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
