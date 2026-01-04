import 'package:enrutador/utilities/funcion_parser.dart';

class UsuarioModel {
  int id;
  String? uuid; // Cambiado de int? a String? para almacenar el UID de Firebase
  String? nombre;
  int? contactoId;
  int? empleadoId;
  int? adminTipo;
  int? status;
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
      required this.creacion,
      this.actualizacion});

  UsuarioModel copyWith(
          {int? id,
          String? uuid, // Cambiado de int? a String?
          String? nombre,
          int? contactoId,
          int? empleadoId,
          int? adminTipo,
          int? status,
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
          creacion: creacion ?? this.creacion,
          actualizacion: actualizacion ?? this.actualizacion);

  factory UsuarioModel.fromJson(Map<String, dynamic> json) => UsuarioModel(
      id: json["id"],
      uuid: json["uuid"],
      nombre: json["nombre"],
      contactoId: json["contacto_id"],
      empleadoId: json["empleado_id"],
      adminTipo: json["admin_tipo"],
      status: Parser.toInt(json["status"]),
      creacion: DateTime.tryParse(json["creacion"]),
      actualizacion: DateTime.tryParse(json["actualizacion"]) ??
          DateTime.now());

  Map<String, dynamic> toJson() => {
        "id": id,
        "uuid": uuid,
        "nombre": nombre,
        "contacto_id": contactoId,
        "empleado_id": empleadoId,
        "admin_tipo": adminTipo,
        "status": status,
        "creacion": creacion?.toIso8601String(),
        "actualizacion": actualizacion?.toIso8601String()
      };
}
