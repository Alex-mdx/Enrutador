import 'package:enrutador/utilities/funcion_parser.dart';

class ReferenciaModelo {
  int id;
  int? idForanea;
  int? idRForenea;
  double contactoIdLat;
  double contactoIdLng;
  double? contactoIdRLat;
  double? contactoIdRLng;
  int buscar;
  int? tipoCliente;
  int? estatus;
  DateTime? fecha;

  ReferenciaModelo(
      {required this.id,
      required this.idForanea,
      required this.idRForenea,
      required this.contactoIdLat,
      required this.contactoIdLng,
      required this.contactoIdRLat,
      required this.contactoIdRLng,
      required this.buscar,
      required this.tipoCliente,
      required this.estatus,
      required this.fecha});

  ReferenciaModelo copyWith(
          {int? id,
          int? idForanea,
          int? idRForenea,
          double? contactoIdLat,
          double? contactoIdLng,
          double? contactoIdRLat,
          double? contactoIdRLng,
          int? buscar,
          int? tipoCliente,
          int? estatus,
          DateTime? fecha}) =>
      ReferenciaModelo(
          id: id ?? this.id,
          idForanea: idForanea ?? this.idForanea,
          idRForenea: idRForenea ?? this.idRForenea,
          contactoIdLat: contactoIdLat ?? this.contactoIdLat,
          contactoIdLng: contactoIdLng ?? this.contactoIdLng,
          contactoIdRLat: contactoIdRLat ?? this.contactoIdRLat,
          contactoIdRLng: contactoIdRLng ?? this.contactoIdRLng,
          buscar: buscar ?? this.buscar,
          tipoCliente: tipoCliente ?? this.tipoCliente,
          estatus: estatus ?? this.estatus,
          fecha: fecha ?? this.fecha);

  factory ReferenciaModelo.fromJson(Map<String, dynamic> json) =>
      ReferenciaModelo(
          id: json["id"],
          idForanea: json["id_foranea"],
          idRForenea: json["id_r_forenea"],
          contactoIdLat:
              double.tryParse(json["contacto_id_lat"].toString()) ?? 1,
          contactoIdLng:
              double.tryParse(json["contacto_id_lng"].toString()) ?? 1,
          contactoIdRLat: double.tryParse(json["contacto_id_r_lat"].toString()),
          contactoIdRLng: double.tryParse(json["contacto_id_r_lng"].toString()),
          buscar: Parser.toInt(json["buscar"]) ?? -1,
          tipoCliente: Parser.toInt(json["tipo_cliente"]),
          estatus: Parser.toInt(json["estatus"]),
          fecha: DateTime.tryParse(json["fecha"]));

  Map<String, dynamic> toJson() => {
        "id": id,
        "id_foranea": idForanea,
        "id_r_forenea": idRForenea,
        "contacto_id_lat": contactoIdLat,
        "contacto_id_lng": contactoIdLng,
        "contacto_id_r_lat": contactoIdRLat,
        "contacto_id_r_lng": contactoIdRLng,
        "buscar": buscar,
        "tipo_cliente": tipoCliente,
        "estatus": estatus,
        "fecha": fecha?.toIso8601String()
      };
}
