import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:seks/classes/encounter.dart';

class Dialogs {
  static Future<void> showLoadingDialog(BuildContext context, GlobalKey key, String message) async {
    return showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return WillPopScope(
              onWillPop: () async => false,
              child: SimpleDialog(key: key, backgroundColor: Colors.black54, children: <Widget>[
                Center(
                  child: Column(children: [
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      message,
                      style: TextStyle(color: Colors.pink),
                    )
                  ]),
                )
              ]));
        });
  }

  static Future<String?> showPlaceDialog(BuildContext context, {String? place}) async {
    return await showDialog(
        context: context,
        builder: (c) {
          TextEditingController controller = TextEditingController();
          controller.text = place ?? '';
          return AlertDialog(
            title: Text('Agregar lugar'),
            actions: [
              ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(controller.text);
                  },
                  child: Text('Guardar'))
            ],
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(hintText: 'Nombre del lugar'),
            ),
          );
        });
  }

  static Future<Partner?> showPartnerDialog(BuildContext context, {Partner? partner}) async {
    return await showDialog(
        context: context,
        builder: (c) {
          GlobalKey<FormState> formPartnerKey = GlobalKey();
          List<String> genders = ['Hombre', 'Mujer', 'Hombre trans', 'Mujer trans', 'No binarie', 'Trapito', 'Otro'];

          TextEditingController nameController = TextEditingController();
          TextEditingController ageController = TextEditingController();
          TextEditingController detailsController = TextEditingController();
            String gender =  'Otro';
          if(partner != null) {
            gender = partner.gender;
            nameController.text = partner.name;
            ageController.text = partner.age.toString();
            detailsController.text = partner.details;
          }
          return StatefulBuilder(
              builder: (context, setState) => AlertDialog(
                    title: Text('Agregar pareja'),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            if (formPartnerKey.currentState!.validate()) {
                              Partner newPartner = Partner(name: nameController.text, age: int.parse(ageController.text), details: detailsController.text, gender: gender, id: partner?.id ?? '');
                              Navigator.of(context).pop(newPartner);
                            }
                          },
                          child: Text('Guardar'))
                    ],
                    content: Form(
                      key: formPartnerKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextFormField(
                            controller: nameController,
                            textCapitalization: TextCapitalization.words,
                            validator: (val) => val!.isEmpty ? 'Todos tienen un nombre' : null,
                            decoration: const InputDecoration(hintText: 'Nombre', icon: Icon(FluentIcons.person_24_regular)),
                          ),
                          TextFormField(
                            controller: ageController,
                            validator: (String? val) {
                              if (val!.isNotEmpty) {
                                int valInt = int.parse(val);
                                if (valInt < 14) {
                                  return 'Eso no es muy legal de tu parte';
                                } else {
                                  return null;
                                }
                              }
                              return 'No es posible que haya nacido ayer';
                            },
                            decoration: const InputDecoration(hintText: 'Edad', icon: Icon(FluentIcons.calendar_empty_24_regular)),
                            keyboardType: TextInputType.number,
                          ),
                          DropdownButtonFormField( value: gender,
                              validator: (val) => val == null ? 'De alguna forma se debe identificar' : null,
                              decoration: const InputDecoration(icon: Icon(FluentIcons.person_tag_24_regular), hintText: 'Género / Identidad'),
                              items: genders.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                              onChanged: (String? val) {
                                setState(() {
                                  gender = val ?? '';
                                });
                              }),
                          TextFormField(
                            controller: detailsController,
                            decoration: const InputDecoration(hintText: 'Detalles', icon: Icon(FluentIcons.notepad_person_24_regular)),
                          )
                        ],
                      ),
                    ),
                  ));
        });
  }

  static Future<bool> showDeleteDialog(BuildContext context, String message) async {
    return await showDialog(
        context: context,
        builder: (c) => AlertDialog(
              title: Text('¿Estas segur@?'),
              content: Text(message),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: Text('No')),
                ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: Text('Sí'))
              ],
            ));
  }
}
