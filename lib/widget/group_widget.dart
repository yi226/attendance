import 'package:attendance/config/item.dart';
import 'package:attendance/style/__init__.dart';
import 'package:attendance/widget/item_widget.dart';
import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

class GroupWidget extends StatefulWidget {
  final Group group;
  final Function onChanged;
  const GroupWidget({super.key, required this.group, required this.onChanged});

  @override
  State<GroupWidget> createState() => _GroupWidgetState();
}

class _GroupWidgetState extends State<GroupWidget> {
  bool groupChecked = false;
  int notChecked = 0;
  List<String> notCheckedPersons = [];

  int getNotChecked() {
    int count = 0;
    for (Person person in widget.group.persons) {
      if (!person.checked) {
        count++;
        notCheckedPersons.add(person.name);
      }
    }
    return count;
  }

  void update() {
    setState(() {
      groupChecked = widget.group.persons.every((element) => element.checked);
      notChecked = getNotChecked();
    });
    widget.onChanged();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      groupChecked = widget.group.persons.every((element) => element.checked);
      notChecked = getNotChecked();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorPlate.lightGray,
      surfaceTintColor: ColorPlate.lightGray,
      child: ExpansionTile(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        clipBehavior: Clip.antiAlias,
        initiallyExpanded: widget.group.show,
        title: StText.medium(widget.group.name),
        leading: Checkbox(
          value: groupChecked,
          onChanged: (value) {
            setState(() {
              groupChecked = value!;
              for (Person person in widget.group.persons) {
                person.checked = value;
              }
              notChecked = getNotChecked();
              widget.onChanged();
            });
          },
        ),
        trailing: InkWell(
          onTap: () {
            MyDialog.popup(
                SizedBox(
                  width: double.infinity,
                  child: notChecked > 0
                      ? Column(
                          mainAxisSize: MainAxisSize.min,
                          children: notCheckedPersons
                              .map((e) => StText.normal(e))
                              .toList()
                            ..insert(0, const StText.medium('Not checked:')))
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [StText.medium('All checked')],
                        ),
                ),
                isScrollControlled: true,
                maxHeight: 300);
          },
          child: notChecked > 0
              ? StText.warning('$notChecked remaining')
              : const Icon(
                  Icons.check,
                  color: ColorPlate.green,
                ),
        ),
        children: [
          for (Person person in widget.group.persons)
            ItemWidget(person: person, onChanged: update)
        ],
      ),
    );
  }
}
