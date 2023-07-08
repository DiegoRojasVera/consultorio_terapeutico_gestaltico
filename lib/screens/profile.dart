import 'dart:io';

import 'package:consultorio_terapeutico_gestaltico/models/api_response.dart';
import 'package:consultorio_terapeutico_gestaltico/models/user.dart';
import 'package:consultorio_terapeutico_gestaltico/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../constant.dart';
import '../utils/utils.dart';
import 'home.dart';
import 'login.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  User? user;
  bool loading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  File? _imageFile;
  final _picker = ImagePicker();
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
  final ImagePicker _picker1 = ImagePicker();
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
                valueColor: AlwaysStoppedAnimation<Color>(Utils.secondaryColor),
              ),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
              child: ListView(
                children: [
                  Center(
                      child: GestureDetector(
                    child: Container(
                      width: 110,
                      height: 110,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(60),
                          image: _imageFile == null
                              ? user!.image != null
                                  ? DecorationImage(
                                      image: NetworkImage('${user!.image}'),
                                      fit: BoxFit.cover)
                                  : null
                              : DecorationImage(
                                  image: FileImage(
                                    _imageFile ?? File(''),
                                  ),
                                  fit: BoxFit.cover),
                          color: Colors.black26),
                    ),
                    onTap: () {
                      imagePicker();
                    },
                  )),
                  const Text('Nueva foto de perfil'),
                  const SizedBox(
                    height: 2,
                  ),
                  imageName == "" ? Container() : Text(imageName),

                  const SizedBox(
                    height: 15,
                  ),
                  //         Text(_uploadImage.uploadPath.text),
                  const SizedBox(
                    height: 15,
                  ),
                  TextField(
                    controller: txtemailController,
                    decoration: kInputDecoration('Email'),
                    enabled: false,
                  ),
                  const SizedBox(height: 20),
                  Form(
                    key: formKey,
                    child: TextField(
                      decoration: kInputDecoration('Name'),
                      controller: txtNameController,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: txtPhoneController,
                    decoration: kInputDecoration('Telefono'),
                  ),

                  const Text("Ejemplo: 0981411341",
                      style: TextStyle(color: Colors.black26)),
                  const SizedBox(height: 20),
                  TextField(
                    enabled: false,
                    controller: txtFechaNController,
                    decoration: kInputDecoration('Fecha de Nacimiento'),
                  ),
                  TextButton(
                    style: ButtonStyle(
                      foregroundColor:
                          MaterialStateProperty.all<Color>(Colors.black38),
                    ),
                    onPressed: () async {
                      DateTime? newDate = await showDatePicker(
                        locale: const Locale("es", "ES"),
                        context: context,
                        initialDate: date,
                        firstDate: DateTime(1940),
                        lastDate: DateTime(2100),
                      );
                      if (newDate == null) return;
                      setState(() => date = newDate);
                      txtFechaNController.text = date.toString();
                      print(txtFechaNController.text);
                    },
                    child: const Text(
                      'Seleccionar fecha',
                      style: TextStyle(
                        color: Colors.brown, // Cambia el color a rojo
                        fontSize: 16, // Cambia el tamaño de fuente
                        fontWeight: FontWeight
                            .bold, // Cambia el peso de la fuente a negrita
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  kTextButton(
                    'Actualizar',
                    () {
                      if (formKey.currentState!.validate()) {
                        imageName == "" ? updateProfile2() : loading = true;
                        _uploadImage();
                        _showAlertDialog();
                      }
                    },
                  )
                ],
              ),
            ),
    );
  }

  imagePicker() async {
    final XFile? image = await _picker1.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        imagePath = image;
        imageName = image.name.toString();
        descriptionController.text = Faker().lorem.sentence();
      });
    }
  }

  _uploadImage() async {
    setState(() {
      loading = true;
    });

    var uniqueKey = firestoreRef.collection(collectionName).doc();
    String uploadFileName = '${DateTime.now().microsecondsSinceEpoch}.jpg';
    Reference reference =
        storageRef.ref().child(collectionName).child(uploadFileName);
    UploadTask uploadTask = reference.putFile(File(imagePath!.path));

    uploadTask.snapshotEvents.listen((event) {
      if (kDebugMode) {
        print("${event.bytesTransferred}\t${event.totalBytes}");
      }
    });
    await uploadTask.whenComplete(() async {
      var uploadPath = await uploadTask.snapshot.ref.getDownloadURL();

      //Ahora aquí se insertará un registro en la base de datos con respecto a la URL
      if (uploadPath.isNotEmpty) {
        firestoreRef.collection(collectionName).doc(uniqueKey.id).set({
          "discription": descriptionController.text,
          "image": uploadPath,
        }).then((value) => _showMessage("Registro insertado"));
        txtImageController.text = uploadPath;
        if (kDebugMode) {
          print(uploadPath);
        }
        updateProfile();
      } else {
        _showMessage("Algo salio mal mientras se sube la imagen.");
      }
      setState(() {
        loading = false;
        descriptionController.text = "";
        imageName = "";
      });
    });
  }

  _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(msg),
      duration: const Duration(seconds: 3),
    ));
  }

  void _showAlertDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text("Mensaje"),
          content: Text("Datos Actualizados"),
          actions: <Widget>[],
        );
      },
    ).then((value) {
      Future.delayed(const Duration(seconds: 0), () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => const Home(),
          ),
        );
      });
    });
  }
}
