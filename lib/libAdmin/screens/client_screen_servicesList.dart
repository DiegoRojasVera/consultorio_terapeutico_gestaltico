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

import 'detailServicio.dart';

class servicesList extends StatefulWidget {
  const servicesList({super.key});

  @override
  _servicesListState createState() => _servicesListState();
}

// pedimos el correo para selecciona solo un usuario
class _servicesListState extends State<servicesList> {
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
        .get(Uri.parse("http://34.171.207.241/proyecto1/api/service"));

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
        title: const Text("Listados de Servicios"),
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
                  builder: (BuildContext context) => DetailServicio(
                        list: list,
                        index: i,
                      )),
            ),

            child: Card(
              // Con esta propiedad modificamos la forma de nuestro card
              // Aqui utilizo RoundedRectangleBorder para proporcionarle esquinas circulares al Card
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),

              // Con esta propiedad agregamos margen a nuestro Card
              // El margen es la separación entre widgets o entre los bordes del widget padre e hijo
              margin: const EdgeInsets.all(5),

              // Con esta propiedad agregamos elevación a nuestro card
              // La sombra que tiene el Card aumentará
              elevation: 10,

              // La propiedad child anida un widget en su interior
              // Usamos columna para ordenar un ListTile y una fila con botones
              child: Column(
                children: <Widget>[
                  // Usamos ListTile para ordenar la información del card como titulo, subtitulo e icono
                  ListTile(
                    contentPadding: const EdgeInsets.fromLTRB(15, 10, 25, 0),
                    title: Text(
                      list[i]['name'],
                      style: const TextStyle(
                          fontSize: 20.0, color: Utils.primaryColor),
                    ),
                    subtitle: Text(
                      'Precio: ${list[i]['price']} Gs.',
                      style: const TextStyle(
                          fontSize: 15, color: Utils.secondaryColor),
                    ),
                    leading: const Icon(Icons.pending),
                  ),
                  // Usamos una fila para ordenar los botones del card
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
