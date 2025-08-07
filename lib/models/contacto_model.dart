import 'package:enrutador/utilities/textos.dart';

class ContactoModelo {
  int id;
  String? nombreCompleto;
  double latitud;
  double longitud;
  String? domicilio;
  DateTime? fechaDomicilio;
  int? numero;
  DateTime? numeroFecha;
  DateTime? agendar;
  List<int> contactoEnlances;
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

  ContactoModelo(
      {required this.id,
      required this.nombreCompleto,
      required this.latitud,
      required this.longitud,
      required this.domicilio,
      required this.fechaDomicilio,
      required this.numero,
      required this.numeroFecha,
      required this.agendar,
      required this.contactoEnlances,
      required this.tipo,
      required this.tipoFecha,
      required this.estado,
      required this.estadoFecha,
      required this.foto,
      required this.fotoFecha,
      required this.fotoReferencia,
      required this.fotoReferenciaFecha,
      required this.what3Words,
      required this.nota});

  ContactoModelo copyWith(
          {int? id,
          String? nombreCompleto,
          double? latitud,
          double? longitud,
          String? domicilio,
          DateTime? fechaDomicilio,
          int? numero,
          DateTime? numeroFecha,
          DateTime? agendar,
          List<int>? contactoEnlances,
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
          DateTime? creado,
          DateTime? actual}) =>
      ContactoModelo(
          id: id ?? this.id,
          nombreCompleto: nombreCompleto ?? this.nombreCompleto,
          latitud: latitud ?? this.latitud,
          longitud: longitud ?? this.longitud,
          domicilio: domicilio ?? this.domicilio,
          fechaDomicilio: fechaDomicilio ?? this.fechaDomicilio,
          numero: numero ?? this.numero,
          numeroFecha: numeroFecha ?? this.numeroFecha,
          agendar: agendar ?? this.agendar,
          contactoEnlances: contactoEnlances ?? this.contactoEnlances,
          tipo: tipo ?? this.tipo,
          tipoFecha: tipoFecha ?? this.tipoFecha,
          estado: estado ?? this.estado,
          estadoFecha: estadoFecha ?? this.estadoFecha,
          foto: foto ?? this.foto,
          fotoFecha: fotoFecha ?? this.fotoFecha,
          fotoReferencia: fotoReferencia ?? this.fotoReferencia,
          fotoReferenciaFecha: fotoReferenciaFecha ?? this.fotoReferenciaFecha,
          what3Words: what3Words ?? this.what3Words,
          nota: nota ?? this.nota);

  factory ContactoModelo.fromJson(Map<String, dynamic> json) => ContactoModelo(
      id: json["id"],
      nombreCompleto: json["nombre_completo"],
      latitud: double.parse(double.parse(json["latitud"]).toStringAsFixed(6)),
      longitud: double.parse(double.parse(json["longitud"]).toStringAsFixed(6)),
      domicilio: json["domicilio"],
      fechaDomicilio: DateTime.tryParse(json["fecha_domicilio"]),
      numero: json["numero"],
      numeroFecha: DateTime.tryParse(json["numero_fecha"]),
      agendar: DateTime.tryParse(json["agendar"]),
      contactoEnlances: List<int>.from(json["contacto_enlances"].map((x) => x)),
      tipo: json["tipo"],
      tipoFecha: DateTime.tryParse(json["tipo_fecha"]),
      estado: json["estado"],
      estadoFecha: DateTime.tryParse(json["estado_fecha"]),
      foto: json["foto"],
      fotoFecha: DateTime.parse(json["foto_fecha"]),
      fotoReferencia: json["foto_referencia"],
      fotoReferenciaFecha: DateTime.parse(json["foto_referencia_fecha"]),
      what3Words: json["what_3_words"],
      nota: json["nota"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre_completo": nombreCompleto,
        "latitud": latitud,
        "longitud": longitud,
        "domicilio": domicilio,
        "fecha_domicilio": fechaDomicilio?.toIso8601String(),
        "numero": numero,
        "numero_fecha": numeroFecha?.toIso8601String(),
        "agendar": agendar == null ? null : Textos.fechaYMD(fecha: agendar!),
        "contacto_enlances": List<int>.from(contactoEnlances.map((x) => x)),
        "tipo": tipo,
        "tipo_fecha": tipoFecha?.toIso8601String(),
        "estado": estado,
        "estado_fecha": estadoFecha?.toIso8601String(),
        "foto": foto,
        "foto_fecha": fotoFecha?.toIso8601String(),
        "foto_referencia": fotoReferencia,
        "foto_referencia_fecha": fotoReferenciaFecha?.toIso8601String(),
        "what_3_words": what3Words,
        "nota": nota
      };
}
