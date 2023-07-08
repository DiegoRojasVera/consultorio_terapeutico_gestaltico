import 'package:consultorio_terapeutico_gestaltico/pages/finish_page.dart';
import 'package:consultorio_terapeutico_gestaltico/providers/booking_provider.dart';
import 'package:consultorio_terapeutico_gestaltico/providers/services_provider.dart';
import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:consultorio_terapeutico_gestaltico/widgets/booking_action_button.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constant.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../screens/login.dart';
import '../services/user_service.dart';

class ConfirmBookingModalAdmin extends StatefulWidget {
  const ConfirmBookingModalAdmin({super.key});

  @override
  State<ConfirmBookingModalAdmin> createState() =>
      _ConfirmBookingModalAdminState();
}

class _ConfirmBookingModalAdminState extends State<ConfirmBookingModalAdmin> {
  User? user;
  bool loading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtNameController = TextEditingController();
  TextEditingController txtemailController = TextEditingController();
  TextEditingController txtPhoneController = TextEditingController();
  TextEditingController txtnombreStylist = TextEditingController();
  TextEditingController txtmensajeController = TextEditingController();

// get user detail
  void getUser() async {
    ApiResponse response = await getUserDetail();
    if (response.error == null) {
      setState(() {
        user = response.data as User;
        loading = false;
        txtNameController.text = user!.name ?? '';
        txtemailController.text = user!.email ?? '';
        txtPhoneController.text = user!.phone ?? '';
      });
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

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);
    final bookingProvider = Provider.of<BookingProvider>(context);
    final date = formatDate(servicesProvider.currentDate);
    final stylist = servicesProvider.stylist?.name;
    final price = servicesProvider.bookingService?.price;
    const mensaje = "no";

    bookingProvider.initData(
      servicesProvider.stylist!.id,
      servicesProvider.bookingService!.id,
      servicesProvider.currentDate,
    );
    txtnombreStylist.text = stylist!;
    txtmensajeController.text = mensaje;

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const _BookingTitle(value: 'Confirmar Admin'),
          const SizedBox(height: 10.0),
          TextFormField(
              controller: txtNameController,
              validator: (val) => val!.isEmpty
                  ? 'Nombre del cliente'
                  : null,
              decoration: kInputDecoration('Nombre del cliente')),
          const SizedBox(height: 10.0),
          TextFormField(
              controller: txtPhoneController,
              validator: (val) => val!.isEmpty
                  ? 'Telefono del cliente'
                  : null,
              decoration: kInputDecoration('Telefono del cliente')),
          const SizedBox(height: 10.0),
          TextFormField(
              controller: txtemailController,
              validator: (val) => val!.isEmpty
                  ? 'Correo del cliente'
                  : null,
              decoration: kInputDecoration('Correo del cliente')),
          const SizedBox(height: 10.0),
          _BookingInfo(value: date),
          const SizedBox(height: 10.0),
          _BookingInfo(value: "Con: ${txtnombreStylist.text}"),
          const SizedBox(height: 10.0),
          //_BookingInfo(value: "precio: \Gs $price"),
          const SizedBox(height: 30.0),
          BookingActionButton(
              onPressed: () => sendRequest(context, bookingProvider),
              label: 'Reserva Ahora')
        ],
      ),
    );
  }

  void sendRequest(
      BuildContext context, BookingProvider bookingProvider) async {
    bookingProvider.name = txtNameController.text;
    bookingProvider.phone = txtPhoneController.text;
    bookingProvider.email = txtemailController.text;
    bookingProvider.stylistName = txtnombreStylist.text;
    bookingProvider.mensaje = txtnombreStylist.text;

    print(txtnombreStylist.text);
    print(txtmensajeController.text);

    bookingProvider.isLoading = true;
    final success = await bookingProvider.save();
    bookingProvider.isLoading = false;

    if (success) {
      bookingProvider.clean();
      Navigator.pop(context);
      Navigator.of(context).pushReplacementNamed(FinishPage.route);
    }
  }
}

class _BookingTitle extends StatelessWidget {
  const _BookingTitle({
    Key? key,
    required this.value,
  }) : super(key: key);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w300,
          ),
      textAlign: TextAlign.center,
    );
  }
}

class _BookingInfo extends StatelessWidget {
  const _BookingInfo({
    Key? key,
    required this.value,
  }) : super(key: key);

  final String value;

  @override
  Widget build(BuildContext context) {
    return Text(
      value,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
          ),
      textAlign: TextAlign.center,
    );
  }
}
