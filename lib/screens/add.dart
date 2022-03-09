import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seks/classes/auth.dart';
import 'package:seks/classes/encounter.dart';
import 'package:seks/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddScreen extends StatefulWidget {
  const AddScreen({Key? key, this.data}) : super(key: key);
  final Encounter? data;

  @override
  State<StatefulWidget> createState() => _AddScreen();
}

class _AddScreen extends State<AddScreen> {
  List<Partner> partners = [];
  List<String> places = ['Su casa', 'Mi casa'];
  List<dynamic> positions = [];
  late SharedPreferences pref;
  GlobalKey progressKey = GlobalKey();

  DateTime date = DateTime.now();
  bool protection = true;
  double points = 3;
  GlobalKey<FormState> formKey = GlobalKey();
  TextEditingController dateController = TextEditingController();
  TextEditingController timeController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  TextEditingController notesController = TextEditingController();
  Partner? partner;
  String? place;

  List<String> positionsList = [
    'Perrito',
    'Misionero',
    'Misionero enganchado',
    '69',
    '69 de pie',
    'Helicoptero',
    'Cara a cara',
    'La bicicleta',
    'El enchufe',
    'Perro tumbado',
    'Cucharita',
    'Gato',
    'Catarata',
    'Vaquera',
    'Vaquera invertida',
    'Vaquero',
    'Vaquero invertido',
    'Silla caliente',
    'El vago',
    'El trono',
    'El pretzel',
    'Estantería',
    'Patitas arriba',
    'Mantequilla',
    'Bailarina',
    'El chef',
    'La carretilla',
    'Carretilla sentad@',
    'Surfero',
    'Regalo envuelto',
    'La X',
    'Ángel de las nieves',
    'Tijerita',
    'Araña',
    'Mariposa',
    'Libelula',
    'Ascensor',
    'El estandarte'
  ];

  @override
  void initState() {
    super.initState();
    setPref();
  }

  Future setPref() async {
    pref = await SharedPreferences.getInstance();
    List<String> data = pref.getKeys().toList();
    List<String> places_ = ['Mi casa', 'Su casa'];
    List<Partner> partners_ = [];
    for (var key in data) {
      if (key.contains('place_')) {
        places_ = pref.getStringList(key) ?? [];
      } else if (key.contains('partner_')) {
        var value = pref.getString(key);
        if (value != null) {
          Map<String, dynamic> item = jsonDecode(value);
          partners_.add(Partner.fromJson(item));
        }
      }
    }
    setState(() {
      places = places_;
      partners = partners_;
    });
    var toEdit = widget.data;
    if (toEdit != null) {
      setState(() {
        date = DateTime.fromMillisecondsSinceEpoch(toEdit.date);
        positions = toEdit.positions;
        partner = toEdit.partner;
        protection = toEdit.protection;
        points = toEdit.points;
        place = toEdit.place;
      });
      durationController.text = toEdit.duration.toString();
      notesController.text = toEdit.notes;
      dateController.text = formatDate(toEdit.date, formatType: dateFormatType.onlyDate);
      timeController.text = TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(toEdit.date)).format(context);
    }
  }

  Future save() async {
    if (formKey.currentState!.validate()) {
      Dialogs.showLoadingDialog(context, progressKey, 'Guardando...');
      String id = widget.data?.id ?? generateId();
      Encounter newEncounter = Encounter(
          id: id,
          duration: double.parse(durationController.text),
          date: date.millisecondsSinceEpoch,
          notes: notesController.text,
          partner: partner ?? Partner(name: 'name', age: 0, details: 'details', gender: 'gender', id: ''),
          place: place ?? '',
          points: points,
          positions: positions,
          protection: protection);
      await pref.setString('encounter_$id', jsonEncode(newEncounter.toJson()));
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore storage = FirebaseFirestore.instance;
        await storage.collection('users').doc(user.uid).collection('encounters').doc('encounter_$id').set(newEncounter.toJson());
      }
      if(widget.data == null){
        context.read<AuthService>().addEncounter(newEncounter);
      }
      Navigator.of(progressKey.currentContext ?? context).pop();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(FluentIcons.arrow_left_24_regular)),
          title: const Text('Añadir encuentro'),
        ),
        floatingActionButton: Visibility(
          visible: MediaQuery.of(context).viewInsets.bottom == 0,
          child: FloatingActionButton(onPressed: save, child: const Icon(FluentIcons.save_24_regular)),
        ),
        body: SingleChildScrollView(
            child: Form(
          key: formKey,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                          child: InkWell(
                        onTap: () async {
                          var date_ = await showDatePicker(context: context, initialDate: date, firstDate: DateTime.utc(2015, 1, 1), lastDate: DateTime.now(), locale: Locale('es'));
                          if (date_ != null) {
                            setState(() {
                              date = date_;
                            });
                            dateController.text = formatDate(date_.millisecondsSinceEpoch, formatType: dateFormatType.onlyDate);
                          }
                        },
                        child: TextFormField(
                          enabled: false,
                          controller: dateController,
                          validator: (val) => val!.isEmpty ? '¿Cuándo pasó todo?' : null,
                          decoration: const InputDecoration(hintText: 'Fecha', errorStyle: TextStyle(color: Colors.red), icon: Icon(FluentIcons.calendar_empty_24_regular)),
                        ),
                      )),
                      Expanded(
                          child: InkWell(
                        onTap: () async {
                          var time_ = await showTimePicker(
                              context: context,
                              initialTime: widget.data != null ? TimeOfDay.fromDateTime(DateTime.fromMillisecondsSinceEpoch(widget.data?.date ?? 0)) : TimeOfDay.now(),
                              confirmText: 'OK');
                          if (time_ != null) {
                            var dateWithHour = date;
                            if (widget.data != null) {
                              dateWithHour = dateWithHour.subtract(Duration(minutes: date.minute, hours: date.hour));
                            }
                            setState(() {
                              date = dateWithHour.add(Duration(minutes: time_.minute, hours: time_.hour));
                            });
                            timeController.text = time_.format(context);
                          }
                        },
                        child: TextFormField(
                          enabled: false,
                          controller: timeController,
                          validator: (val) => val!.isEmpty ? '¿A qué hora sucedió?' : null,
                          decoration: const InputDecoration(hintText: 'Hora', icon: Icon(FluentIcons.clock_alarm_24_regular)),
                        ),
                      ))
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                          child: DropdownButtonFormField(
                        value: place,
                        hint: const Text('Lugar'),
                        validator: (val) => val == null ? '¿Dónde fue?' : null,
                        decoration: const InputDecoration(icon: Icon(FluentIcons.location_24_regular)),
                        items: places
                            .map((e) => DropdownMenuItem(
                                  child: Text(e),
                                  value: e,
                                ))
                            .toList(),
                        onChanged: (String? value) {
                          if (value != null) {
                            setState(() {
                              place = value;
                            });
                          }
                        },
                      )),
                      TextButton(
                          onPressed: () async {
                            var newPlace = await Dialogs.showPlaceDialog(context);
                            if (newPlace != null) {
                              Dialogs.showLoadingDialog(context, progressKey, 'Guardando...');
                              var places_ = places;
                              places_.add(newPlace);
                              await pref.setStringList('place_', places_);
                              User? user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                FirebaseFirestore storage = FirebaseFirestore.instance;
                                await storage.collection('users').doc(user.uid).collection('places').add({'name': newPlace, 'addDate': DateTime.now().millisecondsSinceEpoch});
                              }
                              setState(() {
                                places = places_;
                              });
                              Navigator.of(progressKey.currentContext ?? context).pop();
                            }
                          },
                          child: const Icon(FluentIcons.add_24_regular))
                    ],
                  ),
                  Visibility(
                      visible: widget.data == null,
                      child: Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Expanded(
                              child: DropdownButtonFormField(
                            hint: const Text('Pareja'),
                            validator: (val) => val == null && widget.data == null ? '¿Con quién lo hiciste?' : null,
                            decoration: const InputDecoration(icon: Icon(FluentIcons.person_24_regular)),
                            items: partners
                                .map((e) => DropdownMenuItem(
                                      child: Text(e.name),
                                      value: e,
                                    ))
                                .toList(),
                            onChanged: (Partner? value) {
                              if (value != null) {
                                setState(() {
                                  partner = value;
                                });
                              }
                            },
                          )),
                          TextButton(
                              onPressed: () async {
                                Partner? newPartner = await Dialogs.showPartnerDialog(context);
                                if (newPartner != null) {
                                  Dialogs.showLoadingDialog(context, progressKey, 'Guardando...');
                                  var partnerList = partners;
                                  partnerList.add(newPartner);
                                  String id = 'partner_${generateId()}';
                                  User? user = FirebaseAuth.instance.currentUser;
                                  newPartner.id = id.replaceAll('partner_', '');
                                  if (user != null) {
                                    FirebaseFirestore storage = FirebaseFirestore.instance;
                                    await storage.collection('users').doc(user.uid).collection('partners').doc(id).set(newPartner.toJson());
                                  }
                                  setState(() {
                                    partners = partnerList;
                                  });
                                  await pref.setString(id, jsonEncode(newPartner.toJson()));
                                  Navigator.of(progressKey.currentContext ?? context).pop();
                                }
                              },
                              child: const Icon(FluentIcons.add_24_regular))
                        ],
                      )),
                  Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Row(
                        children: [
                          Expanded(
                              child: Row(
                            children: [
                              const Icon(
                                FluentIcons.lock_closed_24_regular,
                                color: Color(0xff909090),
                              ),
                              const Padding(
                                  padding: EdgeInsets.only(left: 15),
                                  child: Text(
                                    'Protección',
                                    style: TextStyle(fontSize: 16),
                                  )),
                              Checkbox(
                                  value: protection,
                                  onChanged: (val) {
                                    setState(() {
                                      protection = val!;
                                    });
                                  })
                            ],
                          )),

                          TextFormField(
                            controller: durationController,
                            validator: (val) => val!.isEmpty ? 'También se vale 0.001' : null,
                            decoration: InputDecoration(
                                constraints: const BoxConstraints(maxWidth: 155),
                                icon: const Icon(FluentIcons.timer_24_regular),
                                hintText: 'Duración',
                                suffixIcon: Column(
                                  children: const [Text('Horas')],
                                  mainAxisAlignment: MainAxisAlignment.center,
                                )),
                            keyboardType: TextInputType.number,
                          ),
                          // Text('Horas')
                        ],
                      )),
                  Row(children: [
                    const Icon(FluentIcons.star_24_regular, color: Color(0xff909090)),
                    Padding(
                      padding: const EdgeInsets.only(left: 15),
                      child: Text(
                        "Puntuación: $points",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ]),
                  Slider(
                      label: points.toString(),
                      value: points,
                      max: 5,
                      divisions: 10,
                      onChanged: (val) {
                        setState(() {
                          points = val;
                        });
                      }),
                  Autocomplete<String>(
                    optionsBuilder: (value) {
                      if (value.text.isEmpty) {
                        return const Iterable.empty();
                      }
                      return positionsList.where((e) => e.toLowerCase().contains(value.text.toLowerCase()));
                    },
                    fieldViewBuilder: (c, controller, focusNode, onEditingComplete) => TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onEditingComplete: onEditingComplete,
                      onSubmitted: (val) {
                        if (val.trim().isNotEmpty) {
                          var newList = positions;
                          newList.add(val);
                          setState(() {
                            positions = newList;
                          });
                          controller.text = '';
                        }
                      },
                      decoration: const InputDecoration(hintText: 'Posiciones', icon: Icon(FluentIcons.people_24_regular)),
                    ),
                  ),
                  Wrap(
                    children: positions
                        .map((e) => Chip(
                              label: Text(e),
                              deleteIcon: const Icon(
                                FluentIcons.dismiss_24_regular,
                                size: 18,
                              ),
                              onDeleted: () {
                                var newList = positions;
                                newList = newList.where((element) => element != e).toList();
                                setState(() {
                                  positions = newList;
                                });
                              },
                            ))
                        .toList(),
                  ),
                  TextFormField(
                    controller: notesController,
                    minLines: 2,
                    maxLines: 5,
                    decoration: const InputDecoration(hintText: 'Notas', icon: Icon(FluentIcons.comment_24_regular)),
                  )
                ],
              )),
        )),
      );
}
