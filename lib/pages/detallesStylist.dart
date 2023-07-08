import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;

import '../models/client.dart';
import '../utils/utils.dart';

class DetailPage extends StatefulWidget {
  final int stylistId;
  final String stylistName;

  const DetailPage(
      {Key? key, required this.stylistId, required this.stylistName})
      : super(key: key);

  @override
  _DetailPageState createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  Stylist? _stylist;

  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadStylistDetails();
    getDataService_stylist();
    listarcalificaciones();
  }

  Future<List> getDataService_stylist() async {
    final response = await http.get(
      Uri.parse(
          "http://34.171.207.241/proyecto1/api/servicestylistall/${widget.stylistId}"),
    );
    print("-.--------getDataService_stylist-s-s-");

    return json.decode(response.body);
  }

  Future<List> listarcalificaciones() async {
    final response = await http.get(
      Uri.parse(
          "http://34.171.207.241/proyecto1/api/puntuacion/stylist/${widget.stylistName}"),
    );

    print("-.--------listarcalificacioness-s-s-");
    return json.decode(response.body);
  }

  Future<void> _loadStylistDetails() async {
    try {
      final response = await http.get(
          Uri.parse("http://34.171.207.241/proyecto1/api/stylist/${widget.stylistId}"));
      if (response.statusCode == 200) {
        final dynamic data = json.decode(response.body);
        if (data is Map<String, dynamic>) {
          setState(() {
            _stylist = Stylist.fromJson(data);
          });
        } else if (data is List<dynamic> && data.isNotEmpty) {
          setState(() {
            _stylist = Stylist.fromJson(data[0]);
          });
        } else {
          setState(() {
            _errorMessage = "Unexpected response format: $data";
          });
        }
      } else {
        setState(() {
          _errorMessage =
              "Error ${response.statusCode}: ${response.reasonPhrase}";
        });
      }
    } catch (error) {
      setState(() {
        _errorMessage = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            _stylist?.name ?? '',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          backgroundColor: Utils.primaryColor,
          systemOverlayStyle: SystemUiOverlayStyle.dark,
        ),
        body: _errorMessage != null
            ? Center(
                child: Text(_errorMessage!),
              )
            : _stylist == null
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Utils.secondaryColor)))
                : SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Center(
                            child: CircleAvatar(
                              radius: 48,
                              backgroundColor: Colors.grey, // Image radius
                              backgroundImage: NetworkImage(
                                _stylist!.photo.toString(),
                              ),
                            ),
                          ),
                          const Divider(),
                          SizedBox(
                            height: 50,
                            child: Column(
                              children: [
                                Expanded(
                                  child: FutureBuilder<String>(
                                    future: getDataCalificacion(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<String> snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const Center(
                                          child: CircularProgressIndicator(
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                              Utils.secondaryColor,
                                            ),
                                          ),
                                        );
                                      }
                                      if (snapshot.hasError) {
                                        return Center(
                                            child: Text(
                                                'Error: ${snapshot.error}'));
                                      }
                                      String? data = snapshot.data ?? '0';

                                      if (data is String) {
                                        double initialRating = 0;
                                        if (data != null && data.isNotEmpty) {
                                          initialRating =
                                              double.tryParse(data) ?? 0;
                                        }
                                        return SingleChildScrollView(
                                          child: Column(
                                            children: [
                                              RatingBar.builder(
                                                itemCount: 5,
                                                initialRating: initialRating,
                                                allowHalfRating: true,
                                                itemSize: 30,
                                                ignoreGestures: true,
                                                // Impide la interacción del usuario
                                                itemBuilder: (context, _) {
                                                  return const Icon(
                                                    Icons.star,
                                                    color: Colors.amber,
                                                  );
                                                },
                                                onRatingUpdate:
                                                    (rating) {}, // Función vacía que no hace nada
                                              ),
                                              const SizedBox(height: 2),
                                            ],
                                          ),
                                        );
                                      } else {
                                        return const Center(
                                            child: Text(
                                                'Error: Unexpected data format'));
                                      }
                                    },
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text(
                            "Realiza las siguentes funcioness: ",
                            textAlign: TextAlign.left,
                            style: TextStyle(fontSize: 20.0),
                          ),
                          const SizedBox(height: 10),
                          Column(
                            children: [
                              SizedBox(
                                height: 100,
                                child: Center(
                                  child: FutureBuilder<List>(
                                    future: getDataService_stylist(),
                                    builder: (context, idServicio) {
                                      if (idServicio.hasError) {
                                        if (kDebugMode) {
                                          print(idServicio.error);
                                        }
                                      }
                                      return idServicio.hasData
                                          ? ItemListSer(
                                              list: idServicio.data!,
                                            )
                                          : const Center(
                                              child: CircularProgressIndicator(
                                                valueColor:
                                                    AlwaysStoppedAnimation<
                                                            Color>(
                                                        Utils.secondaryColor),
                                              ),
                                            );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Column(
                            children: [
                              Text(
                                "Calificaciones: ",
                                style: TextStyle(
                                  fontSize: 18,
                                ),
                                textAlign: TextAlign.left,
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 400,
                            child: FutureBuilder<List>(
                              future: listarcalificaciones(),
                              builder: (context, idServicio) {
                                if (idServicio.hasError) {
                                  if (kDebugMode) {
                                    print(idServicio.error);
                                  }
                                }
                                return idServicio.hasData
                                    ? ItemLisCalificacion(
                                        list: idServicio.data!,
                                      )
                                    : const Center(
                                        child: CircularProgressIndicator(
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                  Utils.secondaryColor),
                                        ),
                                      );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ));
  }

  ListView ItemListSer({required List list}) {
    return ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, int id) {
        return Text(
          "Servicio: ${list[id]['nombre_servicio']}",
          style: const TextStyle(
            fontSize: 17,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }

  Column ItemLisCalificacion({required List list}) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            itemCount: list == null ? 0 : list.length,
            itemBuilder: (context, int id) {
              return Card(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Imagen del cliente a la izquierda
                      CircleAvatar(
                        radius: 30.0,
                        backgroundImage: NetworkImage("${list[id]['photo']}"),
                      ),
                      SizedBox(width: 16.0),
                      // Información del cliente a la derecha
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${list[id]['nombre']}",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20.0,
                              ),
                            ),
                            const SizedBox(height: 8.0),
                            RatingBar.builder(
                              initialRating: double.tryParse(
                                      "${list[id]['calificacion'] ?? 0}") ??
                                  0.0,
                              minRating: 1,
                              itemSize: 20,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemPadding:
                                  const EdgeInsets.symmetric(horizontal: 4.0),
                              itemBuilder: (context, _) => const Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              ignoreGestures: true,
                              // Impide la interacción del usuario
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                            const SizedBox(height: 8.0),
                            Text(
                              "${list[id]['comentario']}",
                              style: const TextStyle(
                                fontSize: 16.0,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<String> getDataCalificacion() async {
    String? nombre = widget.stylistName;
    final response = await http.get(
        Uri.parse("http://34.171.207.241/proyecto1/api/puntuacion/promedio/$nombre"));
    Map<String, dynamic> datos = json.decode(response.body);
    String promedio = datos["promedio"] ?? "0";
    return promedio;
  }

  Future<List> listarcalificacionesdelosclientes() async {
    String? nombre = widget.stylistName;

    final response = await http.get(
      Uri.parse("http://34.171.207.241/proyecto1/api/puntuacion/stylist/$nombre"),
    );

    print("-.--------listarcalificacioness-s-s-");
    return json.decode(response.body);
  }
}
