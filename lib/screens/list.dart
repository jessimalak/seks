import 'package:flutter/material.dart';
import 'package:seks/classes/encounter.dart';
import 'package:seks/widgets/expandableCard.dart';
import '../widgets/dialogs.dart';
import 'add.dart';

class ListScreen extends StatefulWidget {
  const ListScreen({Key? key, required this.data, required this.onEdit, required this.onDelete}) : super(key: key);
  final List<Encounter> data;
  final Function(Encounter newEncounter) onEdit;
  final Function(String id) onDelete;

  @override
  State<StatefulWidget> createState() => _ListScreen();
}

class _ListScreen extends State<ListScreen> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        itemCount: widget.data.length + 1,
        itemBuilder: (c, i) => i < widget.data.length
            ? ExpandableCard(
                data: widget.data[i],
                onEdit: () async {
                  Encounter? edited = await Navigator.of(context).push(MaterialPageRoute(
                      builder: (c) => AddScreen(
                            data: widget.data[i],
                          )));
                  if (edited != null) {
                    widget.onEdit(edited);
                  }
                },
                onDelete: () async {
                  bool toDelete =
                      await Dialogs.showDeleteDialog(context, 'Eliminar encuentro de ${formatDate(widget.data[i].date, formatType: dateFormatType.onlyDate)} con ${widget.data[i].partner.name}');
                  if(toDelete){
                    widget.onDelete(widget.data[i].id);
                  }
                },
              )
            : const SizedBox(
                height: 125,
              ));
  }
}
