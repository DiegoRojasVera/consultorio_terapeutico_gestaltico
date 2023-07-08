import 'dart:convert';

import 'package:consultorio_terapeutico_gestaltico/models/stylist.dart';

Service serviceFromJson(String str) => Service.fromDetailJson(json.decode(str));

String serviceToJson(Service data) => json.encode(data.toDetailJson());

class Service {
  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.stylists,
    this.availableTimes = const [], // Lista de horarios disponibles
    this.bookedTimes = const [], // Lista de horarios ocupados
    this.occupiedTimes =
        const [], // Agrega esta línea para definir la propiedad
  });

  int id;
  String name;
  double price;
  int categoryId;
  List<Stylist> stylists;
  List<DateTime> availableTimes; // Lista de horarios disponibles
  List<DateTime> bookedTimes; // Lista de horarios ocupados
  List<DateTime> occupiedTimes; // Agrega esta línea para definir la propiedad

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        name: json["name"],
        price: json["price"].toDouble(),
        categoryId: json["category_id"],
        stylists: [],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "category_id": categoryId,
      };

  factory Service.fromDetailJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        name: json["name"],
        price: json["price"].toDouble(),
        categoryId: json["category_id"],
        stylists: List<Stylist>.from(
            json["stylists"].map((x) => Stylist.fromJson(x))),
        availableTimes: [],
        // Inicialmente no hay horarios disponibles
        bookedTimes: [], // Inicialmente no hay horarios ocupados
      );

  Map<String, dynamic> toDetailJson() => {
        "id": id,
        "name": name,
        "price": price,
        "category_id": categoryId,
        "stylists": List<dynamic>.from(stylists.map((x) => x.toJson())),
      };
}
