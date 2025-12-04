class GeoPostalModel {
  String adminCode2;
  String adminCode1;
  String? adminName2;
  double lat;
  double lng;
  String countryCode;
  String postalCode;
  String? adminName1;
  String? iso31662;
  String placeName;

  GeoPostalModel(
      {required this.adminCode2,
      required this.adminCode1,
      required this.adminName2,
      required this.lat,
      required this.lng,
      required this.countryCode,
      required this.postalCode,
      required this.adminName1,
      required this.iso31662,
      required this.placeName});

  GeoPostalModel copyWith(
          {String? adminCode2,
          String? adminCode1,
          String? adminName2,
          double? lat,
          double? lng,
          String? countryCode,
          String? postalCode,
          String? adminName1,
          String? iso31662,
          String? placeName}) =>
      GeoPostalModel(
          adminCode2: adminCode2 ?? this.adminCode2,
          adminCode1: adminCode1 ?? this.adminCode1,
          adminName2: adminName2 ?? this.adminName2,
          lat: lat ?? this.lat,
          lng: lng ?? this.lng,
          countryCode: countryCode ?? this.countryCode,
          postalCode: postalCode ?? this.postalCode,
          adminName1: adminName1 ?? this.adminName1,
          iso31662: iso31662 ?? this.iso31662,
          placeName: placeName ?? this.placeName);

  factory GeoPostalModel.fromJson(Map<String, dynamic> json) => GeoPostalModel(
      adminCode2: json["adminCode2"],
      adminCode1: json["adminCode1"],
      adminName2: json["adminName2"],
      lat: json["lat"]?.toDouble(),
      lng: json["lng"]?.toDouble(),
      countryCode: json["countryCode"],
      postalCode: json["postalCode"],
      adminName1: json["adminName1"],
      iso31662: json["ISO3166-2"],
      placeName: json["placeName"]);

  Map<String, dynamic> toJson() => {
        "adminCode2": adminCode2,
        "adminCode1": adminCode1,
        "adminName2": adminName2,
        "lat": lat,
        "lng": lng,
        "countryCode": countryCode,
        "postalCode": postalCode,
        "adminName1": adminName1,
        "ISO3166-2": iso31662,
        "placeName": placeName
      };
}
