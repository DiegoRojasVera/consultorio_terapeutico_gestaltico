import 'package:flutter/material.dart';


import 'registerStylist.dart';
import '../../utils/utils.dart';
import 'datosdeStylista.dart';

class MenuStylist extends StatelessWidget {
  const MenuStylist({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Menu Estilista"),
        backgroundColor: Utils.primaryColor,
      ),
      body: ListView(
        children: [
          Card(
            elevation: 50,
            child: Center(
              child: Column(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(top: 30.0),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DatosEstilista(),
                        ),
                      );
                    },
                    child: const Text(
                      "Estilistas",
                      style: TextStyle(
                          fontSize: 20.0, color: Utils.secondaryColor),
                    ),
                  ),
                  const Divider(),
                  const Divider(),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const RegisterStylist(),
                        ),
                      );
                    },
                    child: const Text(
                      "Agregar Estilistas",
                      style: TextStyle(
                          fontSize: 20.0, color: Utils.secondaryColor),
                    ),
                  ),
                  const Divider(),
                  const Divider(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
