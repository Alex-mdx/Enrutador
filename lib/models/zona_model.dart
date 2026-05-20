import 'dart:convert';

class ZonasModel {
  final int id;
  final String nombre;
  final String? notas;
  final List<List<String>> latlongs;

  ZonasModel(
      {required this.id,
      required this.nombre,
      this.notas,
      required this.latlongs});

  ZonasModel copyWith(
          {int? id,
          String? nombre,
          String? notas,
          List<List<String>>? latlongs}) =>
      ZonasModel(
          id: id ?? this.id,
          nombre: nombre ?? this.nombre,
          notas: notas ?? this.notas,
          latlongs: latlongs ?? this.latlongs);

  factory ZonasModel.fromJson(Map<String, dynamic> json) {
    dynamic rawLatlongs = json["latlongs"];
    if (rawLatlongs is String) {
      rawLatlongs = jsonDecode(rawLatlongs);
    }

    return ZonasModel(
        id: json["id"],
        nombre: json["nombre"],
        notas: json["notas"],
        latlongs: rawLatlongs == null
            ? []
            : List<List<String>>.from((rawLatlongs as List).map((x) =>
                List<String>.from(
                    (x as List).map((y) => (y as String))))));
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "nombre": nombre,
        "notas": notas,
        "latlongs": latlongs.map((x) => x.map((y) => y).toList()).toList()
      };

  Map<String, dynamic> toFire() => {
        "id": id,
        "nombre": nombre,
        "notas": notas,
        "latlongs":
            latlongs.map((x) => x.map((y) => y).toList()).toList(),
      };
}
