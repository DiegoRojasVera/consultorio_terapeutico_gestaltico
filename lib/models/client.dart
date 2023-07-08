import 'dart:convert';

List<Client> clientFromJson(String str) =>
    List<Client>.from(json.decode(str).map((x) => Client.fromJson(x)));

String clientToJson(List<Client> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class Client {
  Client({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.inicio,
    required this.stylist,
    required this.service,
    required this.appointments,
  });

  int id;
  String name;
  String phone;
  String email;
  String inicio;
  String stylist;
  String service;
  List<Appointment> appointments;

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json["id"],
      name: json["name"],
      phone: json["phone"],
      email: json["email"],
      inicio: json["inicio"],
      stylist: json["stylist"],
      service: json["service"],
      appointments: List<Appointment>.from(
          json["appointments"].map((x) => Appointment.fromJson(x))),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "phone": phone,
        "email": email,
        "inicio": inicio,
        "stylist": stylist,
        "service": service,
        "appointments": List<dynamic>.from(appointments.map((x) => x.toJson())),
      };
}

class Appointment {
  Appointment({
    required this.id,
    required this.datedAt,
    required this.finishAt,
    required this.total,
    required this.duration,
    required this.clientId,
    required this.email,
    required this.serviceId,
    required this.stylistId,
    required this.createdAt,
    required this.updatedAt,
    required this.stylist,
    required this.service,
  });

  int id;
  DateTime datedAt;
  DateTime finishAt;
  int total;
  int duration;
  int clientId;
  String email;
  int serviceId;
  int stylistId;
  DateTime createdAt;
  DateTime updatedAt;
  Stylist stylist;
  Service service;

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json["id"],
      datedAt: DateTime.parse(json["dated_at"]),
      finishAt: DateTime.parse(json["finish_at"]),
      total: json["total"],
      duration: json["duration"],
      clientId: json["client_id"],
      email: json["email"],
      serviceId: json["service_id"],
      stylistId: json["stylist_id"],
      createdAt: DateTime.parse(json["created_at"]),
      updatedAt: DateTime.parse(json["updated_at"]),
      stylist: Stylist.fromJson(json["stylist"]),
      service: Service.fromJson(json["service"]),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "dated_at": datedAt.toIso8601String(),
        "finish_at": finishAt.toIso8601String(),
        "total": total,
        "duration": duration,
        "client_id": clientId,
        "email": email,
        "service_id": serviceId,
        "stylist_id": stylistId,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "stylist": stylist.toJson(),
        "service": service.toJson(),
      };
}

class Service {
  Service({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
  });

  int id;
  String name;
  int price;
  int categoryId;

  factory Service.fromJson(Map<String, dynamic> json) => Service(
        id: json["id"],
        name: json["name"],
        price: json["price"],
        categoryId: json["category_id"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "price": price,
        "category_id": categoryId,
      };
}

class Stylist {
  Stylist({
    required this.id,
    required this.name,
    required this.photo,
    required this.score,
  });

  int id;
  String? name;
  String? photo;
  double? score;

  factory Stylist.fromJson(Map<String, dynamic> json) => Stylist(
        id: json["id"],
        name: json["name"],
        photo: json["photo"],
        score: json["score"].toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "photo": photo,
        "score": score,
      };
}


