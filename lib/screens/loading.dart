import 'package:consultorio_terapeutico_gestaltico/models/api_response.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../constant.dart';
import '../libAdmin/screens/home.dart';
import '../libAdmin/screens/homenologin.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../utils/utils.dart';
import 'home.dart';
import 'login.dart';

class Loading extends StatefulWidget {
  static const String route = '/Loading';

  const Loading({Key? key}) : super(key: key);

  @override
  State<Loading> createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {
  User? user;
  String? Admin;
  String textToken = "";

  void verificacionuser() async {
    ApiResponse response = await getUserDetail();
    if (response.data != null) {
      user = response.data as User;
      Admin = user!.admin ?? '';
      _loadUserInfo();
    } else {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) =>  homenologin()),
              (route) => false
      );
      print("No es usuario, menú sin usuario");
    }
  }

  void getUser() async {
    ApiResponse response = await getUserDetail();
    user = response.data as User;
    Admin = user!.admin ?? '';
    if (kDebugMode) {
      print("${Admin!}Verificación de Admin o cliente");
    }
    if (Admin == "true") {
      if (kDebugMode) {
        print("modo Admin");
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeAdmin()),
          (route) => false);
    } else {
      if (kDebugMode) {
        print("modo cliente");
      }
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);
    }
  }

  @override
  void initState() {
    super.initState();
    verificacionuser();
  }

  void _loadUserInfo() async {
    String token = await getToken();
    if (token == '') {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Login()),
          (route) => false);
    } else {
      ApiResponse response = await getUserDetail();
      if (response.error == null) {
        getUser();
      } else if (response.error == unauthorized) {
        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${response.error}'),
        ));

        Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const Login()),
            (route) => false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      color: Colors.white,
      child: const Center(
        child: CircularProgressIndicator(
          backgroundColor: Utils.secondaryColor,
        ),
      ),
    );
  }
}
