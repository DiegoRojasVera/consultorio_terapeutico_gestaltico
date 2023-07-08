import 'package:consultorio_terapeutico_gestaltico/models/api_response.dart';
import 'package:consultorio_terapeutico_gestaltico/models/user.dart';
import 'package:consultorio_terapeutico_gestaltico/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constant.dart';
import '../controllers/databasehelper.dart';
import '../pages/home_page.dart';
import '../utils/utils.dart';
import 'login.dart';

class cancelacionCliente extends StatefulWidget {
  const cancelacionCliente({super.key});

  @override
  _cancelacionClienteState createState() => _cancelacionClienteState();
}

class _cancelacionClienteState extends State<cancelacionCliente> {
  DataBaseHelper databaseHelper = DataBaseHelper();

  User? user;
  bool loading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  DateTime date = DateTime(2022, 12, 23);

  TextEditingController txtIdController = TextEditingController();
  TextEditingController txtImageController = TextEditingController();
  TextEditingController txtImageControllerURL = TextEditingController();
  TextEditingController txtNameController = TextEditingController();
  TextEditingController txtemailController = TextEditingController();
  TextEditingController txtPhoneController = TextEditingController();
  TextEditingController txtFechaNController = TextEditingController();

  //Para migrar a firebase
  String imageName = "";
  XFile? imagePath;
  var descriptionController = TextEditingController();

  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage storageRef = FirebaseStorage.instance;
  String collectionName = "Image";

  //bool loading = false;

  // hasata aca

  // get user detail
  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        loading = false;
        txtIdController.text = user!.id.toString();
        txtImageControllerURL.text = user!.image ?? '';
        txtNameController.text = user!.name ?? '';
        txtemailController.text = user!.email ?? '';
        txtPhoneController.text = user!.phone ?? '';
        txtFechaNController.text = user!.fechaN ?? '';

        if (kDebugMode) {
          print(txtImageControllerURL.text);
        }
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

  //update profile
  void updateProfile() async {
    ApiResponse response = await updateUser(
        txtIdController.text,
        txtNameController.text,
        txtImageController.text,
        txtPhoneController.text,
        txtemailController.text,
        txtFechaNController.text);

    setState(() {
      loading = false;
    });
    if (response.error == null) {
      print("object");
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

  void updateProfile2() async {
    loading = true;
    ApiResponse response = await updateUser(
        txtIdController.text,
        txtNameController.text,
        txtImageControllerURL.text,
        txtPhoneController.text,
        txtemailController.text,
        txtFechaNController.text);

    setState(() {
      loading = false;
    });
    if (response.error == null) {
      print("Guardado");
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

  @override
  void initState() {
    getUser();
    super.initState();
  }

  Future<void> confirm() async {
    AlertDialog alertDialog = AlertDialog(
      content: Text(
          "¿Esta seguro que desea eliminar su cuenta? '${user!.name}' si la elimina se borran todos los datos"),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Utils.primaryColor),
          child: const Text(
            "Borrar!",
            style: TextStyle(color: Colors.black),
          ),
          onPressed: () {
            databaseHelper.removeUser((user!.id).toString());
            Navigator.of(context).push(MaterialPageRoute(
              builder: (BuildContext context) => const HomePage(),
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
        title: const Text("Datos Personales"),
        backgroundColor: Utils.primaryColor,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Utils.secondaryColor)),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 20, left: 60, right: 60),
              child: ListView(
                children: [
                  Center(
                    child: CircleAvatar(
                      radius: 48,
                      backgroundColor: Colors.grey, // Image radius
                      backgroundImage: NetworkImage((user!.image).toString()),
                    ),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  //         Text(_uploadImage.uploadPath.text),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: txtemailController,
                    decoration: kInputDecoration('email'),
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: formKey,
                    child: TextField(
                      decoration: kInputDecoration('Name'),
                      controller: txtNameController,
                      enabled: false,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: txtPhoneController,
                    decoration: kInputDecoration('Telefono'),
                    enabled: false,
                  ),

                  const Text("Ejemplo: 0981123123",
                      style: TextStyle(color: Colors.black26)),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: false,
                    controller: txtFechaNController,
                    decoration: kInputDecoration('Fecha de Nacimiento'),
                  ),

                  const SizedBox(height: 20),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const VerticalDivider(),
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Utils.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                          ),
                          child: const Text("Eliminar Cuenta"),
                          onPressed: () => confirm(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
