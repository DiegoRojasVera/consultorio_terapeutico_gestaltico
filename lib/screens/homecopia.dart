import 'package:consultorio_terapeutico_gestaltico/services/user_service.dart';
import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
import '../libAdmin/screens/post_screen.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../pages/home_page.dart';
import 'login.dart';
import 'menuClient.dart';

class Home extends StatefulWidget {
  static const String route = '/Home';

  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  User? user;

  int currentIndex = 0;

  TextEditingController username = TextEditingController();
  TextEditingController body = TextEditingController();
  TextEditingController title = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTokenUser();
  }

  updateToken(int userId, String tokenFB) async {
    ApiResponse response = await updateTokenUser(userId, tokenFB);
    if (response.error == null) {
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

  void getTokenUser() async {
    ApiResponse response = await getUserDetail();
    user = response.data as User?;
    int? id = user!.id;
    String? mtoken = " ";

    await FirebaseMessaging.instance.getToken().then((token) {
      setState(() {
        mtoken = token;
        print("My token is $mtoken");
      });
      saveToken(token!);
      updateToken(id!, token);
    });
  }

  void saveToken(String token) async {
    String? name;
    ApiResponse response = await getUserDetail();
    user = response.data as User?;
    name = user!.email ?? '';
    print("$name saveToken");
    await FirebaseFirestore.instance.collection("User Tokens").doc(name).set(
      {
        'token': token,
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Reservas'),
        backgroundColor: Utils.primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: user != null && user!.image != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user!.image!),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Image.asset('assets/usuariologo.png'),
                    ),
                  ),
            // Puedes mostrar un contenedor vacío si no hay imagen disponible
          ),
        ],
      ),
      body: currentIndex == 0 ? const PostScreen() : const MenuCliente(),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.of(context).push(
                MaterialPageRoute(builder: (context) => const HomePage()));
            //   Navigator.of(context)
            //       .push(MaterialPageRoute(builder: (context) => const PostForm()));
          },
          backgroundColor: Utils.secondaryColor,
          child: const Icon(Icons.calendar_month)),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Utils.secondaryColor,
        notchMargin: 5,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: const CircularNotchedRectangle(),
        child: BottomNavigationBar(
            fixedColor: Utils.secondaryColor,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: ''),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: ''),
            ],
            currentIndex: currentIndex,
            onTap: (val) {
              setState(() {
                currentIndex = val;
              });
            }),
      ),
    );
  }
}
