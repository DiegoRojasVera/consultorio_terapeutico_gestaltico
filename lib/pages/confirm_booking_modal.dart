import 'package:consultorio_terapeutico_gestaltico/pages/finish_page.dart';
import 'package:consultorio_terapeutico_gestaltico/providers/booking_provider.dart';
import 'package:consultorio_terapeutico_gestaltico/providers/services_provider.dart';
import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:consultorio_terapeutico_gestaltico/widgets/booking_action_button.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart';
import 'package:mailer/smtp_server/gmail.dart';
import 'package:provider/provider.dart';
import 'package:vibration/vibration.dart';



import '../constant.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../screens/login.dart';
import '../services/user_service.dart';

class ConfirmBookingModal extends StatefulWidget {
  const ConfirmBookingModal({Key? key}) : super(key: key);

  @override
  State<ConfirmBookingModal> createState() => _ConfirmBookingModalState();
}

class _ConfirmBookingModalState extends State<ConfirmBookingModal> {
  User? user;
  bool loading = true;
  GlobalKey<FormState> formKey = GlobalKey<FormState>();
  TextEditingController txtNameController = TextEditingController();
  TextEditingController txtemailController = TextEditingController();
  TextEditingController txtPhoneController = TextEditingController();
  TextEditingController txtnombreStylist = TextEditingController();
  TextEditingController txtmensajeController = TextEditingController();
  final TextEditingController _recipientEmailController =
      TextEditingController();
  final TextEditingController _recipientInicioController =
      TextEditingController();

  final TextEditingController _mailMessageController = TextEditingController();

  late String bookingInfoValue;

  // Send Mail function
  void sendMail({
    required String recipientEmail,
    required String mailMessage,
  }) async {
    // change your email here
    String username = 'confirmacionrv@gmail.com';
    // change your password here
    String password = 'zkwfsfpxpjyddlse';
    final smtpServer = gmail(username, password);
    final message = Message()
      ..from = Address(username, 'Confirmación')
      ..recipients.add(recipientEmail)
      ..subject = 'Mail'
      ..text = mailMessage;

    try {
      await send(message, smtpServer);
      showSnackbar('Email sent successfully');
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: FittedBox(
          child: Text(
            message,
            style: const TextStyle(
              fontSize: 10,
            ),
          ),
        ),
      ),
    );
  }

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
        _recipientEmailController.text = user!.email ?? '';
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

    bookingInfoValue = date;

    final String firma = "Atentamente,\nRVSolutions Apps.";
    _mailMessageController.text =
        "Buenas!\nPosee una cita con '${txtnombreStylist.text}'\nFecha: $bookingInfoValue\n\n$firma";

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      color: Colors.white,
      child: ListView(
        padding: const EdgeInsets.all(20.0),
        children: [
          const _BookingTitle(value: 'Confirmar'),
          const SizedBox(height: 30.0),
          _BookingInfo(value: "Cliente: ${txtNameController.text}"),
          const SizedBox(height: 10.0),
          _BookingInfo(value: "Teléfono: ${txtPhoneController.text}"),
          const SizedBox(height: 10.0),
          _BookingInfo(value: date),
          const SizedBox(height: 10.0),
          _BookingInfo(value: "Con: ${txtnombreStylist.text}"),
          const SizedBox(height: 10.0),
          const SizedBox(height: 30.0),
          BookingActionButton(
            onPressed: () {
              sendRequest(context, bookingProvider);
              sendMail(
                recipientEmail: _recipientEmailController.text.toString(),
                mailMessage: _mailMessageController.text.toString(),
              );
              Vibration.vibrate(duration: 100);

            },
            label: 'Reserva Ahora',
          ),
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
    bookingProvider.email = _recipientEmailController.text;

    print(txtnombreStylist.text);
    print(_recipientInicioController.text);

    print(txtmensajeController.text);
    print(_recipientEmailController.text);

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
