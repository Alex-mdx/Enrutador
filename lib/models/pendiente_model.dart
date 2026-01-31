import 'dart:convert';

import 'package:enrutador/models/contacto_model.dart';
import 'package:enrutador/models/referencia_model.dart';

class PendienteModel {
  int id;
  int contactoId;
  String empleadoId;
  List<ContactoModelo> contactos;
  List<ReferenciaModelo> referencias;
  List<int> notas;
  int sincronizado;

  PendienteModel({
    required this.id,
    required this.contactoId,
    required this.empleadoId,
    required this.contactos,
    required this.referencias,
    required this.notas,
    required this.sincronizado,
  });

  PendienteModel copyWith({
    int? id,
    int? contactoId,
    String? empleadoId,
    List<ContactoModelo>? contactos,
    List<ReferenciaModelo>? referencias,
    List<int>? notas,
    int? sincronizado
  }) =>
      PendienteModel(
        id: id ?? this.id,
        contactoId: contactoId ?? this.contactoId,
        empleadoId: empleadoId ?? this.empleadoId,
        contactos: contactos ?? this.contactos,
        referencias: referencias ?? this.referencias,
        notas: notas ?? this.notas,
        sincronizado: sincronizado ?? this.sincronizado 
      );

  factory PendienteModel.fromJson(Map<String, dynamic> json) => PendienteModel(
        id: json["id"],
        contactoId: json["contacto_id"],
        empleadoId: json["empleado_id"],
        contactos: List<ContactoModelo>.from(json["contactos"].map((x) => ContactoModelo.fromJson(x))),
        referencias: List<ReferenciaModelo>.from(json["referencias"].map((x) => ReferenciaModelo.fromJson(x))),
        notas: List<int>.from(json["notas"].map((x) => x)),
        sincronizado: json["sincronizado"]
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "contacto_id": contactoId,
        "empleado_id": empleadoId,
        "contactos": generarContactos(contactos.toString()),
        "referencias": generarReferencias(referencias.toString()),
        "notas": notas,
        "sincronizado": sincronizado
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
}
