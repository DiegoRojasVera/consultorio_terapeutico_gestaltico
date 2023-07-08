import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constant.dart';
import '../../models/api_response.dart';

import '../../models/stylistAdmin.dart';

import '../../services/stylist_service.dart';

import '../../utils/utils.dart';

import 'menuStylis.dart';

class RegisterStylist extends StatefulWidget {
  final StylistAdmin? Stylist;
  final String? name;
  final String? photo;
  final String? phone;
  final String? score;

  const RegisterStylist(
      {super.key, this.Stylist, this.name, this.photo, this.phone, this.score});

  @override
  _RegisterStylistState createState() => _RegisterStylistState();
}

class _RegisterStylistState extends State<RegisterStylist> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtControllername = TextEditingController();
  final TextEditingController _txtphotoControllerURL = TextEditingController();
  final TextEditingController _txtControllerscore = TextEditingController();
  final TextEditingController _txtControllerphone = TextEditingController();

  bool _loading = false;
  File? _imageFile;
  bool loading = true;

  //Para migrar a firebase
  String imageName = "";
  XFile? imagePath;
  final ImagePicker _picker1 = ImagePicker();
  var descriptionController = TextEditingController();

  FirebaseFirestore firestoreRef = FirebaseFirestore.instance;
  FirebaseStorage storageRef = FirebaseStorage.instance;
  String collectionName = "Image";

  Future getImage() async {
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
        _txtphotoControllerURL.text = uploadPath;
        if (kDebugMode) {
          print(uploadPath);
        }
        _createStylist();
      } else {
        _showMessage("Algo mientras se sube la imagen.");
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

  void _createStylist() async {
    print(_txtControllername.text);
    print(_txtphotoControllerURL.text);
    print(_txtControllerphone.text);
    print(_txtControllerscore.text);

    ApiResponse response = await createStylist(
        _txtControllername.text,
        _txtphotoControllerURL.text,
        _txtControllerphone.text,
        _txtControllerscore.text);

    if (response.error == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MenuStylist()),
          (route) => false);
    } else {
      print(response.error);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crear Estilista'),
        backgroundColor: Utils.primaryColor,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Utils.secondaryColor)),
            )
          : Padding(
              padding: const EdgeInsets.only(top: 40, left: 40, right: 40),
              child: ListView(
                children: [
                  //cambio de imagen
                  widget.Stylist != null
                      ? const SizedBox()
                      : Container(
                          width: MediaQuery.of(context).size.width,
                          height: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(60),
                              image: _imageFile == null
                                  ? null
                                  : DecorationImage(
                                      image: FileImage(_imageFile ?? File('')),
                                      fit: BoxFit.cover)),
                          child: Center(
                            child: IconButton(
                              icon: const Icon(Icons.image,
                                  size: 50, color: Colors.black38),
                              onPressed: () {
                                getImage();
                              },
                            ),
                          ),
                        ),
                  Form(
                    key: _formKey,
                    child: TextField(
                      controller: _txtControllername,
                      decoration: kInputDecoration('Nombre'),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _txtControllerphone,
                    decoration: kInputDecoration('Telefono'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    keyboardType: TextInputType.number,
                    controller: _txtControllerscore,
                    decoration: kInputDecoration('Score'),
                  ),
                  const SizedBox(height: 40),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: kTextButton(
                      'Guardar',
                      () {
                        if (_formKey.currentState!.validate()) {
                          setState(() {
                            _loading = !_loading;
                          });
                          if (widget.Stylist == null) {
                            _uploadImage();
                          } else {
                            print("estamos aca en publicar");
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
