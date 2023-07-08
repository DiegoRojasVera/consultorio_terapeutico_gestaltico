import 'package:consultorio_terapeutico_gestaltico/libAdmin/BNavigation/reservas.dart';
import 'package:flutter/cupertino.dart';

import '../../pages/home_page.dart';
import '../screens/menuClient.dart';
import '../screens/post_form.dart';

class Routes extends StatelessWidget {
  final int index;

  const Routes({Key? key, required this.index}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> myList = [
      //Listas de paginas que van a parecer
      const PostForm(),
      const MenuCliente(),
      const HomePage(),
      const Reservas(),
    ];
    return myList[index];
  }
}
