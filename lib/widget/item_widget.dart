import 'package:attendance/config/item.dart';
import 'package:attendance/style/__init__.dart';
import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

class ItemWidget extends StatefulWidget {
  final Person person;
  final Function onChanged;
  const ItemWidget({super.key, required this.person, required this.onChanged});

  @override
  State<ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<ItemWidget> {
  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      splashRadius: 8,
      value: widget.person.checked,
      onChanged: (value) {
        setState(() {
          widget.person.checked = value!;
          widget.onChanged();
        });
      },
      title: StText.normal(widget.person.name),
      secondary: IconButton(
        iconSize: 16,
        icon: const Icon(Icons.edit),
        onPressed: () async {
          final result = await MyDialog.prompt(
              title: "修改名字",
              builder: (context, controller) {
                controller.text = widget.person.name;
                return TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                );
              });
          if (result != null) {
            setState(() {
              widget.person.name = result;
              widget.onChanged();
            });
          }
        },
      ),
    );
  }
}
