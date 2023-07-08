import 'package:consultorio_terapeutico_gestaltico/models/service.dart';
import 'dart:convert';
//     final category = categoriesFromJson(jsonString);

List<Category> categoriesFromJson(String str) =>
    List<Category>.from(json.decode(str).map((x) => Category.fromJson(x)));

String categoryToJson(List<Category> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Category {
  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.photo,
    required this.services,
  });

  int id;
  String name;
  String icon;
  String photo;
  List<Service> services;

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        name: json["name"],
        icon: json["icon"],
        photo: json["photo"],
        services: List<Service>.from(
            json["services"].map((x) => Service.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "icon": icon,
        "photo": photo,
        "services": List<dynamic>.from(services.map((x) => x.toJson())),
      };
}
