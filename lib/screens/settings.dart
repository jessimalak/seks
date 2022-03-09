import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth_;
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seks/classes/auth.dart';
import 'package:seks/classes/encounter.dart';
import 'package:seks/classes/user.dart';
import 'package:seks/screens/gestion.dart';
import 'package:seks/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _SettingsScreen();
}

class _SettingsScreen extends State<SettingsScreen> {
  GlobalKey progressKey = GlobalKey();

  Future syncData(String id) async {
    Dialogs.showLoadingDialog(context, progressKey, 'Sincronizando datos....');
    FirebaseFirestore storage = FirebaseFirestore.instance;
    SharedPreferences pref = await SharedPreferences.getInstance();
    List<Encounter> enc = [];
    List<String> ids = [];
    var db = storage.collection('users').doc(id);
    var localKeys = pref.getKeys();
    var dbEnc = db.collection('encounters');
    var dbPartners = db.collection('partners');
    var dbPlaces = db.collection('places');
    var encounters_ = await dbEnc.get();
    for (var element in encounters_.docs) {
      ids.add(element.id);
      enc.add(Encounter.fromJson(element.data()));
      if (!pref.containsKey(element.id)) {
        await pref.setString(element.id, jsonEncode(element.data()));
      }
    }
    var places_ = await dbPlaces.get();
    List<String> localPlaces = pref.getStringList('place_') ?? [];
    List<String> dbPlaces_ = [];
    for (var element in places_.docs) {
      dbPlaces_.add(element['name']);
      if (!localPlaces.contains(element['name'])) {
        localPlaces.add(element['name']);
      }
    }
    await pref.setStringList('place_', localPlaces);
    var partners_ = await dbPartners.get();
    for (var element in partners_.docs) {
      ids.add(element.id);
      if (!pref.containsKey(element.id)) {
        await pref.setString(element.id, jsonEncode(element.data()));
      }
    }
    for (String localId in localKeys) {
      if (!ids.contains(localId)) {
        if (localId.contains('encounter_')) {
          var source = pref.getString(localId);
          if (source != null) {
            enc.add(Encounter.fromJson(jsonDecode(source)));
            await dbEnc.doc(localId).set(jsonDecode(source));
          }
        } else if (localId.contains('partner_')) {
          var source = pref.getString(localId);
          if (source != null) {
            await dbPartners.doc(localId).set(jsonDecode(source));
          }
        }
      }
    }
    for (String name in localPlaces) {
      if (!dbPlaces_.contains(name)) {
        await dbPlaces.add({'name': name, 'addDate': DateTime.now().millisecondsSinceEpoch});
      }
    }
    Navigator.of(progressKey.currentContext ?? context, rootNavigator: true).pop();
    context.read<AuthService>().setEncounters(enc);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(FluentIcons.arrow_left_24_regular)),
        title: const Text('Ajustes'),
      ),
      body: ListView(
        children: [
          StreamBuilder(
              stream: auth.user,
              builder: (BuildContext c, AsyncSnapshot<User?> snap) {
                if (snap.hasData) {
                  return Column(children: [
                    ListTile(
                      title: Text(snap.data?.displayName ?? ''),
                      subtitle: Text(snap.data?.email ?? ''),
                      trailing: IconButton(
                          onPressed: () async {
                            bool? logout = await showDialog(
                                context: context,
                                builder: (c) => AlertDialog(
                                      title: const Text('¿Quieres cerrar la sesión?'),
                                      content: const Text('Tu datos dejarán de sincronizarse con la nube'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(false);
                                            },
                                            child: const Text('No')),
                                        ElevatedButton(
                                            onPressed: () {
                                              Navigator.of(context).pop(true);
                                            },
                                            child: const Text('Cerrar sesión'))
                                      ],
                                    ));
                            if (logout == true) {
                              auth.signOut();
                            }
                          },
                          icon: const Icon(FluentIcons.dismiss_24_regular)),
                      leading: const Icon(FluentIcons.person_24_regular),
                    ),
                    ListTile(
                      leading: const Icon(FluentIcons.approvals_app_24_regular),
                      title: const Text('Sincronizar datos'),
                      onTap: () {
                        var id = auth_.FirebaseAuth.instance.currentUser?.uid;
                        if (id != null) {
                          syncData(id);
                        }
                      },
                    )
                  ]);
                } else {
                  return ListTile(
                    onTap: () async {
                      var user = await auth.googleSignIn();
                      if (user != null) {
                        syncData(user.id);
                      }
                    },
                    title: const Text('Iniciar sesión'),
                    subtitle: const Text('Guarda tus encuentros en la nube'),
                    leading: const Icon(FluentIcons.person_24_regular),
                  );
                }
              }),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GestionScreen(
                            type: 'parejas',
                          )));
            },
            title: const Text('Gestionar parejas'),
            leading: const Icon(FluentIcons.book_contacts_24_regular),
          ),
          ListTile(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const GestionScreen(
                            type: 'lugares',
                          )));
            },
            title: const Text('Gestionar lugares'),
            leading: const Icon(FluentIcons.book_globe_24_regular),
          ),
          ListTile(
            onTap: () async {
              Dialogs.showLoadingDialog(context, progressKey, 'Limpiando...');
              SharedPreferences pref = await SharedPreferences.getInstance();
              await pref.clear();
              context.read<AuthService>().clearEncounters();
              Future.delayed(const Duration(seconds: 2), (){
                Navigator.of(progressKey.currentContext ?? context).pop();
              });
            },
            title: const Text('Limpiar datos locales'),
            subtitle: const Text('Elimina la información de tu dispositivo'),
            leading: const Icon(FluentIcons.broom_24_regular),
          ),
          AboutListTile(
            icon:const Icon(FluentIcons.info_24_regular),
            applicationName: 'Seks',
            applicationVersion: '1.0.0 Afrodita',
            applicationLegalese: 'Seks desarrollada por Malak; (2022)',
            applicationIcon: ImageIcon(const AssetImage('assets/logo_512.png'), size: 72, color: Theme.of(context).colorScheme.primary,),
            aboutBoxChildren: const [Text('Recuerda siempre usar protección y realizarte pruebas periodicamente')],
          )
        ],
      ),
    );
  }
}
