class ArchivoModel {
  int? id;
  int? contactoId;
  String? nombre;
  String? archivo;
  DateTime? actualizacion;

  ArchivoModel(
      {this.id,
      required this.contactoId,
      required this.nombre,
      required this.archivo,this.actualizacion});

  ArchivoModel copyWith(
          {int? id,
          int? contactoId,
          String? nombre,
          String? archivo,
          DateTime? actualizacion}) =>
      ArchivoModel(
          id: id ?? this.id,
          contactoId: contactoId ?? this.contactoId,
          nombre: nombre ?? this.nombre,
          archivo: archivo ?? this.archivo,
          actualizacion: actualizacion ?? this.actualizacion);

  factory ArchivoModel.fromJson(Map<String, dynamic> json) => ArchivoModel(
      id: json["id"],
      contactoId: json["contacto_id"],
      nombre: json["nombre"],
      archivo: json["archivo"],
      actualizacion: DateTime.tryParse(json["actualizacion"]));

  Map<String, dynamic> toJson() => {
        "id": id,
        "contacto_id": contactoId,
        "nombre": nombre,
        "archivo": archivo,
        "actualizacion": actualizacion?.toIso8601String()
      };
}
