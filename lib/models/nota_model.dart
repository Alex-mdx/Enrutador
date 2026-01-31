class NotaModel {
  int? id;
  int contactoId;
  String descripcion;
  String empleadoId;
  int pendiente;
  DateTime creado;

  NotaModel(
      {this.id,
      required this.contactoId,
      required this.descripcion,
      required this.empleadoId,
      required this.pendiente,
      required this.creado});

  NotaModel copyWith(
          {int? id,
          int? contactoId,
          String? descripcion,
          String? empleadoId,
          int? pendiente,
          DateTime? creado}) =>
      NotaModel(
          id: id ?? this.id,
          contactoId: contactoId ?? this.contactoId,
          descripcion: descripcion ?? this.descripcion,
          empleadoId: empleadoId ?? this.empleadoId,
          pendiente: pendiente ?? this.pendiente,
          creado: creado ?? this.creado);

  factory NotaModel.fromJson(Map<String, dynamic> json) => NotaModel(
      id: json["id"],
      contactoId: json["contacto_id"],
      descripcion: json["descripcion"],
      empleadoId: json["empleado_id"],
      pendiente: json["pendiente"],
      creado: DateTime.parse(json["creado"]));

  Map<String, dynamic> toJson() => {
        "id": id,
        "contacto_id": contactoId,
        "descripcion": descripcion,
        "empleado_id": empleadoId,
        "pendiente": pendiente,
        "creado": creado.toIso8601String()
      };
}
