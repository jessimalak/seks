import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:seks/classes/encounter.dart';
import 'package:seks/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GestionScreen extends StatefulWidget {
  const GestionScreen({Key? key, required this.type}) : super(key: key);

  final String type;

  @override
  State<StatefulWidget> createState() => GestionScreen_();
}

class GestionScreen_ extends State<GestionScreen> {
  List<String> places = [];
  List<Partner> partners = [];
  late SharedPreferences pref;
  GlobalKey progressKey = GlobalKey();

  Future getData() async {
    pref = await SharedPreferences.getInstance();
    if (widget.type == 'parejas') {
      var keys = pref.getKeys().where((element) => element.contains('partner_'));
      List<Partner> partners_ = [];
      for (String key in keys) {
        var data = pref.getString(key);
        if (data != null) {
          partners_.add(Partner.fromJson(jsonDecode(data)));
        }
      }
      setState(() {
        partners = partners_;
      });
    } else {
      setState(() {
        places = pref.getStringList('place_') ?? [];
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getData();
  }

  Future savePartner(Partner newPartner) async {
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

  Future savePlace(String newPlace) async {
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

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Gestionar ${widget.type}'),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            if (widget.type == 'parejas') {
              Partner? newPartner = await Dialogs.showPartnerDialog(context);
              if (newPartner != null) {
                savePartner(newPartner);
              }
            } else {
              String? newPlace = await Dialogs.showPlaceDialog(context);
              if (newPlace != null) {
                savePlace(newPlace);
              }
            }
          },
          child: const Icon(FluentIcons.add_24_regular),
        ),
        body: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            itemCount: (widget.type == 'parejas' ? partners.length : places.length) + 1,
            itemBuilder: (c, i) => i < (widget.type == 'parejas' ? partners.length : places.length)
                ? widget.type == 'parejas'
                    ? Card(
                        child: Padding(
                            padding: const EdgeInsets.fromLTRB(15, 0, 15, 20),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                Text(partners[i].name),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    IconButton(
                                      onPressed: () async {
                                        Partner? edited = await Dialogs.showPartnerDialog(context, partner: partners[i]);
                                        if (edited != null) {
                                          Dialogs.showLoadingDialog(context, progressKey, 'Guardando...');
                                          await pref.setString('partner_${edited.id}', jsonEncode(edited.toJson()));
                                          User? user_ = FirebaseAuth.instance.currentUser;
                                          if (user_ != null) {
                                            await FirebaseFirestore.instance.collection('users').doc(user_.uid).collection('partners').doc('partner_${partners[i].id}').set(edited.toJson());
                                          }
                                          var data = partners;
                                          data[i] = edited;
                                          setState(() {
                                            partners = data;
                                          });
                                          Navigator.of(progressKey.currentContext ?? context).pop();
                                        }
                                      },
                                      icon: const Icon(FluentIcons.edit_24_regular),
                                      iconSize: 16,
                                      padding: const EdgeInsets.all(0.5),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        bool? delete = await Dialogs.showDeleteDialog(context, '¿Quieres eliminar a ${partners[i].name}');
                                        if (delete) {
                                          Dialogs.showLoadingDialog(context, progressKey, 'Eliminando...');
                                          await pref.remove('partner_${partners[i].id}');
                                          User? user_ = FirebaseAuth.instance.currentUser;
                                          if (user_ != null) {
                                            await FirebaseFirestore.instance.collection('users').doc(user_.uid).collection('partners').doc('partner_${partners[i].id}').delete();
                                          }
                                          var data = partners;
                                          data.removeAt(i);
                                          setState(() {
                                            partners = data;
                                          });
                                          Navigator.of(progressKey.currentContext ?? context).pop();
                                        }
                                      },
                                      icon: const Icon(FluentIcons.delete_24_regular),
                                      iconSize: 16,
                                      padding: const EdgeInsets.all(0.5),
                                    )
                                  ],
                                )
                              ]),
                              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${partners[i].age} años'), Text(partners[i].gender)]),
                              partners[i].details.isNotEmpty ? Text(partners[i].details) : const SizedBox()
                            ])),
                      )
                    : Card(
                        child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                              Text(places[i]),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: () async {
                                      bool? delete = await Dialogs.showDeleteDialog(context, '¿Quieres eliminar ${places[i]}');
                                      if(delete){
                                        Dialogs.showLoadingDialog(context, progressKey, 'Eliminando...');
                                        User? user_ = FirebaseAuth.instance.currentUser;
                                        if (user_ != null) {
                                          var ref = FirebaseFirestore.instance.collection('users').doc(user_.uid).collection('places');
                                          var docs = await ref.get();
                                          for (var element in docs.docs) {
                                            var item = element.data();
                                            if (item['name'] == places[i]) {
                                              await ref.doc(element.id).delete();
                                              break;
                                            }
                                          }
                                        }
                                        var places_ = places;
                                        places_.removeAt(i);
                                        await pref.setStringList('place_', places_);
                                        setState(() {
                                          places = places_;
                                        });
                                        Navigator.pop(progressKey.currentContext ?? context);
                                      }
                                    },
                                    icon: const Icon(FluentIcons.delete_24_regular),
                                    iconSize: 16,
                                    padding: const EdgeInsets.all(0.5),
                                  )
                                ],
                              )
                            ])),
                      )
                : const SizedBox(
                    height: 72,
                  )),
      );
}
