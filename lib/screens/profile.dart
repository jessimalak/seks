import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:seks/widgets/dialogs.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfileScreen extends StatelessWidget {
  GlobalKey progressKey = GlobalKey();

  ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Perfil'),
        ),
        body: Column(children: [
          ListTile(
            onTap: () async {
              bool? delete = await Dialogs.showDeleteDialog(context, '¿Quieres eliminar todo lo que tienes guardado?');
              if (delete) {
                Dialogs.showLoadingDialog(context, progressKey, 'Limpiando...');
                String id = FirebaseAuth.instance.currentUser?.uid ?? '';
                await FirebaseFirestore.instance.collection('users').doc(id).delete();
                SharedPreferences pref = await SharedPreferences.getInstance();
                pref.clear();
                await Future.delayed(const Duration(seconds: 1));
                Navigator.pop(progressKey.currentContext ?? context);
              }
            },
            title: const Text('Eliminar datos en la nube'),
            subtitle: const Text('Limpia todo lo que tienes en la nube'),
          ),
          ListTile(
              onTap: () async {
                bool? delete = await Dialogs.showDeleteDialog(context, '¿Quieres eliminar todo lo que tienes guardado?');
                if (delete) {
                  Dialogs.showLoadingDialog(context, progressKey, 'Eliminando cuenta...');
                  String id = FirebaseAuth.instance.currentUser?.uid ?? '';
                  await FirebaseFirestore.instance.collection('users').doc(id).delete();
                  SharedPreferences pref = await SharedPreferences.getInstance();
                  pref.clear();
                  await FirebaseAuth.instance.currentUser?.delete();
                  await Future.delayed(const Duration(seconds: 1));
                  Navigator.pop(progressKey.currentContext ?? context);
                  Navigator.pop(context);
                }
              },
              title: const Text(
                'Eliminar cuenta',
                style: TextStyle(color: Colors.red),
              )),
        ]),
      );
}
