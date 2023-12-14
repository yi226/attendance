import 'package:attendance/config/item.dart';
import 'package:attendance/style/__init__.dart';
import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

class ItemEditWidget extends StatefulWidget {
  final Person person;
  final Function onDeleted;
  final Function onChanged;
  const ItemEditWidget(
      {super.key,
      required this.person,
      required this.onDeleted,
      required this.onChanged});

  @override
  State<ItemEditWidget> createState() => _ItemEditWidgetState();
}

class _ItemEditWidgetState extends State<ItemEditWidget> {
  @override
  Widget build(BuildContext context) {
    return Dismissible(
        key: ValueKey(widget.person),
        background: Container(
          color: ColorPlate.halfGray,
          child: const Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Icon(
                Icons.delete,
                color: ColorPlate.red,
              ),
            ),
          ),
        ),
        direction: DismissDirection.endToStart,
        onDismissed: (direction) {
          widget.onDeleted(widget.person);
          // Then show a snackbar.
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${widget.person.name} dismissed')));
        },
        child: ListTile(
          title: StText.normal(widget.person.name),
          leading: IconButton(
            iconSize: 16,
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await MyDialog.prompt(
                title: "修改名字",
                defaultValue: widget.person.name,
                barrierDismissible: true,
                buttonText: 'OK',
                cancelText: 'Cancel',
              );
              if (result != null) {
                setState(() {
                  widget.person.name = result;
                  widget.onChanged();
                });
              }
            },
          ),
        ));
  }
}
