import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seks/widgets/expandableCard.dart';
import '../classes/auth.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class ListScreen extends StatelessWidget {
  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var encounters = context.watch<AuthService>().encountersList;
    return encounters.isNotEmpty
        ? ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            itemCount: encounters.length + 1,
            itemBuilder: (c, i) => i < encounters.length
                ? ExpandableCard(
                    data: encounters[i],
                    index: i,
                  )
                : const SizedBox(
                    height: 125,
                  ))
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                FluentIcons.calendar_cancel_24_regular,
                size: 128,
              ),
              Text(
                'Aún no has hecho maldades 😈',
                style: Theme.of(context).textTheme.headline2,
              )
            ],
          );
  }
}
