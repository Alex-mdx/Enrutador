import 'dart:convert';

import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/nota_model.dart';
import 'package:enrutador/models/referencia_model.dart';

class PendienteModel {
  String id;
  int contactoId;
  String? aceptadoEmpleadoId;
  String empleadoId;
  List<ContactoModelo> contactos;
  List<ReferenciaModelo> referencias;
  List<NotaModel> notas;
  int sincronizado;
  DateTime fechaPendiente;
  DateTime? fechaSincronizado;

  PendienteModel(
      {required this.id,
      required this.contactoId,
      required this.aceptadoEmpleadoId,
      required this.empleadoId,
      required this.contactos,
      required this.referencias,
      required this.notas,
      required this.sincronizado,
      required this.fechaPendiente,
      required this.fechaSincronizado});

  PendienteModel copyWith(
          {String? id,
          int? contactoId,
          String? aceptadoEmpleadoId,
          String? empleadoId,
          List<ContactoModelo>? contactos,
          List<ReferenciaModelo>? referencias,
          List<NotaModel>? notas,
          int? sincronizado,
          DateTime? fechaPendiente,
          DateTime? fechaSincronizado}) =>
      PendienteModel(
          id: id ?? this.id,
          contactoId: contactoId ?? this.contactoId,
          aceptadoEmpleadoId: aceptadoEmpleadoId ?? this.aceptadoEmpleadoId,
          empleadoId: empleadoId ?? this.empleadoId,
          contactos: contactos ?? this.contactos,
          referencias: referencias ?? this.referencias,
          notas: notas ?? this.notas,
          sincronizado: sincronizado ?? this.sincronizado,
          fechaPendiente: fechaPendiente ?? this.fechaPendiente,
          fechaSincronizado: fechaSincronizado ?? this.fechaSincronizado);

  factory PendienteModel.fromJson(Map<String, dynamic> json) => PendienteModel(
      id: json["id"],
      contactoId: json["contacto_id"],
      aceptadoEmpleadoId: json["aceptado_empleado_id"],
      empleadoId: json["empleado_id"],
      contactos:generarContactos(json["contactos"].toString()),
      referencias:generarReferencias(json["referencias"].toString()),
      notas:generarNotas(json["notas"].toString()),
      sincronizado: json["sincronizado"],
      fechaPendiente: DateTime.parse(json["fecha_pendiente"]),
      fechaSincronizado: DateTime.parse(json["fecha_sincronizado"]));

  Map<String, dynamic> toJson() => {
        "id": id,
        "contacto_id": contactoId,
        "empleado_id": empleadoId,
        "contactos":  jsonEncode(contactos.map((r) => r.toJson()).toList()),
        "referencias":  jsonEncode(referencias.map((r) => r.toJson()).toList()),
        "notas":  jsonEncode(notas.map((r) => r.toJson()).toList()),
        "sincronizado": sincronizado,
        "fecha_pendiente": fechaPendiente.toIso8601String(),
        "fecha_sincronizado": fechaSincronizado?.toIso8601String()
      };

  static List<ContactoModelo> generarContactos(String texto) {
    try {
      final mapa = jsonDecode(texto);
      List<ContactoModelo> detalleTemp = [];
      for (var element in mapa) {
        detalleTemp.add(ContactoModelo.fromJson(element));
      }
      return detalleTemp;
    } catch (e) {
      return [];
    }
  }

  static List<ReferenciaModelo> generarReferencias(String texto) {
    try {
      final mapa = jsonDecode(texto);
      List<ReferenciaModelo> detalleTemp = [];
      for (var element in mapa) {
        detalleTemp.add(ReferenciaModelo.fromJson(element));
      }
      return detalleTemp;
    } catch (e) {
      return [];
    }
  }

  static List<NotaModel> generarNotas(String texto) {
    try {
      final mapa = jsonDecode(texto);
      List<NotaModel> detalleTemp = [];
      for (var element in mapa) {
        detalleTemp.add(NotaModel.fromJson(element));
      }
      return detalleTemp;
    } catch (e) {
      return [];
    }
  }
}
