class ContactoModel {
  int id;
  String? nombreCompleto;
  double latitud;
  double longitud;
  String? domicilio;
  DateTime? agendar;
  int? numero;
  List<int> contactoEnlances;
  int? tipo;
  int? estado;
  String? foto;
  String? fotoReferencia;
  String? what3Words;
  String? nota;

  ContactoModel(
      {required this.id,
      required this.nombreCompleto,
      required this.latitud,
      required this.longitud,
      required this.domicilio,
      required this.agendar,
      required this.numero,
      required this.contactoEnlances,
      required this.tipo,
      required this.estado,
      required this.foto,
      required this.fotoReferencia,
      required this.what3Words,
      required this.nota});

  ContactoModel copyWith(
          {int? id,
          String? nombreCompleto,
          double? latitud,
          double? longitud,
          String? domicilio,
          DateTime? agendar,
          int? numero,
          List<int>? contactoEnlances,
          int? tipo,
          int? estado,
          String? foto,
          String? fotoReferencia,
          String? what3Words,
          String? nota}) =>
      ContactoModel(
          id: id ?? this.id,
          nombreCompleto: nombreCompleto ?? this.nombreCompleto,
          latitud: latitud ?? this.latitud,
          longitud: longitud ?? this.longitud,
          domicilio: domicilio ?? this.domicilio,
          numero: numero ?? this.numero,
          agendar: agendar ?? this.agendar,
          contactoEnlances: contactoEnlances ?? this.contactoEnlances,
          tipo: tipo ?? this.tipo,
          estado: estado ?? this.estado,
          foto: foto ?? this.foto,
          fotoReferencia: fotoReferencia ?? this.fotoReferencia,
          what3Words: what3Words ?? this.what3Words,
          nota: nota ?? this.nota);

  factory ContactoModel.fromJson(Map<String, dynamic> json) => ContactoModel(
      id: json["id"],
      nombreCompleto: json["nombre_completo"],
      latitud: double.parse(double.parse(json["latitud"]).toStringAsFixed(6)),
      longitud: double.parse(double.parse(json["longitud"]).toStringAsFixed(6)),
      domicilio: json["domicilio"],
      numero: json["numero"],
      agendar: DateTime.tryParse(json["agendar"]),
      contactoEnlances: List<int>.from(json["contacto_enlances"].map((x) => x)),
      tipo: json["tipo"],
      estado: json["estado"],
      foto: json["foto"],
      fotoReferencia: json["foto_referencia"],
      what3Words: json["what_3_words"],
      nota: json["nota"]);

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre_completo": nombreCompleto,
        "latitud": latitud.toStringAsFixed(6),
        "longitud": longitud.toStringAsFixed(6),
        "domicilio": domicilio,
        "numero": numero,
        "agendar": agendar?.toIso8601String(),
        "contacto_enlances": List<int>.from(contactoEnlances.map((x) => x)),
        "tipo": tipo,
        "estado": estado,
        "foto": foto,
        "foto_referencia": fotoReferencia,
        "what_3_words": what3Words,
        "nota": nota
      };
}
