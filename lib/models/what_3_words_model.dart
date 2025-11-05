class What3WordsModel {
  String country;
  String nearestPlace;
  String words;
  String? distanceToFocusKm;
  int rank;
  String language;
  String locale;

  What3WordsModel(
      {required this.country,
      required this.nearestPlace,
      required this.words,
      required this.distanceToFocusKm,
      required this.rank,
      required this.language,
      required this.locale});

  What3WordsModel copyWith(
          {String? country,
          String? nearestPlace,
          String? words,
          String? distanceToFocusKm,
          int? rank,
          String? language,
          String? locale}) =>
      What3WordsModel(
          country: country ?? this.country,
          nearestPlace: nearestPlace ?? this.nearestPlace,
          words: words ?? this.words,
          distanceToFocusKm: distanceToFocusKm ?? this.distanceToFocusKm,
          rank: rank ?? this.rank,
          language: language ?? this.language,
          locale: locale ?? this.locale);

  factory What3WordsModel.fromJson(Map<String, dynamic> json) =>
      What3WordsModel(
          country: json["country"],
          nearestPlace: json["nearestPlace"],
          words: json["words"],
          distanceToFocusKm: json["distanceToFocusKm"],
          rank: json["rank"],
          language: json["language"],
          locale: json["locale"]);

  Map<String, dynamic> toJson() => {
        "country": country,
        "nearestPlace": nearestPlace,
        "words": words,
        "distanceToFocusKm": distanceToFocusKm,
        "rank": rank,
        "language": language,
        "locale": locale
      };
}
