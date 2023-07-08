import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';
import '../screens/Stilistas_screen_servicesList.dart';
import '../screens/client_ListTotal.dart';
import '../screens/client_screen_servicesList.dart';

class Reservas extends StatefulWidget {
  const Reservas({Key? key}) : super(key: key);

  @override
  State<Reservas> createState() => _ReservasState();
}

class _ReservasState extends State<Reservas> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Menu Cliente"),
        backgroundColor: Utils.primaryColor,
      ),
      body: Card(
        elevation: 50,
        child: Center(
          child: Column(
            children: <Widget>[
              const Padding(
                padding: EdgeInsets.only(top: 30.0),
              ),
              const Divider(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const servicesList()));
                },
                child: const Text("Reservas Servicios",
                    style:
                        TextStyle(fontSize: 20.0, color: Utils.secondaryColor)),
              ),
              const Divider(),
              const Divider(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ListadoTotalCitas()));
                },
                child: const Text("Reservas Total",
                    style:
                        TextStyle(fontSize: 20.0, color: Utils.secondaryColor)),
              ),
              const Divider(),
              const Divider(),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const ListadoEstilista()));
                },
                child: const Text("Reservas por Estilistas",
                    style:
                        TextStyle(fontSize: 20.0, color: Utils.secondaryColor)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
