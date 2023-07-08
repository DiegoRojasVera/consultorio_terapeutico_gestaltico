import 'package:consultorio_terapeutico_gestaltico/screens/profile.dart';
import 'package:flutter/material.dart';

import '../libAdmin/screens/homenologin.dart';
import '../services/user_service.dart';
import '../utils/utils.dart';
import 'calificarestilista.dart';
import 'cancelacionCliente.dart';
import 'client_screen.dart';

class MenuCliente extends StatefulWidget {
  const MenuCliente({super.key});

  @override
  _MenuClienteState createState() => _MenuClienteState();
}

// pedimos el el correo para selecciona solo un usuario
class _MenuClienteState extends State<MenuCliente> {
  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (buildcontext) {
        return AlertDialog(
          title: const Text("Mensaje"),
          content: const Text(
            "En esta opción se podrán enviar Notificaciones a los clientes."
                " Desactivado en la demo",
          ),
          actions: <Widget>[
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Utils.secondaryColor,
              ),
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
      },
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text("Panel de usuario"),
        backgroundColor: Utils.primaryColor,
        centerTitle: true,
        elevation: 1,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        children: <Widget>[
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
              style: TextStyle(fontSize: 20.0, color: Utils.secondaryColor),
            ),
          ),
          const Divider(),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ListProducts(),
                ),
              );
            },
            child: const Text(
              "Reservas",
              style: TextStyle(fontSize: 20.0, color: Utils.secondaryColor),
            ),
          ),
          const Divider(),
          TextButton(
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CalificarEstilista(),
                ),
              );
            },
            child: const Text(
              "Calificar Estilista",
              style: TextStyle(fontSize: 20.0, color: Utils.secondaryColor),
            ),
          ),
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
              style: TextStyle(fontSize: 20.0, color: Utils.secondaryColor),
            ),
          ),
          const Divider(),
          TextButton(
            onPressed: () {
              logout().then(
                    (value) => {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(builder: (context) => homenologin()),
                        (route) => false,
                  ),
                },
              );
            },
            child: const Text(
              "Cerrar Sesión",
              style: TextStyle(fontSize: 20.0, color: Utils.secondaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
