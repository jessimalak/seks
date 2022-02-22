import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:seks/classes/encounter.dart';
import 'package:seks/screens/add.dart';

class ExpandableCard extends StatelessWidget {
  const ExpandableCard({Key? key, required this.data, required this.onEdit, required this.onDelete}) : super(key: key);
  final Encounter data;
  final Function onEdit;
  final Function onDelete;

  @override
  Widget build(BuildContext context) {
    return ExpandableNotifier(
        child: Card(
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: ExpandablePanel(
            theme: const ExpandableThemeData(hasIcon: false, tapBodyToCollapse: true, tapBodyToExpand: true),
            // header: Text(
            //   formatDate(data[i].date, dateFormatType.textShort)),
            collapsed: Column(
              children: [
                Text(
                  formatDate(
                    data.date,
                    formatType: dateFormatType.textShort,
                    context: context,
                  ),
                  style: Theme.of(context).textTheme.headline2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(children: [const Icon(FluentIcons.person_16_regular, size: 18), Text(data.partner.name)]),
                    Row(children: [const Icon(FluentIcons.location_16_regular, size: 18), Text(data.place)])
                  ],
                )
              ],
            ),
            expanded: Column(
              children: [
                Text(
                  formatDate(
                    data.date,
                    formatType: dateFormatType.textLong,
                    context: context,
                  ),
                  style: Theme.of(context).textTheme.headline2,
                ),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(children: [const Icon(FluentIcons.person_16_regular, size: 18), Text(data.partner.name)]),
                      Text("${data.partner.age} años"),
                      Text(data.partner.gender),
                      Text(data.partner.details)
                    ])),
                    Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Row(children: [const Icon(FluentIcons.location_16_regular, size: 18), Text(data.place)]),
                      Row(
                        children: [
                          const Icon(
                            FluentIcons.lock_closed_16_regular,
                            size: 18,
                          ),
                          Text(data.protection ? 'Seguro' : 'Sin protección'),
                        ],
                      ),
                      Row(children: [
                        const Icon(
                          FluentIcons.clock_16_regular,
                          size: 18,
                        ),
                        Text("${data.duration} horas")
                      ]),
                      Row(children: [
                        const Icon(
                          FluentIcons.star_16_regular,
                          size: 18,
                        ),
                        Text("${data.points}")
                      ])
                    ])
                  ],
                ),
                Wrap(
                  children: data.positions.map((value) => Chip(label: Text(value))).toList(),
                ),
                Text(data.notes),
                Row(
                  children: [
                    IconButton(
                        onPressed: () {
                          onEdit();
                        },
                        icon: const Icon(FluentIcons.edit_24_regular),
                        iconSize: 18,
                        padding: const EdgeInsets.all(1)),
                    IconButton(
                      onPressed: () {
                        onDelete();
                      },
                      icon: const Icon(FluentIcons.delete_24_regular),
                      iconSize: 18,
                      padding: const EdgeInsets.all(1),
                    )
                  ],
                )
              ],
            ),
          )),
    ));
  }
}