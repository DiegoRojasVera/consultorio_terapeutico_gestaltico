import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/service.dart';
import '../providers/services_provider.dart';
import '../utils/utils.dart';

class Calendar extends StatelessWidget {
  const Calendar({Key? key}) : super(key: key);

  @override
  @override
  Widget build(BuildContext context) {
    ServicesProvider servicesProvider = Provider.of<ServicesProvider>(context);

    final int currentYear = servicesProvider.year;
    final String currentMonth =
    servicesProvider.months[servicesProvider.month - 1];

    List<Widget> calendarDays = [];
    final today = DateTime.now();
    final startDate = DateTime(
      servicesProvider.year,
      servicesProvider.month,
      1,
      servicesProvider.currentDate.hour,
      0,
      0,
    );

    for (var i = 0; i < servicesProvider.countMonthDays; i++) {
      final current = startDate.add(Duration(days: i));

      if (current.isBefore(today)) {
        continue; // Saltar días vencidos
      }
      final service = ModalRoute.of(context)!.settings.arguments as Service;

      calendarDays.add(
        _CalendarDay(
          weekDay: servicesProvider.weekdays[current.weekday - 1],
          day: current.day,
          isSelected: servicesProvider.currentDate.compareTo(current) == 0,
          onTap: () async {
            servicesProvider.day = current.day;
            servicesProvider.hour = 0; // Reiniciar la hora seleccionada a cero
            await servicesProvider.loadServiceForBooking(service);
            print("Se modificó la fecha");
          },
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const SizedBox(height: 5.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left_outlined, size: 30.0),
                color: Utils.secondaryColor,
                onPressed: () {
                  servicesProvider.changeMonth(false);
                },
              ),
              const SizedBox(width: 15.0),
              Text(
                "$currentMonth ($currentYear)",
                style: const TextStyle(fontSize: 22.0),
              ),
              const SizedBox(width: 15.0),
              IconButton(
                icon: const Icon(Icons.arrow_right_outlined, size: 30.0),
                color: Utils.secondaryColor,
                onPressed: () {
                  servicesProvider.changeMonth(true);
                },
              ),
            ],
          ),
          SizedBox(
            height: 100.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: calendarDays,
            ),
          ),
        ],
      ),
    );
  }
}

class _CalendarDay extends StatelessWidget {
  const _CalendarDay({
    required this.weekDay,
    required this.day,
    required this.isSelected,
    required this.onTap,
  });

  final String weekDay;
  final int day;
  final bool isSelected;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: 10.0,
        ),
        child: Column(
          children: [
            const SizedBox(height: 5.0),
            Text(weekDay),
            Text(
              "$day",
              style: const TextStyle(fontSize: 20.0),
            ),
            const SizedBox(height: 10.0),
            isSelected
                ? Container(
              height: 8.0,
              width: 50.0,
              decoration: const BoxDecoration(
                color: Utils.primaryColor,
              ),
            )
                : Container(
              height: 6.0,
              width: 40.0,
              decoration: const BoxDecoration(
                color: Colors.transparent,
                border: Border(
                  bottom: BorderSide(
                    color: Utils.grayColor,
                    width: 1.0,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
