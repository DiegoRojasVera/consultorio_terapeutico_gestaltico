import 'package:flutter/material.dart';

import '../../screens/cancelacionCliente.dart';
import '../../screens/profile.dart';
import '../../services/user_service.dart';
import '../../utils/utils.dart';
import 'datosdeClientes.dart';
import 'homenologin.dart';
import 'menuStylis.dart';

class MenuCliente extends StatefulWidget {
  const MenuCliente({super.key});

  @override
  State<MenuCliente> createState() => _MenuClienteState();
}

class _MenuClienteState extends State<MenuCliente> {
  void _showAlertDialog() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: const Text("Mensaje"),
            content: const Text(
                "En esta opción se podrán enviar Notificaciones a los clientes."
                " Desactivado en la demo"),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Utils.secondaryColor),
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  "CERRAR",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Menú Cliente"),
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
                          builder: (context) => const Profile(),
                        ),
                      );
                    },
                    child: const Text(
                      "Datos Personales",
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
                          builder: (context) => const DatosClientes(),
                        ),
                      );
                    },
                    child: const Text(
                      "Clientes",
                      style: TextStyle(
                          fontSize: 20.0, color: Utils.secondaryColor),
                    ),
                  ),
                  const Divider(),
                  const Divider(),
                  TextButton(
                    onPressed: () {
                      _showAlertDialog();
                      /**           Navigator.of(context).push(
                          MaterialPageRoute(
                          builder: (context) => const Notificacion_Page(),
                          ),
                          );**/
                    },
                    child: const Text(
                      "Notificaciones",
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
                          builder: (context) => const MenuStylist(),
                        ),
                      );
                    },
                    child: const Text(
                      "Menú Estilistas",
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
                          builder: (context) => const cancelacionCliente(),
                        ),
                      );
                    },
                    child: const Text(
                      "Cancelar Cuenta",
                      style: TextStyle(
                          fontSize: 20.0, color: Utils.secondaryColor),
                    ),
                  ),
                  const Divider(),
                  const Divider(),
                  TextButton(
                    onPressed: () {
                      logout().then((value) => {
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(
                                  builder: (context) => homenologin()),
                              (route) => false,
                            ),
                          });
                    },
                    child: const Text("Cerrar Sesión",
                        style: TextStyle(
                            fontSize: 20.0, color: Utils.secondaryColor)),
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
