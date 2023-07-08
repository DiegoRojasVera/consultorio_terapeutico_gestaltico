
import 'package:consultorio_terapeutico_gestaltico/libAdmin/BNavigation/routes.dart';
import 'package:flutter/material.dart';

import '../../utils/utils.dart';

class BNavigator extends StatefulWidget {
  final Function currentIndex;

  const BNavigator({
    Key? key,
    required this.currentIndex,
  }) : super(key: key);

  @override
  State<BNavigator> createState() => _BNavigatorState();
}

class _BNavigatorState extends State<BNavigator> {
  int index = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index,
        onTap: (int i) {
          setState(() {
            index = i;
            widget.currentIndex(i);
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Utils.secondaryColor,
        iconSize: 25,
        selectedFontSize: 14,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle), label: 'Publicar'),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Administrador'),
          BottomNavigationBarItem(
              icon: Icon(Icons.apps_outage), label: 'Reservar'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_chart), label: 'Reservas'),
        ],
      ),
      body: Routes(index: index),
    );
  }
}
