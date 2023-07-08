import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../constant.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/utils.dart';
import 'detailProduct.dart';
import 'login.dart';

class ListProducts extends StatefulWidget {
  const ListProducts({super.key});

  @override
  _ListProductsState createState() => _ListProductsState();
}

// pedimos el correo para selecciona solo un usuario
class _ListProductsState extends State<ListProducts> {
  List? data;
  User? user;
  bool loading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtNameController = TextEditingController();
  TextEditingController txtemailController = TextEditingController();
  TextEditingController txtPhoneController = TextEditingController();

  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        loading = false;
        txtNameController.text = user!.name ?? '';
        txtemailController.text = user!.email ?? '';
        txtPhoneController.text = user!.phone ?? '';
      });
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  Future<List> getData() async {
    ApiResponse response = await getUserDetail();
    user = response.data as User;
    txtemailController.text = user!.email ?? '';
    final response1 = await http.get(Uri.parse(
        "http://34.171.207.241/proyecto1/api/clients/${txtemailController.text}"));
    return json.decode(response1.body);
  }

  @override
  void initState() {
    super.initState();
    getData();
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
                  builder: (BuildContext context) => Detail(
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
                          // Usamos una fila para ordenar los botones del card
                        ],
                      ),
                    ),
                         ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
