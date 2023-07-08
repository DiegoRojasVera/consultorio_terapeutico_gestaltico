import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import '../../controllers/databasehelper.dart';
import '../../utils/utils.dart';
import 'home.dart';

class DetailStylist extends StatefulWidget {
  List list;
  int index;

  DetailStylist({super.key, required this.index, required this.list});

  @override
  _DetailStylistState createState() => _DetailStylistState();
}

class _DetailStylistState extends State<DetailStylist> {
  DataBaseHelper databaseHelper = DataBaseHelper();

  //los datos restantes

  late int? idServicio = widget.list[widget.index]['id'];

  // con este caso el numero del servicio para buscar

  List? data;

  //hasta aca

  Future<List> _loadData() async {
    List posts = [];
    try {
      print(idServicio);
      var apiUrl = 'http://34.171.207.241/proyecto1/api/clientsStylist/$idServicio';
      final http.Response response = await http.get(Uri.parse(apiUrl));
      posts = json.decode(response.body);
    } catch (err) {
      if (kDebugMode) {
        print(err);
      }
    }
    return posts;
  }

  //Boton de borrar
  Future<void> confirm(set) async {
    AlertDialog alertDialog = AlertDialog(
      content: Text("Esta seguro de eliminar "),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Utils.primaryColor),
          child: const Text(
            "Cancelar Cita!",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            print(set);
            databaseHelper.removeRegister(set);
            databaseHelper.removeRegister2(set);

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
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadData();
  }

  ListView ItemList(AsyncSnapshot<List<dynamic>> snapshot) {
    return ListView.builder(
      // render the list
      itemCount: snapshot.data!.length,
      itemBuilder: (BuildContext context, index) => Column(children: [
        Column(
          children: [
            if (snapshot.data![index]['inicio']
                .compareTo(DateTime.now().toString()) >=
                0) ...[
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.all(15),
                elevation: 10,
                child: Column(
                  children: [
                    Column(
                      children: <Widget>[
                        // Usamos ListTile para ordenar la información del card como titulo, subtitulo e icono
                        ListTile(
                          contentPadding:
                          const EdgeInsets.fromLTRB(15, 10, 25, 0),
                          title: Text(
                            'Estilista: ' +
                                snapshot.data![index]['stylistName'],
                          ),
                          subtitle: Text("Fecha de Reservas: " +
                              snapshot.data![index]['inicio']),
                          leading: Text(snapshot.data![index]['name']),
                        ),
                        // Usamos una fila para ordenar los botones del card
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            const VerticalDivider(),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Utils.primaryColor,
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(30.0))),
                              child: const Text("Cancelar Cita "),
                              onPressed: () => confirm(
                                  snapshot.data![index]['id'].toString()),
                            ),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
        if (snapshot.data![index]['inicio']
            .compareTo(DateTime.now().toString()) <
            0) ...[
          Card(
            color: Utils.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(15),
            elevation: 10,
            child: Column(
              children: [
                Column(
                  children: <Widget>[
                    // Usamos ListTile para ordenar la información del card como titulo, subtitulo e icono
                    ListTile(
                      contentPadding: const EdgeInsets.fromLTRB(15, 10, 25, 0),
                      title: Text(
                        'Estilista: ' + snapshot.data![index]['stylistName'],
                      ),
                      subtitle: Text("Fecha de Reservas: " +
                          snapshot.data![index]['inicio']),
                      leading: Text(snapshot.data![index]['name']),
                    ),
                    // Usamos una fila para ordenar los botones del card
                  ],
                ),
              ],
            ),
          ),
        ],
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("${widget.list[widget.index]['name']}"),
        //Nombre del Stylist en la cabeza de la pagina
        backgroundColor: Utils.primaryColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      body: FutureBuilder(
        future: _loadData(),
        builder: (BuildContext ctx, AsyncSnapshot<List> snapshot) => snapshot
            .hasData
            ? ItemList(snapshot)
            : const Center(
          // render the loading indicator
          child: CircularProgressIndicator(
              valueColor:
              AlwaysStoppedAnimation<Color>(Utils.secondaryColor)),
        ),
      ),
    );
  }
}
