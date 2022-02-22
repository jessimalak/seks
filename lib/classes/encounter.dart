import 'package:flutter/material.dart';

class Encounter {
  Partner partner;
  String notes;
  String place;
  double duration;
  double points;
  bool protection;
  int date;
  List<dynamic> positions;
  String id;

  Encounter(
      {required this.id,
      required this.duration,
      required this.date,
      required this.notes,
      required this.partner,
      required this.place,
      required this.points,
      required this.positions,
      required this.protection});

  Encounter.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        duration = json['duration'],
        date = json['date'],
        notes = json['notes'],
        partner = Partner.fromJson(json['partner']),
        place = json['place'],
        positions = json['positions'],
        points = json['points'],
        protection = json['protection'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'duration': duration, 'date': date, 'notes': notes, 'partner': partner.toJson(), 'place': place, 'points': points, 'positions': positions, 'protection': protection};
}

var shortMonths = ['Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun', 'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'];
var longMonths = ['Enero', 'Febrero', 'Marzo', 'Abril', 'Mayo', 'Junio', 'Julio', 'Agosto', 'Septiembre', 'Octubre', 'Noviembre', 'Diciembre'];

enum dateFormatType { textShort, textLong, moment, onlyDate }

String formatDate(int timeStamp, {bool isUtc = false, dateFormatType formatType = dateFormatType.textShort, BuildContext? context}) {
  var date = DateTime.fromMillisecondsSinceEpoch(timeStamp, isUtc: isUtc);
  String time = context != null ? TimeOfDay.fromDateTime(date).format(context) : '00:00';
  switch (formatType) {
    case dateFormatType.moment:
      return " ${date.year}-${shortMonths[date.month - 1]}-${date.day}";
    case dateFormatType.textShort:
      return "${shortMonths[date.month - 1]} ${date.day} ${date.year}, $time";
    case dateFormatType.textLong:
      return "${longMonths[date.month - 1]} ${date.day} ${date.year}, $time";
    case dateFormatType.onlyDate:
      return "${shortMonths[date.month - 1]} ${date.day} ${date.year}";
  }
}

DateTime getDate(int timeStamp) {
  return DateTime.fromMillisecondsSinceEpoch(timeStamp);
}

class Partner {
  String gender;
  String name;
  String details;
  int age;
  String id;

  Partner({required this.name, required this.age, required this.details, required this.id, required this.gender});

  Partner.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        age = json['age'],
        details = json['details'],
        id = json['id'],
        gender = json['gender'];

  Map<String, dynamic> toJson() => {'name': name, 'age': age, 'details': details, 'gender': gender, 'id': id};
}

String generateId() {
  int now = DateTime.now().millisecondsSinceEpoch;
  return now.toRadixString(32);
}
