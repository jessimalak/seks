import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seks/widgets/expandableCard.dart';
import '../classes/auth.dart';



class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var encounters = context.watch<AuthService>().encountersList;
    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        itemCount: encounters.length + 1,
        itemBuilder: (c, i) => i < encounters.length
            ? ExpandableCard(
                data: encounters[i],
                index: i,
              )
            : const SizedBox(
                height: 125,
              ));
  }
}
