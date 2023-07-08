import 'package:consultorio_terapeutico_gestaltico/providers/services_provider.dart';

import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:consultorio_terapeutico_gestaltico/widgets/booking_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../libAdmin/screens/home.dart';
import '../models/api_response.dart';
import '../models/user.dart';

import '../screens/home.dart';
import '../services/user_service.dart';

class FinishPage extends StatefulWidget {
  static const String route = 'finish';

  const FinishPage({super.key});

  @override
  State<FinishPage> createState() => _FinishPageState();
}

class _FinishPageState extends State<FinishPage> {
  User? user;
  String? Admin;

  void getUser() async {
    ApiResponse response = await getUserDetail();
    user = response.data as User;
    Admin = user!.admin ?? '';
    print("${Admin!}Verificacion de Admin o cliente");
    if (Admin == "true") {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeAdmin()),
          (route) => false);
    } else {
      print("modo cliente");
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const Home()),
          (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = Theme.of(context).textTheme.headline3?.copyWith(
          fontWeight: FontWeight.w700,
          color: Utils.primaryColor,
        );
    final subtitle = Theme.of(context).textTheme.headline5?.copyWith(
          fontWeight: FontWeight.w300,
        );
    final servicesProvider = Provider.of<ServicesProvider>(
      context,
      listen: false,
    );

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text('Hecho!', style: title),
            const SizedBox(height: 20.0),
            Text(
              'Te estaremos esperando con el mejor servicio..',
              style: subtitle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 100.0),
            BookingActionButton(
              label: 'Home',
              onPressed: () {
                servicesProvider.cleanAll();
                getUser();
              },
            ),
          ],
        ),
      ),
    );
  }
}
