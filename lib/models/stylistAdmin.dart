class StylistAdmin {
  StylistAdmin({
    this.id,
    this.name,
    this.photo,
    this.score,
    this.phone,
    required this.lockedDates,
  });

  int? id;
  String? name;
  String? photo;
  String? phone;
  double? score;

  List<DateTime> lockedDates;

  factory StylistAdmin.fromJson(Map json) {
    return StylistAdmin(
      id: json["id"],
      name: json["name"],
      photo: json["photo"],
      phone: json["phone"],
      score: json["score"].toDouble(),
      lockedDates: List<DateTime>.from(
          json["locked_dates"].map((x) => DateTime.parse(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "photo": photo,
        "phone": phone,
        "score": score,
        "locked_dates":
            List<dynamic>.from(lockedDates.map((x) => x.toIso8601String())),
      };
}
