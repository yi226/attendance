import 'package:attendance/config/item.dart';
import 'package:attendance/style/style.dart';
import 'package:flutter/material.dart';

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
    );
  }
}
