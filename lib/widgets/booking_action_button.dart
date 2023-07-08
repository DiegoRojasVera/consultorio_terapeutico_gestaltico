import 'package:consultorio_terapeutico_gestaltico/utils/utils.dart';
import'package:flutter/material.dart';

class BookingActionButton extends StatelessWidget {
  const BookingActionButton({
    Key? key,
    required this.onPressed, required this.label,
  }) : super(key: key);

  final String label;
  final Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    // Boton del socalo
    return Container(
      color: Colors.white, // se transforma en traparente si sacamos eso
      padding: EdgeInsets.all(10),
      //  height: 80, // socalo de abajo fijo
      child: Center(
        child: ElevatedButton(
          onPressed: onPressed, //Boton del socalo de abajo
          style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 70), backgroundColor: Utils.secondaryColor,
              shape: const StadiumBorder()),
          child:  Text(label,
              style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.w300)),
        ),
      ),
    );
  }
}