import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seks/classes/auth.dart';
import 'package:seks/classes/encounter.dart';
import 'package:seks/widgets/expandableCard.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';
import '../widgets/dialogs.dart';
import 'add.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({Key? key}) : super(key: key);


  @override
  State<StatefulWidget> createState() => _CalendarScreen();
}

class _CalendarScreen extends State<CalendarScreen> {
  String name = "";
  CalendarFormat format = CalendarFormat.month;
  Map<String, List<Encounter>> dates = {};
  DateTime focusDay = DateTime.now();
  List<Encounter> encounters = [];

  @override
  void initState() {
    super.initState();
    // setData();
  }

  @override
  Widget build(BuildContext context) {
    var encountersMap = context.read<AuthService>().encounterMap;
    return Column(mainAxisSize: MainAxisSize.max, children: [
      TableCalendar(
        locale: 'es',
        weekendDays: const [],
        calendarStyle: CalendarStyle(
            isTodayHighlighted: false,
            holidayDecoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, shape: BoxShape.circle),
            holidayTextStyle: const TextStyle(color: Colors.white)),
        availableCalendarFormats: const {CalendarFormat.month: 'Mes', CalendarFormat.twoWeeks: '2 Semanas', CalendarFormat.week: 'semana'},
        focusedDay: focusDay,
        firstDay: DateTime.utc(2015, 1, 1),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        calendarFormat: format,
        startingDayOfWeek: StartingDayOfWeek.monday,
        onFormatChanged: (format_) {
          setState(() {
            format = format_;
          });
        },
        holidayPredicate: (day) {
          String i = formatDate(day.millisecondsSinceEpoch, formatType: dateFormatType.moment, isUtc: true);
          return encountersMap[i] != null;
        },
        onDaySelected: (day, day_) {
          String index = formatDate(day.millisecondsSinceEpoch, formatType: dateFormatType.moment, isUtc: true);
          setState(() {
            focusDay = day;
            encounters = encountersMap[index] ?? [];
          });
        },
      ),
      Visibility(
          visible: encounters.isEmpty,
          child: Column(
            children: [
              const Icon(
                FluentIcons.calendar_empty_24_regular,
                size: 32,
              ),
              Text(formatDate(focusDay.millisecondsSinceEpoch, formatType: dateFormatType.onlyDate, isUtc: true)),
              Text(
                'No hiciste nada este día',
                style: Theme.of(context).textTheme.headline2,
              )
            ],
          )),
      Expanded(
          child: ListView.builder(
              itemCount: encounters.length + 1,
              itemBuilder: (c, i) => i < encounters.length
                  ? ExpandableCard(
                      data: encounters[i],
                      index: i,
                    )
                  : const SizedBox(
                      height: 125,
                    )))
    ]);
  }
}
