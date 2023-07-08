import 'dart:convert';

import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../../controllers/databasehelper.dart';
import '../../utils/utils.dart';
import 'home.dart';

class DetailReservaTotal extends StatefulWidget {
  List list;
  int index;

  DetailReservaTotal({super.key, required this.index, required this.list});

  @override
  _DetailReservaTotalState createState() => _DetailReservaTotalState();
}

class _DetailReservaTotalState extends State<DetailReservaTotal> {
  DataBaseHelper databaseHelper = DataBaseHelper();
  late String? id = widget.list[widget.index]
      ['stylist']; // con este caso el numero del stylista para buscar
  late String? idServicio = widget.list[widget.index]
      ['service']; // con este caso el numero del servicio para buscar
  List? data;

  Future<List> getDataStylist() async {
    final response = await http.get(
        Uri.parse("http://34.171.207.241/proyecto1/api/stylist/$id"));
    return json.decode(response.body);
  }

  Future<List> getDataService() async {
    final response = await http.get(Uri.parse(
        "http://34.171.207.241/proyecto1/api/service/$idServicio"));
    return json.decode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.list[widget.index]['stylist'];
    idServicio = widget.list[widget.index]['service'];
    getDataService();
    getDataStylist();
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
            "Cancelar Cita!",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            databaseHelper
                .removeRegister(widget.list[widget.index]['id'].toString());
            databaseHelper
                .removeRegister2(widget.list[widget.index]['id'].toString());
            print(widget.list[widget.index]['id'].toString());
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const HomeAdmin(),
            ));
          },
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Utils.primaryColor),
          child: const Text("Salir", style: TextStyle(color: Colors.black)),
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
          if (snapshot.hasError) print(snapshot.error);
          return snapshot.hasData
              ? ItemList(list: snapshot.data!)
              : const Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Utils.secondaryColor)),
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
          height: 270,
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                Text(
                  widget.list[widget.index]['name'],
                  style: const TextStyle(fontSize: 20.0),
                ),
                const Divider(),
                Text(
                  "Email : ${widget.list[widget.index]['email']}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18.0),
                ),
                Text(
                  "Cita : ${widget.list[widget.index]['inicio']}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18.0),
                ),
                Text(
                  ("Estilista: ${list[id]['name']}"),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18.0),
                ),
                SizedBox(
                  height: 40,
                  child: Center(
                    child: FutureBuilder<List>(
                      future: getDataService(),
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
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const VerticalDivider(),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Utils.primaryColor,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0))),
                      child: const Text("Cancelar Cita"),
                      onPressed: () => confirm(),
                    ),
                  ],
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
      // ignore: unnecessary_null_comparison
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, idServicio) {
        return Text(
          "Servicio: " + list[idServicio]['name'],
          style: const TextStyle(
            fontSize: 20.0,
          ),
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
