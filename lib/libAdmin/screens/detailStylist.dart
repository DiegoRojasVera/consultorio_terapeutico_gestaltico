import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../../constant.dart';
import '../../controllers/databasehelper.dart';
import '../../utils/utils.dart';


import 'menuStylis.dart';

class DetailStylist1 extends StatefulWidget {
  List list;
  int index;

  DetailStylist1({super.key, required this.index, required this.list});

  @override
  _DetailStylist1State createState() => _DetailStylist1State();
}

class _DetailStylist1State extends State<DetailStylist1> {
  DataBaseHelper databaseHelper = DataBaseHelper();
  late String? id = widget.list[widget.index]
      ['id']; // con este caso el numero del stylista para buscar
  List? data;

  Future<List> getDataStylist() async {
    final response = await http.get(
      Uri.parse("http://34.171.207.241/proyecto1/api/stylist/$id"),
    );
    return json.decode(response.body);
  }

  Future<List> getDataService_stylist() async {
    final response = await http.get(
      Uri.parse(
          "http://34.171.207.241/proyecto1/api/servicestylistall/$id"),
    );
    return json.decode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.list[widget.index]['id'].toString();

    getDataStylist();
    getDataStylist();
    print(id);
  }

  //create function delete
  Future<void> confirm() async {
    AlertDialog alertDialog = AlertDialog(
      content: Text(
          "Esta seguto de eliminar '${widget.list[widget.index]['name']}'"),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Utils.primaryColor),
          child: const Text(
            "Borrar!",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            databaseHelper
                .removeStylists(widget.list[widget.index]['id'].toString());
            print(widget.list[widget.index]['name'].toString());
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const MenuStylist(),
            ));
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Utils.primaryColor),
          child: const Text("CANCEL", style: TextStyle(color: Colors.black)),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return alertDialog;
      },
    );
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
                  height: 150,
                  child: Center(
                    child: FutureBuilder<List>(
                      future: getDataService_stylist(),
                      builder: (context, idServicio) {
                        if (idServicio.hasError) print(idServicio.error);
                        return idServicio.hasData
                            ? ItemListSer(
                                list: idServicio.data!,
                              )
                            : const Center(
                                child: CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Utils.secondaryColor)),
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
                      /**           Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: kTextButton(
                          ' Agregar Servicios ',
                          () {
                          Navigator.of(context).push(
                          MaterialPageRoute(
                          builder: (BuildContext context) =>
                          AgregarServicioStylist(
                          list: list,
                          index: id,
                          ),
                          ),
                          );
                          },
                          ),
                          ),
                       **/
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: kTextButton(
                          ' Borrar Estilista ',
                          () {
                            confirm();
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

  ListView ItemListSer({required List list}) {
    return ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, int id) {
         return Text(
          "Servicio: ${list[id]['nombre_servicio']}",
          style: const TextStyle(
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
