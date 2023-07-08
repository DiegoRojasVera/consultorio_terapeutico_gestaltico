import 'package:consultorio_terapeutico_gestaltico/pages/home_page.dart';
import 'package:consultorio_terapeutico_gestaltico/screens/login.dart';
import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:flutter/material.dart';

import 'PostScreennologin.dart';

class homenologin extends StatefulWidget {
  static const String route = '/homenologin';

  @override
  _homenologinState createState() => _homenologinState();
}

class _homenologinState extends State<homenologin> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    PostScreennologin(),
    HomePage(),
    Login(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
            icon: Icon(Icons.calendar_today, color: Utils.secondaryColor),
            label: 'Reservar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.login, color: Utils.secondaryColor),
            label: 'Ingresar',
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
