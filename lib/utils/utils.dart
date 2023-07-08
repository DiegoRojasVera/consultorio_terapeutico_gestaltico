import 'package:flutter/material.dart';

class Utils {
  static const Color primaryColor = Color.fromRGBO(233, 189, 160, 1.0);
  static const Color secondaryColor = Color.fromRGBO(120, 82, 61, 1.0);
  static const Color grayColor = Color.fromRGBO(190, 190, 190, 1.0);
}

String formatDate(DateTime date) {
  final month = date.month < 10 ? "0${date.month}" : "${date.month}";
  final day = date.day < 10 ? "0${date.day}" : "${date.day}";
  final fHour = formatHour(date);
  return "$day/$month/${date.year} $fHour";
}

String formatHour(DateTime date) {
  final am = date.hour < 12 ? 'AM' : 'PM';
  final hour = date.hour < 10 ? "0${date.hour}" : "${date.hour}";
  return "$hour:00 $am";
}

String formatTimestamp(DateTime date) {
  final month = date.month < 10 ? "0${date.month}" : "${date.month}";
  final day = date.day < 10 ? "0${date.day}" : "${date.day}";
  final hour = date.hour < 10 ? "0${date.hour}" : "${date.hour}";
  final minute = date.minute < 10 ? "0${date.minute}" : "${date.minute}";

  // 2021-06-24 20:00:00
  return "${date.year}-$month-$day $hour:$minute:00";
}
