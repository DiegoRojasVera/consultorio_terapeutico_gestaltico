class Puntuacion {
  int? id;
  String? calificacion;
  String? stylist;
  String? comentario;
  String? nombre;
  String? photo;

  Puntuacion(
      {this.id,
      this.calificacion,
      this.stylist,
      this.comentario,
      this.nombre,
      this.photo});

  // function to convert json data to user model
  factory Puntuacion.fromJson(Map<String, dynamic> json) {
    return Puntuacion(
        id: json["id"],
        calificacion: json["calificacion"],
        stylist: json["stylist"],
        comentario: json["comentario"],
        nombre: json["nombre"],
        photo: json["photo"]);
  }
}
