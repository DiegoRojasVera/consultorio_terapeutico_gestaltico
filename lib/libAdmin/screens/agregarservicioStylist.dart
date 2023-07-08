import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';
import '../../controllers/databasehelper.dart';
import '../../utils/utils.dart';

class AgregarServicioStylist extends StatefulWidget {
  List list;
  int index;

  AgregarServicioStylist({super.key, required this.index, required this.list});

  @override
  _AgregarServicioStylistState createState() => _AgregarServicioStylistState();
}

class _AgregarServicioStylistState extends State<AgregarServicioStylist> {
  DataBaseHelper databaseHelper = DataBaseHelper();
  late String? id = widget.list[widget.index]
      ['id']; // con este caso el numero del stylista para buscar
  List? data;

  Future<List> getDataStylist() async {
    final response =
        await http.get(Uri.parse("http://34.171.207.241/proyecto1/api/stylist/$id"));
    return json.decode(response.body);
  }

  Future<List> getDataService_stylist() async {
    final response = await http
        .get(Uri.parse("http://34.171.207.241/proyecto1/api/servicestylistall/$id"));
    return json.decode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.list[widget.index]['id'].toString();

    getDataStylist();
    getDataStylist();
    if (kDebugMode) {
      print(id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.list[widget.index]['name']}"),
        backgroundColor: Utils.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: FutureBuilder<List>(
        future: getDataStylist(),
        builder: (context, snapshot) {
          if (snapshot.hasError) if (kDebugMode) {
            print(snapshot.error);
          }
          return snapshot.hasData
              ? ItemList(list: snapshot.data!)
              : const Center(
                  child: CircularProgressIndicator(
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Utils.secondaryColor),
                  ),
                );
        },
      ),
    );
  }

  ListView ItemList({required List list}) {
    return ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, id) {
        return Container(
          height: 500,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 30.0),
                ),
                Center(
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey, // Image radius
                    backgroundImage: NetworkImage(
                        widget.list[widget.index]['photo'].toString()),
                  ),
                ),
                const Divider(),
                Text(
                  "Nombre : ${widget.list[widget.index]['name']}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18.0),
                ),
                Text(
                  "Teléfono : ${widget.list[widget.index]['phone']}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 50,
                  child: Center(
                    child: FutureBuilder<List>(
                      future: getDataService_stylist(),
                      builder: (context, idServicio) {
                        if (idServicio.hasError) print(idServicio.error);
                        return idServicio.hasData
                            ? const DropdownButtonExample()
                            : const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Utils.secondaryColor),
                                ),
                              );
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const VerticalDivider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: kTextButton(
                          ' Agregar Servicios ',
                          () {
                            print(widget.list[widget.index]['id'].toString() +
                                " id del estilista");
                          },
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}

//carga de los datos de estilisra manual
const List<String> list = <String>[
  'Selecciona un servicio',
  'Afeitado',
  'Corte Hombres',
  'Cortes Mujeres',
  'Depilacion de piernas',
  'Depilación cuerpo completo',
  'Lavado de cabello',
  'Maquillaje para bodas',
  'Masaje de cuerpo completo',
  'Peinado para bodas',
  'Teñido del cabello'
];

class DropdownButtonExample extends StatefulWidget {
  const DropdownButtonExample({
    super.key,
  });

  @override
  State<DropdownButtonExample> createState() => _DropdownButtonExampleState();
}

class _DropdownButtonExampleState extends State<DropdownButtonExample> {
  String dropdownValue = list.first;
  var idservice;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: dropdownValue,
      icon: const Icon(Icons.arrow_downward),
      elevation: 50,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      onChanged: (String? value) {
        // This is called when the user selects an item.
        setState(() {
          dropdownValue = value!;
          if (value == "Corte Hombres") {
            idservice = 1;
            print(idservice);
          }
          if (value == "Cortes Mujeres") {
            idservice = 2;
            print(idservice);
          }

          if (value == "Cortes Mujeres") {
            idservice = 2;
            print(idservice);
          }
          if (value == "Afeitado") {
            idservice = 3;
            print(idservice);
          }
          if (value == "Maquillaje para bodas") {
            idservice = 4;
            print(idservice);
          }
          if (value == "Maquillaje para eventos") {
            idservice = 5;
            print(idservice);
          }
          if (value == "Lavado de cabello") {
            idservice = 6;
            print(idservice);
          }
          if (value == "Manicura") {
            idservice = 7;
            print(idservice);
          }
          if (value == "Uñas acrilicas") {
            idservice = 8;
            print(idservice);
          }
          if (value == "Peinado para bodas") {
            idservice = 9;
            print(idservice);
          }
          if (value == "Teñido del cabello") {
            idservice = 10;
            print(idservice);
          }
          if (value == "Depilacion de piernas") {
            idservice = 11;
            print(idservice);
          }
          if (value == "Depilación cuerpo completo") {
            idservice = 12;
            print(idservice);
          }
          if (value == "Masaje de cuerpo completo") {
            idservice = 13;
            print(idservice);
          }

          //
          if (kDebugMode) {
            print(value);
          }
        });
      },
      items: list.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
