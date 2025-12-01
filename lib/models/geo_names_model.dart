class GeoNamesModel {
  String adminCode1;
  String lng;
  String lat;
  int geonameId;
  String toponymName;
  String countryId;
  String fcl;
  int population;
  String countryCode;
  String name;
  String fclName;
  String countryName;
  String fcodeName;
  String adminName1;

  GeoNamesModel(
      {required this.adminCode1,
      required this.lng,
      required this.lat,
      required this.geonameId,
      required this.toponymName,
      required this.countryId,
      required this.fcl,
      required this.population,
      required this.countryCode,
      required this.name,
      required this.fclName,
      required this.countryName,
      required this.fcodeName,
      required this.adminName1});

  GeoNamesModel copyWith(
          {String? adminCode1,
          String? lng,
          String? lat,
          int? geonameId,
          String? toponymName,
          String? countryId,
          String? fcl,
          int? population,
          String? countryCode,
          String? name,
          String? fclName,
          String? countryName,
          String? fcodeName,
          String? adminName1}) =>
      GeoNamesModel(
          adminCode1: adminCode1 ?? this.adminCode1,
          lng: lng ?? this.lng,
          lat: lat ?? this.lat,
          geonameId: geonameId ?? this.geonameId,
          toponymName: toponymName ?? this.toponymName,
          countryId: countryId ?? this.countryId,
          fcl: fcl ?? this.fcl,
          population: population ?? this.population,
          countryCode: countryCode ?? this.countryCode,
          name: name ?? this.name,
          fclName: fclName ?? this.fclName,
          countryName: countryName ?? this.countryName,
          fcodeName: fcodeName ?? this.fcodeName,
          adminName1: adminName1 ?? this.adminName1);

  factory GeoNamesModel.fromJson(Map<String, dynamic> json) => GeoNamesModel(
      adminCode1: json["adminCode1"],
      lng: json["lng"],
      lat: json["lat"],
      geonameId: json["geonameId"],
      toponymName: json["toponymName"],
      countryId: json["countryId"],
      fcl: json["fcl"],
      population: json["population"],
      countryCode: json["countryCode"],
      name: json["name"],
      fclName: json["fclName"],
      countryName: json["countryName"],
      fcodeName: json["fcodeName"],
      adminName1: json["adminName1"]);

  Map<String, dynamic> toJson() => {
        "adminCode1": adminCode1,
        "lng": lng,
        "lat": lat,
        "geonameId": geonameId,
        "toponymName": toponymName,
        "countryId": countryId,
        "fcl": fcl,
        "population": population,
        "countryCode": countryCode,
        "name": name,
        "fclName": fclName,
        "countryName": countryName,
        "fcodeName": fcodeName,
        "adminName1": adminName1
      };
}
