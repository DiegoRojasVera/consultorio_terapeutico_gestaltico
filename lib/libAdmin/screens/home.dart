import 'package:consultorio_terapeutico_gestaltico/libAdmin/screens/post_screen.dart';
import 'package:flutter/material.dart';

import '../../models/api_response.dart';
import '../../models/user.dart';
import '../../services/user_service.dart';
import '../../utils/utils.dart';
import '../BNavigation/bottom_nav.dart';

class HomeAdmin extends StatefulWidget {
  const HomeAdmin({super.key});

  @override
  _HomeAdminState createState() => _HomeAdminState();
}

class _HomeAdminState extends State<HomeAdmin> {
  int index = 0;
  int currentIndex = 0;
  BNavigator? myBNB;
  User? user;

  @override
  void initState() {
    myBNB = BNavigator(currentIndex: (i) {
      setState(() {
        index = i;
      });
    });
    super.initState();
    getTokenUser();
  }

  void getTokenUser() async {
    ApiResponse response = await getUserDetail();
    user = response.data as User?;
  }

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

      body: currentIndex == 0 ? const PostScreen() : myBNB,
      //const PostForm(),  //const Profile(), ClientScreen(),ListProducts(),ListStylist,MenuCliente
      //    floatingActionButton: FloatingActionButton(
      //        onPressed: () {
      //           Navigator.of(context).push(
      //        MaterialPageRoute(builder: (context) => const HomePage()));
      //   Navigator.of(context)
      //       .push(MaterialPageRoute(builder: (context) => const PostForm()));
      //        },
      //   backgroundColor: Utils.secondaryColor,
      //    child: const Icon(Icons.calendar_month)),
      //    floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Utils.secondaryColor,
        notchMargin: 5,
        elevation: 10,
        clipBehavior: Clip.antiAlias,
        shape: const CircularNotchedRectangle(),
        child: BottomNavigationBar(
            fixedColor: Utils.secondaryColor,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Admin'),
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
