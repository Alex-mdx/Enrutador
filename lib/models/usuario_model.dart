import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enrutador/utilities/funcion_parser.dart';
import 'package:enrutador/utilities/textos.dart';

class UsuarioModel {
  int id;
  String? uuid;
  String? nombre;
  int? contactoId;
  String? empleadoId;
  int? adminTipo;
  int? status;
  List<int> children;
  DateTime? creacion;
  DateTime? actualizacion;

  UsuarioModel(
      {required this.id,
      required this.uuid,
      required this.nombre,
      required this.contactoId,
      required this.empleadoId,
      required this.adminTipo,
      required this.status,
      required this.children,
      required this.creacion,
      this.actualizacion});

  UsuarioModel copyWith(
          {int? id,
          String? uuid,
          String? nombre,
          int? contactoId,
          String? empleadoId,
          int? adminTipo,
          int? status,
          List<int>? children,
          DateTime? creacion,
          DateTime? actualizacion}) =>
      UsuarioModel(
          id: id ?? this.id,
          uuid: uuid ?? this.uuid,
          nombre: nombre ?? this.nombre,
          contactoId: contactoId ?? this.contactoId,
          empleadoId: empleadoId ?? this.empleadoId,
          adminTipo: adminTipo ?? this.adminTipo,
          status: status ?? this.status,
          children: children ?? this.children,
          creacion: creacion ?? this.creacion,
          actualizacion: actualizacion ?? this.actualizacion);

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
      id: json["id"],
      uuid: json["uuid"],
      nombre: json["nombre"],
      contactoId: json["contacto_id"],
      empleadoId: json["empleado_id"].toString(),
      adminTipo: json["admin_tipo"],
      status: Parser.toInt(json["status"]),
      children: json["children"] == null
          ? []
          : List<int>.from(json["children"]),
      creacion: Textos.parseoDateFire(json["creacion"]),
      actualizacion: Textos.parseoDateFire(json["actualizacion"]));

  Map<String, dynamic> toFirestore() => {
        "id": id,
        "uuid": uuid,
        "nombre": nombre,
        "contacto_id": contactoId,
        "empleado_id": empleadoId,
        "admin_tipo": adminTipo,
        "status": status,
        "children": children.map((e) => e).toList(),
        "creacion": creacion == null ? null : Timestamp.fromDate(creacion!),
        "actualizacion":
            actualizacion == null ? null : Timestamp.fromDate(actualizacion!)
      };

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "nombre": nombre,
        "contacto_id": contactoId,
        "empleado_id": empleadoId,
        "admin_tipo": adminTipo,
        "status": status,
        "children": children.map((e) => e).toList(),
        "creacion": creacion?.toIso8601String(),
        "actualizacion": actualizacion?.toIso8601String()
      };
}
