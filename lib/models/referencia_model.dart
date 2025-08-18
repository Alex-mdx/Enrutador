import 'package:enrutador/utilities/funcion_parser.dart';

class ReferenciaModelo {
  double contactoIdLat;
  double contactoIdLng;
  double? contactoIdRLat;
  double? contactoIdRLng;
  int buscar;
  int? tipoCliente;
  int? estatus;
  DateTime? fecha;

  ReferenciaModelo(
      {required this.contactoIdLat,
      required this.contactoIdLng,
      required this.contactoIdRLat,
      required this.contactoIdRLng,
      required this.buscar,
      required this.tipoCliente,
      required this.estatus,
      required this.fecha});

  ReferenciaModelo copyWith(
          {double? contactoIdLat,
          double? contactoIdLng,
          double? contactoIdRLat,
          double? contactoIdRLng,
          int? buscar,
          int? tipoCliente,
          int? estatus,
          DateTime? fecha}) =>
      ReferenciaModelo(
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
          contactoIdLat: double.tryParse(json["contacto_id_lat"]) ?? 1,
          contactoIdLng: double.tryParse(json["contacto_id_lng"]) ?? 1,
          contactoIdRLat: double.tryParse(json["contacto_id_r_lat"]),
          contactoIdRLng: double.tryParse(json["contacto_id_r_lng"]),
          buscar: Parser.toInt(json["buscar"]) ?? -1,
          tipoCliente: Parser.toInt(json["tipo_cliente"]),
          estatus: Parser.toInt(json["estatus"]),
          fecha: DateTime.tryParse(json["fecha"]));

  Map<String, dynamic> toJson() => {
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
