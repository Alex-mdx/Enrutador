import 'dart:convert';

import 'package:enrutador/utilities/funcion_parser.dart';
import 'package:enrutador/utilities/textos.dart';

import 'referencia_model.dart';

class ContactoModelo {
  int? id;
  String? nombreCompleto;
  double latitud;
  double longitud;
  String? domicilio;
  DateTime? fechaDomicilio;
  int? numero;
  DateTime? numeroFecha;
  int? otroNumero;
  DateTime? otroNumeroFecha;
  DateTime? agendar;
  int? tipo;
  DateTime? tipoFecha;
  int? estado;
  DateTime? estadoFecha;
  String? foto;
  DateTime? fotoFecha;
  String? fotoReferencia;
  DateTime? fotoReferenciaFecha;
  String? what3Words;
  String? nota;
  String? uuid;
  String? uuidFoto;
  String? uuidFotoReferencia;
  String? uuidDomicilio;
  String? uuidNumero;
  String? uuidOtroNumero;
  String? uuidTipo;
  String? uuidEstado;
  int? status;
  int? pendiente;
  String? aceptadoUuid;
  DateTime? creado;
  DateTime? modificado;

  ContactoModelo(
      {this.id,
      required this.nombreCompleto,
      required this.latitud,
      required this.longitud,
      required this.domicilio,
      required this.fechaDomicilio,
      required this.numero,
      required this.numeroFecha,
      required this.otroNumero,
      required this.otroNumeroFecha,
      required this.agendar,
      required this.tipo,
      required this.tipoFecha,
      required this.estado,
      required this.estadoFecha,
      required this.foto,
      required this.fotoFecha,
      required this.fotoReferencia,
      required this.fotoReferenciaFecha,
      required this.what3Words,
      required this.nota,
      this.pendiente,
      this.aceptadoUuid,
      this.uuid,
      this.uuidFoto,
      this.uuidFotoReferencia,
      this.uuidDomicilio,
      this.uuidNumero,
      this.uuidOtroNumero,
      this.uuidTipo,
      this.uuidEstado,
      this.status,
      this.creado,
      this.modificado});

  ContactoModelo copyWith(
          {int? id,
          String? nombreCompleto,
          double? latitud,
          double? longitud,
          String? domicilio,
          DateTime? fechaDomicilio,
          int? numero,
          DateTime? numeroFecha,
          int? otroNumero,
          DateTime? otroNumeroFecha,
          DateTime? agendar,
          List<ReferenciaModelo>? contactoEnlances,
          int? tipo,
          DateTime? tipoFecha,
          int? estado,
          DateTime? estadoFecha,
          String? foto,
          DateTime? fotoFecha,
          String? fotoReferencia,
          DateTime? fotoReferenciaFecha,
          String? what3Words,
          String? nota,
          int? pendiente,
          String? aceptadoUuid,
          String? uuid,
          String? uuidFoto,
          String? uuidFotoReferencia,
          String? uuidDomicilio,
          String? uuidNumero,
          String? uuidOtroNumero,
          String? uuidTipo,
          String? uuidEstado,
          int? status,
          DateTime? creado,
          DateTime? modificado  }) =>
      ContactoModelo(
          id: id ?? this.id,
          nombreCompleto: nombreCompleto ?? this.nombreCompleto,
          latitud: latitud ?? this.latitud,
          longitud: longitud ?? this.longitud,
          domicilio: domicilio ?? this.domicilio,
          fechaDomicilio: fechaDomicilio ?? this.fechaDomicilio,
          numero: numero ?? this.numero,
          numeroFecha: numeroFecha ?? this.numeroFecha,
          otroNumero: otroNumero ?? this.otroNumero,
          otroNumeroFecha: otroNumeroFecha ?? this.otroNumeroFecha,
          agendar: agendar,
          tipo: tipo ?? this.tipo,
          tipoFecha: tipoFecha ?? this.tipoFecha,
          estado: estado ?? this.estado,
          estadoFecha: estadoFecha ?? this.estadoFecha,
          foto: foto ?? this.foto,
          uuidFoto: uuidFoto ?? this.uuidFoto,
          fotoFecha: fotoFecha ?? this.fotoFecha,
          uuidFotoReferencia: uuidFotoReferencia ?? this.uuidFotoReferencia,
          uuidDomicilio: uuidDomicilio ?? this.uuidDomicilio,
          uuidNumero: uuidNumero ?? this.uuidNumero,
          uuidOtroNumero: uuidOtroNumero ?? this.uuidOtroNumero,
          uuidTipo: uuidTipo ?? this.uuidTipo,
          uuidEstado: uuidEstado ?? this.uuidEstado,
          fotoReferencia: fotoReferencia ?? this.fotoReferencia,
          fotoReferenciaFecha: fotoReferenciaFecha ?? this.fotoReferenciaFecha,
          what3Words: what3Words ?? this.what3Words,
          nota: nota ?? this.nota,
          pendiente: pendiente ?? this.pendiente,
          aceptadoUuid: aceptadoUuid ?? this.aceptadoUuid,
          uuid: uuid ?? this.uuid,
          status: status ?? this.status,
          creado: creado ?? this.creado,
          modificado: modificado ?? this.modificado);

  factory ContactoModelo.fromJson(Map<String, dynamic> json) => ContactoModelo(
      id: json["id"],
      nombreCompleto: json["nombre_completo"],
      latitud: double.parse(
          double.parse(json["latitud"].toString()).toStringAsFixed(6)),
      longitud: double.parse(
          double.parse(json["longitud"].toString()).toStringAsFixed(6)),
      domicilio: json["domicilio"],
      fechaDomicilio: DateTime.tryParse(json["fecha_domicilio"].toString()),
      numero: Parser.toInt(json["numero"]),
      numeroFecha: DateTime.tryParse(json["numero_fecha"].toString()),
      otroNumero: Parser.toInt(json["otro_numero"]),
      otroNumeroFecha: DateTime.tryParse(json["otro_numero_fecha"].toString()),
      agendar: DateTime.tryParse(json["agendar"].toString()),
      tipo: json["tipo"],
      tipoFecha: DateTime.tryParse(json["tipo_fecha"].toString()),
      estado: json["estado"],
      estadoFecha: DateTime.tryParse(json["estado_fecha"].toString()),
      foto: json["foto"],
      uuidFoto: json["uuid_foto"],
      fotoFecha: DateTime.tryParse(json["foto_fecha"].toString()),
      fotoReferencia: json["foto_referencia"],
      uuidFotoReferencia: json["uuid_foto_referencia"],
      fotoReferenciaFecha:
          DateTime.tryParse(json["foto_referencia_fecha"].toString()),
      uuidDomicilio: json["uuid_domicilio"],
      uuidNumero: json["uuid_numero"],
      uuidOtroNumero: json["uuid_otro_numero"],
      uuidTipo: json["uuid_tipo"],
      uuidEstado: json["uuid_estado"],
      what3Words: json["what_3_words"],
      nota: json["nota"],
      pendiente: Parser.toInt(json["pendiente"]),
      aceptadoUuid: json["aceptado_uuid"],
      uuid: json["uuid"],
      status: Parser.toInt(json["status"]),
      creado: DateTime.tryParse(json["creado"].toString()),
      modificado: DateTime.now());

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre_completo": nombreCompleto,
        "latitud": latitud,
        "longitud": longitud,
        "domicilio": domicilio,
        "fecha_domicilio": fechaDomicilio == null
            ? null
            : Textos.fechaYMDHMS(fecha: fechaDomicilio!),
        "numero": numero,
        "numero_fecha": numeroFecha == null
            ? null
            : Textos.fechaYMDHMS(fecha: numeroFecha!),
        "otro_numero": otroNumero,
        "otro_numero_fecha": otroNumeroFecha == null
            ? null
            : Textos.fechaYMDHMS(fecha: otroNumeroFecha!),
        "agendar": agendar == null ? null : Textos.fechaYMD(fecha: agendar!),
        "tipo": tipo,
        "tipo_fecha":
            tipoFecha == null ? null : Textos.fechaYMDHMS(fecha: tipoFecha!),
        "estado": estado,
        "estado_fecha": estadoFecha == null
            ? null
            : Textos.fechaYMDHMS(fecha: estadoFecha!),
        "foto": foto,
        "foto_fecha":
            fotoFecha == null ? null : Textos.fechaYMDHMS(fecha: fotoFecha!),
        "foto_referencia": fotoReferencia,
        "foto_referencia_fecha": fotoReferenciaFecha == null
            ? null
            : Textos.fechaYMDHMS(fecha: fotoReferenciaFecha!),
        "uuid_foto": uuidFoto,
        "uuid_foto_referencia": uuidFotoReferencia,
        "uuid_domicilio": uuidDomicilio,
        "uuid_numero": uuidNumero,
        "uuid_otro_numero": uuidOtroNumero,
        "uuid_tipo": uuidTipo,
        "uuid_estado": uuidEstado,
        "what_3_words": what3Words,
        "nota": nota,
        "uuid": uuid,
        "status": status,
        "pendiente": pendiente ?? 0,
        "aceptado_uuid": aceptadoUuid,
        "creado": creado?.toIso8601String(),
        "modificado": modificado?.toIso8601String()
      };
  static List<ReferenciaModelo> generar1(String texto) {
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
