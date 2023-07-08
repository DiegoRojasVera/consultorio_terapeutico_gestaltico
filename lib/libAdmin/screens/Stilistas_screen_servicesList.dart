import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/user.dart';
import '../../screens/login.dart';
import '../../services/user_service.dart';
import '../../utils/utils.dart';
import 'detailEstilista.dart';

class ListadoEstilista extends StatefulWidget {
  const ListadoEstilista({super.key});

  @override
  _ListadoEstilistaState createState() => _ListadoEstilistaState();
}

class _ListadoEstilistaState extends State<ListadoEstilista> {
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

//donde se lista por lo que se elige
  Future<List> getData() async {
    ApiResponse response = await getUserDetail();
    user = response.data as User;
    txtemailController.text = user!.email ?? '';
    final response1 = await http
        .get(Uri.parse("http://34.171.207.241/proyecto1/api/stylist"));
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
        title: const Text("Listados de Estilistas"),
        backgroundColor: Utils.primaryColor,
      ),
      body: Center(
        child: Center(
          child: FutureBuilder<List>(
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
                            AlwaysStoppedAnimation<Color>(Utils.secondaryColor),
                      ),
                    );
            },
          ),
        ),
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
                builder: (BuildContext context) => DetailStylist(
                  list: list,
                  index: i,
                ),
              ),
            ),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              margin: const EdgeInsets.all(5),
              elevation: 10,
              child: Column(
                children: <Widget>[
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 25, 0),
                    title: Text(
                      list[i]['name'],
                      style: const TextStyle(
                          fontSize: 20.0, color: Utils.primaryColor),
                    ),
                    leading: const Icon(Icons.spa),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
