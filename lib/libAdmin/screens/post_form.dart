import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:faker/faker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../constant.dart';
import '../../models/api_response.dart';
import '../../models/post.dart';

import '../../screens/home.dart';
import '../../services/post_client.dart';
import '../../services/user_service.dart';
import '../../utils/utils.dart';
import '../../screens/login.dart';
import 'home.dart';

class PostForm extends StatefulWidget {
  final Post? post;
  final String? title;

  const PostForm({Key? key, this.post, this.title}) : super(key: key);

  @override
  _PostFormState createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _txtControllerBody = TextEditingController();
  final TextEditingController _txtImageControllerURL = TextEditingController();

  bool _loading = false;
  File? _imageFile;

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
      _loading = true;
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
        _txtImageControllerURL.text = uploadPath;
        if (kDebugMode) {
          print(uploadPath);
        }
        _createPost();
      } else {
        _showMessage("Algo salio mal mientras se sube la imagen.");
      }
      setState(() {
        _loading = false;
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

  void _createPost() async {
    print(_txtImageControllerURL.text);
    print(_txtControllerBody.text);

    ApiResponse response =
        await createPost(_txtControllerBody.text, _txtImageControllerURL.text);

    if (response.error == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeAdmin()),
          (route) => false);
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  // edit post
  void _editPost(int postId) async {
    ApiResponse response = await editPost(postId, _txtControllerBody.text);
    if (response.error == null) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);
    } else if (response.error == unauthorized) {
      logout().then((value) => {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const Login()),
                (route) => false)
          });
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
      setState(() {
        _loading = !_loading;
      });
    }
  }

  @override
  void initState() {
    if (widget.post != null) {
      _txtControllerBody.text = widget.post!.body ?? '';
      _txtImageControllerURL.text = widget.post?.image ?? '';
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Publicar Anuncio'),
        backgroundColor: Utils.primaryColor,
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Utils.secondaryColor)),
            )
          : ListView(
              children: [
                //cambio de imagen
                widget.post != null
                    ? const SizedBox()
                    : Container(
                        width: MediaQuery.of(context).size.width,
                        height: 150,
                        decoration: BoxDecoration(
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
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: TextFormField(
                      controller: _txtControllerBody,
                      keyboardType: TextInputType.multiline,
                      maxLines: 5,
                      validator: (val) => val!.isEmpty
                          ? 'El cuerpo de la publicación es obligatorio'
                          : null,
                      decoration: const InputDecoration(
                          hintText: "Escriba un comentario...",
                          border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(width: 1, color: Colors.black38))),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: kTextButton('Publicar', () {
                    if (_formKey.currentState!.validate()) {
                      setState(() {
                        _loading = !_loading;
                      });
                      if (widget.post == null) {
                        _uploadImage();
                      } else {
                        _editPost(widget.post!.id ?? 0);
                      }
                    }
                  }),
                )
              ],
            ),
    );
  }
}
