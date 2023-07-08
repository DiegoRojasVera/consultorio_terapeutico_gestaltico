import 'package:consultorio_terapeutico_gestaltico/models/api_response.dart';
import 'package:consultorio_terapeutico_gestaltico/models/user.dart';
import 'package:consultorio_terapeutico_gestaltico/services/user_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constant.dart';

import '../libAdmin/screens/home.dart';
import 'home.dart';
import 'register.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  TextEditingController txtEmail = TextEditingController();
  TextEditingController txtPassword = TextEditingController();
  bool loading = false;

  bool _isObscure = true;

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  void getTokenUser() async {
    String? mtoken = " ";

    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        print("My token is $mtoken");
      });
      saveToken(token!);
    });
  }

  void saveToken(String token) async {
    String? name;
    User? user;
    ApiResponse response = await getUserDetail();
    user = response.data as User?;
    name = user!.email ?? '';
    print(name);
    print(token);
    //await FirebaseFirestore.instance.collection("User Tokens").doc(name).set({
    await FirebaseFirestore.instance
        .collection("User Tokens")
        .doc("User1")
        .set({
      'token': token,
    });
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

  void _loginUser() async {
    ApiResponse response = await login(txtEmail.text, txtPassword.text);
    if (response.error == null) {
      _saveAndRedirectToHome(response.data as User);
    } else {
      setState(() {
        loading = false;
      });
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('${response.error}')));
    }
  }

  void _saveAndRedirectToHome(User user) async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    await pref.setString('token', user.token ?? '');
    await pref.setInt('userId', user.id ?? 0);
    if (kDebugMode) {
      print(user.admin);
    }
    if (user.admin == "true") {
      print("admin");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeAdmin()),
          (route) => false);
    } else {
      requestPermission();
      getTokenUser();

      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);
      //MaterialPageRoute(builder: (context) => const Home()), (route) => false); se va al blog
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('inicio de sesión'),
        backgroundColor: Utils.primaryColor,
        centerTitle: true,
      ),
      body: Form(
        key: formkey,
        child: ListView(
          padding: const EdgeInsets.all(32),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Cambia los valores para ajustar el sombreado
                    ),
                  ],
                ),
                child: Image.asset('assets/ic_launcher.png'),
              ),
            ),
            const SizedBox(height: 15),
            TextFormField(
                keyboardType: TextInputType.emailAddress,
                controller: txtEmail,
                validator: (val) => val!.isEmpty
                    ? 'Dirección de correo electrónico no válida'
                    : null,
                decoration: kInputDecoration('Email')),
            const SizedBox(
              height: 10,
            ),
            TextFormField(
              controller: txtPassword,
              obscureText: _isObscure,
              validator: (val) =>
                  val!.length < 6 ? 'Se requieren al menos 6 caracteres' : null,
              decoration: InputDecoration(
                labelText: 'Password',
                border: const OutlineInputBorder(
                    borderSide: BorderSide(width: 1, color: Colors.black)),
                suffixIcon: IconButton(
                    icon: Icon(
                        _isObscure ? Icons.visibility : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _isObscure = !_isObscure;
                      });
                    }),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            loading
                ? const Center(
                    child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                            Utils.secondaryColor)),
                  )
                : kTextButton('Acceder', () {
                    if (formkey.currentState!.validate()) {
                      setState(() {
                        loading = true;
                        _loginUser();
                      });
                    }
                  }),
            const SizedBox(
              height: 10,
            ),
            kLoginRegisterHint('No tengo una cuenta? ', 'Registrar', () {
              Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const Register()),
                  (route) => false);
            })
          ],
        ),
      ),
    );
  }
}
