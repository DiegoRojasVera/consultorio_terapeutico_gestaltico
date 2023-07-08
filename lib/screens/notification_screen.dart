import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import '../utils/utils.dart';

class Notificacion_Page extends StatefulWidget {
  const Notificacion_Page({Key? key}) : super(key: key);

  @override
  State<Notificacion_Page> createState() => _Notificacion_PageState();
}

class _Notificacion_PageState extends State<Notificacion_Page> {
  String user = "User1";
  String? mtoken = " ";

  TextEditingController username = TextEditingController();
  TextEditingController body = TextEditingController();
  TextEditingController title = TextEditingController();

  @override
  void initState() {
    super.initState();
    requestPermission();
    getToken();
  }

  void getToken() async {
    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        print("My token is $mtoken");
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    await FirebaseFirestore.instance.collection("User Tokens").doc(user).set({
      'token': token,
    });
    print("Token Guardado");
  }

  void requestPermission() async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    NotificationSettings settings = await messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User declined or has not accepted permisssion');
    }
  }

  void sendPushMessage(String token, String title, String body) async {
    var serverKey =
        'AAAAJExtUso:APA91bEOtHxmCu1kLfSf4cMX_zEpUTquClVbjr9rw54PWQYd31WO2v5kBX5m6wV4vQSesmH66bc1r2exrv0TWuVFNH55LdYJiaZf4WTd-_Xps9jiiCBlnM_Uz82UpT0HaCXCtK9e90Ia';
    FirebaseFirestore db = FirebaseFirestore.instance;
    List tokenID = [];
    CollectionReference collectionReferencePeople =
        db.collection('User Tokens');
    QuerySnapshot querySnapshot = await collectionReferencePeople.get();
    for (var doc in querySnapshot.docs) {
      final Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      final person = {
        "name": data['token'],
        "uid": doc.id,
      };
      http.Response response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: <String, String>{
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode(
          <String, dynamic>{
            'notification': <String, dynamic>{'body': body, 'title': title},
            'priority': 'high',
            'data': <String, dynamic>{
              'click_action': 'FLUTTER_NOTIFICATION_CLICK',
              'id': '1',
              'status': 'done'
            },
            'to': data['token'],
          },
        ),
      );
      tokenID.add(person);
      print("enviado");
    }
  }

  void _showAlertDialog() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: const Text("Notificación"),
            content: const Text("Las notificaciones fueron enviadas"),
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
          title: const Text("Envío de notificaciones"),
          backgroundColor: Utils.primaryColor,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Column(
//                  mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      TextField(
                        controller: title,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Título",
                        ),
                      ),
                      const SizedBox(
                        height: 20,
                      ),
                      TextField(
                        controller: body,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: "Cuerpo",
                        ),
                      ),
                      GestureDetector(
                        onTap: () async {
                          _showAlertDialog();
                          String name = user.toString();
                          String titleText = title.text;
                          String bodyText = body.text;

                          if (name != "") {
                            DocumentSnapshot snap = await FirebaseFirestore
                                .instance
                                .collection("User Tokens")
                                .doc(name)
                                .get();

                            String token = snap['token'];
                            print("Es mi token  " + token);
                            print("Notificacion Enviada");
                            print(titleText + " Titulo");
                            print(bodyText + " cuerpo");

                            sendPushMessage(token, titleText, bodyText);
                          }
                        },
                        child: Container(
                          margin: const EdgeInsets.all(50),
                          height: 40,
                          width: 200,
                          decoration: BoxDecoration(
                            color: Utils.secondaryColor,
                            //borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.redAccent.withOpacity(0.5))
                            ],
                          ),
                          child: const Center(
                            child: Text(
                              "Enviar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
