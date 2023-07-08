import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../../utils/utils.dart';
import 'detailProduct.dart';

class ListadoTotalCitas extends StatefulWidget {
  const ListadoTotalCitas({Key? key}) : super(key: key);

  @override
  State<ListadoTotalCitas> createState() => _ListadoTotalCitasState();
}

class _ListadoTotalCitasState extends State<ListadoTotalCitas> {
  Future<List> getData() async {
    final response = await http
        .get(Uri.parse("http://34.171.207.241/proyecto1/api/clients/"));

    return json.decode(response.body);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Listados de Reservas"),
        backgroundColor: Utils.primaryColor,
      ),
      body: FutureBuilder<List>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) if (kDebugMode) {
            print(snapshot.error);
          }
          return snapshot.hasData
              ? ItemList(
                  list: snapshot.data!,
                )
              : const Center(
                  child: CircularProgressIndicator(
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Utils.secondaryColor)),
                );
        },
      ),
    );
  }
}

class ItemList extends StatelessWidget {
  final List list;

  const ItemList({super.key, required this.list});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      // ignore: unnecessary_null_comparison
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, i) {
        return Container(
          padding: const EdgeInsets.all(10.0),
          child: GestureDetector(
            // aca es el detalle
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (BuildContext context) => DetailReservaTotal(
                        list: list,
                        index: i,
                      )),
            ),
            child: Column(
              children: <Widget>[
                Column(
                  children: [
                   if (list[i]['inicio']
                            .compareTo(DateTime.now().toString()) >=
                        0) ...[
                      Card(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(5),
                        elevation: 10,
                        child: Column(
                          children: <Widget>[
                            ListTile(
                              contentPadding:
                                  const EdgeInsets.fromLTRB(15, 10, 25, 0),
                              title: Text(
                                list[i]['name'],
                                style: const TextStyle(
                                    fontSize: 20.0, color: Utils.primaryColor),
                              ),
                              subtitle: Text(
                                'Fecha de cita: ${list[i]['inicio']}',
                                style: const TextStyle(
                                    fontSize: 15, color: Utils.secondaryColor),
                              ),
                              leading: const Icon(Icons.pending),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                /**          Column(
                    children: [
                    if (list[i]['inicio'].compareTo(DateTime.now().toString()) <
                    0) ...[
                    Card(
                    color: Utils.primaryColor,
                    shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(5),
                    elevation: 10,
                    child: Column(
                    children: <Widget>[
                    ListTile(
                    contentPadding:
                    const EdgeInsets.fromLTRB(15, 10, 25, 0),
                    title: Text(
                    list[i]['name'],
                    style: const TextStyle(
                    fontSize: 20.0, color: Colors.black),
                    ),
                    subtitle: Text(
                    'Fecha de cita: ${list[i]['inicio']}',
                    style: const TextStyle(
                    fontSize: 15, color: Utils.secondaryColor),
                    ),
                    leading: Text("vencida"),
                    ),
                    ],
                    ),
                    ),
                    ],
                    ],
                    )**/
              ],
            ),
          ),
        );
      },
    );
  }
}
