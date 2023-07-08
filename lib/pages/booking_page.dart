import 'dart:convert';

import 'package:consultorio_terapeutico_gestaltico/models/service.dart';
import 'package:consultorio_terapeutico_gestaltico/models/stylist.dart';
import 'package:consultorio_terapeutico_gestaltico/pages/confirm_booking_modal.dart';
import 'package:consultorio_terapeutico_gestaltico/providers/services_provider.dart';
import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import 'package:consultorio_terapeutico_gestaltico/widgets/booking_action_button.dart';
import 'package:consultorio_terapeutico_gestaltico/widgets/calendar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

import '../models/api_response.dart';
import '../models/user.dart';
import '../screens/login.dart';
import '../services/user_service.dart';
import 'confirm_booking_modal_admin.dart';
import 'detallesStylist.dart';

class BookingPage extends StatefulWidget {
  static const String route = '/booking';

  const BookingPage({super.key});

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  @override
  void initState() {
    super.initState();
    () async {
      await Future.delayed(Duration.zero);
      final service = ModalRoute.of(context)!.settings.arguments as Service;
      final servicesProvider = Provider.of<ServicesProvider>(
        context,
        listen: false,
      );
//      servicesProvider.clean();
      servicesProvider.loadServiceForBooking(service);
    }();
    getButtom();
  }

  void _showAlertDialog() {
    showDialog(
        context: context,
        builder: (buildcontext) {
          return AlertDialog(
            title: const Text("Mensaje"),
            content: const Text(
                "Para poder llevar a cabo las reservas, es necesario iniciar sesión."),
            actions: <Widget>[
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Utils.secondaryColor),
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => const Login()),
                      (route) => false);
                },
                child: const Text(
                  "Iniciar sesión",
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          );
        });
  }

  User? user;
  String? Admin;

  void getButtom() async {
    ApiResponse response = await getUserDetail();
    user = response.data as User;
    Admin = user!.admin ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final service = ModalRoute.of(context)!.settings.arguments as Service;
    final servicesProvider = Provider.of<ServicesProvider>(context);
    void getButtom() async {
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
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return const ConfirmBookingModalAdmin();
          },
        );
      } else {
        if (kDebugMode) {
          print("modo cliente");
        }
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (BuildContext context) {
            return const ConfirmBookingModal();
          },
        );
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0.0,
        title: const Text('Establecer cita'),
        backgroundColor: Utils.primaryColor,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => servicesProvider.loadServiceForBooking(service),
        color: Utils.secondaryColor,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _BookingMainContent(),
            ),
            BookingActionButton(
              label: 'Reservar ahora',
              onPressed: !servicesProvider.canFinalizeAppointment
                  ? null
                  : () async {
                      if (user == null) {
                        print(user);
                        _showAlertDialog();
                        print("es nulo");
                      } else {
                        getButtom();
                      }
                    },
            )
          ],
        ),
      ),
    );
  }
}

class _BookingMainContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);
    List<Widget> times = [];

    // Horario de atención de 10:00 am hasta las 8:00pm (10:00 - 20:00)
    for (var i = 8; i <= 21; i++) {
      int status = _BookingTime.normal;
      final stylist = servicesProvider.stylist;
      final current = DateTime(servicesProvider.year, servicesProvider.month,
          servicesProvider.day, i, 0, 0);

      // Si la fecha seleccionada es igual a la fecha
      // actual en el loop se marca como seleccionada.
      if (servicesProvider.currentDate.compareTo(current) == 0) {
        status = _BookingTime.selected;
      }
      if (servicesProvider.minDate.compareTo(current) > 0) {
        status = _BookingTime.blocked;
      }
      if (stylist != null) {
        //stylist.lockedDates.forEach((lockedDate) {
        for (var lockedDate in stylist.lockedDates) {
          if (lockedDate.compareTo(current) == 0) {
            status = _BookingTime.blocked;
          }
        }
      }

      times.add(_BookingTime(
        status: status,
        time: formatHour(current),
        onTap: () => servicesProvider.hour = i,
      ));
    }

    return servicesProvider.isLoadingService ||
            servicesProvider.bookingService == null
        ? const Column(
            children: [
              Calendar(),
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Utils.secondaryColor,
                    ),
                  ),
                ),
              ),
            ],
          )
        : ListView(
            children: [
              const Calendar(),
              const _Subtitle(subtitle: 'Estilistas'),
              _StylistsList(
                  stylists: servicesProvider.bookingService!.stylists),
              const SizedBox(height: 10.0),
              const _Subtitle(subtitle: 'Tiempo disponible'),
              const SizedBox(height: 10.0),
              SizedBox(
                height: (times.length / 3).ceil() * 55.0,
                child: GridView.count(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 10,
                  childAspectRatio: 2.9,
                  crossAxisCount: 3,
                  physics: const NeverScrollableScrollPhysics(),
                  children: times,
                ),
              ),
            ],
          );
  }
}

class _BookingTime extends StatelessWidget {
  const _BookingTime({
    Key? key,
    required this.time,
    required this.status,
    required this.onTap,
  }) : super(key: key);

  final String time;
  final int status;
  final Function() onTap;

  static const int normal = 1;
  static const int selected = 2;
  static const int blocked = 3;

  @override
  Widget build(BuildContext context) {
    Color backgroundColor = Utils.primaryColor;
    Color textColor = Colors.white;

    if (status == selected) {
      backgroundColor = Utils.secondaryColor;
    } else if (status == blocked) {
      backgroundColor = Utils.grayColor;
    }

    return Material(
      borderRadius: const BorderRadius.all(Radius.circular(10.0)),
      child: InkWell(
        onTap: status == normal ? onTap : null,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        splashColor: Utils.secondaryColor,
        child: Ink(
          padding: const EdgeInsets.all(5.0),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          ),
          child: Center(
            child: Text(
              time,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: textColor,
                    fontSize: 18.0,
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StylistsList extends StatelessWidget {
  const _StylistsList({
    Key? key,
    required this.stylists,
  }) : super(key: key);

  final List<Stylist> stylists;

  @override
  Widget build(BuildContext context) {
    final servicesProvider = Provider.of<ServicesProvider>(context);
    final currentDate = servicesProvider.currentDate;

    return SizedBox(
      height: 210.0,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: stylists.length,
        itemBuilder: (_, int index) {
          final stylist = stylists[index];
          final isSelected = servicesProvider.stylist != null &&
              servicesProvider.stylist?.id == stylist.id &&
              currentDate == servicesProvider.currentDate; // Comprobar si la fecha se ha modificado

          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 20.0 : 0.0,
              right: index == stylists.length - 1 ? 60.0 : 20.0,
            ),
            child: StylistCard(
              stylist: stylist,
              isSelected: isSelected,
              onTap: () {
                if (!isSelected) {
                  servicesProvider.stylist = stylist;
                }
              },
            ),
          );
        },
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({
    Key? key,
    required this.subtitle,
  }) : super(key: key);

  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Text(
        subtitle,
        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w300,
            ),
      ),
    );
  }
}

class StylistCard extends StatelessWidget {
  const StylistCard({
    Key? key,
    required this.stylist,
    this.isSelected = false, // Establecer isSelected en false por defecto
    required this.onTap,
  }) : super(key: key);

  final Stylist stylist;
  final bool isSelected;
  final Function() onTap;

  Future<String> getDataCalificacion() async {
    String nombre = stylist.name;
    try {
      final response = await http.get(
        Uri.parse("http://34.171.207.241/api/puntuacion/promedio/$nombre"),
      );
      if (response.statusCode == 200) {
        Map<String, dynamic> datos = json.decode(response.body);
        String promedio = datos["promedio"] ?? "0";
        print(promedio);
        return promedio;
      } else {
        print('Error en la solicitud HTTP: ${response.statusCode}');
        return "0";
      }
    } catch (e) {
      print('Error en la solicitud HTTP: $e');
      return "0";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        onTap: isSelected ? null : onTap,
        child: Ink(
          padding: const EdgeInsets.all(15.0),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(10.0)),
            color: Colors.white,
            border: Border.all(
              color: isSelected ? Utils.primaryColor : Utils.grayColor,
              width: 2.0,
            ),
          ),
          child: Column(
            children: [
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: FadeInImage(
                  placeholder: const AssetImage('assets/haircut.jpg'),
                  image: NetworkImage(stylist.photo),
                  fit: BoxFit.cover,
                  width: 100.0,
                  height: 70,
                ),
              ),
              const SizedBox(height: 10.0),
              Text(
                stylist.name,
                style: Theme.of(context).textTheme.headline6,
              ),
              const SizedBox(height: 10.0),
              Expanded(
                child: FutureBuilder<String>(
                  future: getDataCalificacion(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String> snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Utils.secondaryColor,
                          ),
                        ),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    }
                    String data = snapshot.data ?? '0';
                    if (data is String) {
                      double initialRating = double.tryParse(data) ?? 0;
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            RatingBar.builder(
                              itemCount: 5,
                              initialRating: initialRating,
                              allowHalfRating: true,
                              itemSize: 15,
                              itemBuilder: (context, _) {
                                return const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                );
                              },
                              onRatingUpdate: (rating) {
                                print(rating);
                              },
                            ),
                            const SizedBox(height: 2),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => DetailPage(
                                      stylistId: stylist.id,
                                      stylistName: stylist.name,
                                    ),
                                  ),
                                );
                              },
                              child: const Text(
                                "Detalles",
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: Utils.secondaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Center(
                        child: Text('Error: Unexpected data format'),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
