import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

import '../../controllers/databasehelper.dart';
import '../../utils/utils.dart';
import 'home.dart';

class DetailClient extends StatefulWidget {
  List list;
  int index;

  DetailClient({super.key, required this.index, required this.list});

  @override
  _DetailClientState createState() => _DetailClientState();
}

class _DetailClientState extends State<DetailClient> {
  DataBaseHelper databaseHelper = DataBaseHelper();
  late String? id = widget.list[widget.index]
      ['id']; // con este caso el numero del stylista para buscar
  late String? idServicio = widget.list[widget.index]
      ['id']; // con este caso el numero del servicio para buscar
  List? data;

  Future<List> getDataStylist() async {
    final response =
        await http.get(Uri.parse("http://34.171.207.241/proyecto1/api/userlist/$id"));
    return json.decode(response.body);
  }

  Future<List> getDataService() async {
    final response = await http
        .get(Uri.parse("http://34.171.207.241/proyecto1/api/userlist/$idServicio"));
    return json.decode(response.body);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    id = widget.list[widget.index]['id'].toString();
    idServicio = widget.list[widget.index]['id'].toString();

    getDataService();
    getDataStylist();
  }

  //create function delete
  Future<void> confirm() async {
    AlertDialog alertDialog = AlertDialog(
      content: Text(
          "Esta seguro de eliminar '${widget.list[widget.index]['name']}'"),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Utils.primaryColor),
          child: const Text(
            "Borrar!",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            databaseHelper
                .removeUser(widget.list[widget.index]['id'].toString());
            print(widget.list[widget.index]['name'].toString());
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const HomeAdmin(),
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
                        widget.list[widget.index]['image'].toString()),
                  ),
                ),
                const Divider(),
                Text(
                  "Email : ${widget.list[widget.index]['email']}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18.0),
                ),
                Text(
                  "Telefono : ${widget.list[widget.index]['phone']}",
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18.0),
                ),
                const Text(
                  ("Fecha de Nacimiento:"),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 18.0),
                ),
                Text(
                  ("${list[id]['fechaN']}"),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18.0),
                ),
                const Text(
                  ("Fecha de registro:"),
                  textAlign: TextAlign.right,
                  style: TextStyle(fontSize: 18.0),
                ),
                Text(
                  ("${list[id]['created_at']}"),
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontSize: 18.0),
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
                      child: const Text("Borrar Cliente"),
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
}
