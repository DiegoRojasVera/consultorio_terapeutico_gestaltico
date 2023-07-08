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

  int _currentIndex = 0;

  final List<Widget> _screens = [
    PostScreen(),
    HomePage(),
    MenuCliente(),
  ];

  TextEditingController username = TextEditingController();
  TextEditingController body = TextEditingController();
  TextEditingController title = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTokenUser();
    startTime = DateTime.now();
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

  DateTime? startTime;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          'Reservas',
          style: TextStyle(
            fontFamily:
                'Beauty Salon', // Reemplaza 'Beauty Salon' con el nombre de la fuente deseada
          ),
        ),
        backgroundColor: Utils.primaryColor,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: user != null && user!.image != null
                ? CircleAvatar(
                    backgroundImage: NetworkImage(user!.image!),
                    key: Key(user!.image!),
                    child: ClipOval(
                      child: Image.network(
                        user!.image!,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          final totalBytes = loadingProgress.expectedTotalBytes;
                          final loadedBytes =
                              loadingProgress.cumulativeBytesLoaded;
                          if (totalBytes != null && loadedBytes != null) {
                            final progress = loadedBytes / totalBytes;
                            final elapsedTime =
                                DateTime.now().difference(startTime!).inSeconds;
                            print('Tiempo de carga: $elapsedTime segundos');
                          }
                          return child;
                        },
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: ClipOval(
                      child: Image.asset('assets/usuariologo.png'),
                    ),
                  ),
          ),
        ],
      ),
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        selectedItemColor: Utils.secondaryColor,
        unselectedItemColor: Colors.black26,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.new_releases, color: Utils.secondaryColor),
            label: 'Novedades',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month, color: Utils.secondaryColor),
            label: 'Agendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Utils.secondaryColor),
            label: 'Mi cuenta',
          ),
        ],
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Home Screen',
        style: TextStyle(fontSize: 24),
      ),
    );
  }
}
