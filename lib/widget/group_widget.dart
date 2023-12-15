import 'package:attendance/config/item.dart';
import 'package:attendance/style/__init__.dart';
import 'package:attendance/widget/item_edit_widget.dart';
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
  bool editType = false;

  addPerson() async {
    GlobalKey formKey = GlobalKey<FormState>();
    String name = "";
    final result = await MyDialog.alertModal(
      Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '人名',
              ),
              validator: (v) {
                return v!.trim().isNotEmpty ? null : "人名不能为空";
              },
              onChanged: (v) {
                name = v;
              },
            ),
          ],
        ),
      ),
      [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if ((formKey.currentState as FormState).validate()) {
              Navigator.of(context).pop(true);
            }
          },
          child: const Text('OK'),
        ),
      ],
      title: "新建人名",
      barrierDismissible: true,
    );
    if (result == true && name.isNotEmpty) {
      setState(() {
        widget.group.persons.add(Person(name));
        notChecked = getNotChecked();
        widget.onChanged();
      });
    }
  }

  int getNotChecked() {
    int count = 0;
    notCheckedPersons.clear();
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
        title: Row(
          children: [
            StText.medium(
                !editType ? widget.group.name : '${widget.group.name} (修改中)'),
            const Spacer(),
            IconButton(
                icon: Icon(!editType ? Icons.edit : Icons.arrow_back),
                iconSize: 20,
                onPressed: () {
                  setState(() {
                    editType = !editType;
                  });
                }),
          ],
        ),
        leading: !editType
            ? Checkbox(
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
              )
            : null,
        trailing: !editType
            ? InkWell(
                onTap: () {
                  MyDialog.popup(
                    SizedBox(
                      width: double.infinity,
                      child: notChecked > 0
                          ? SingleChildScrollView(
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: notCheckedPersons
                                      .map((e) => StText.normal(e))
                                      .toList()
                                    ..insert(0,
                                        const StText.medium('Not checked:'))),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [StText.medium('All checked')],
                            ),
                    ),
                  );
                },
                child: notChecked > 0
                    ? StText.warning('$notChecked remaining')
                    : const Icon(
                        Icons.check,
                        color: ColorPlate.green,
                      ),
              )
            : IconButton(onPressed: addPerson, icon: const Icon(Icons.add)),
        children: [
          if (!editType)
            for (Person person in widget.group.persons)
              ItemWidget(person: person, onChanged: update)
          else
            for (Person person in widget.group.persons)
              ItemEditWidget(
                person: person,
                onChanged: update,
                onDeleted: (p) {
                  setState(() {
                    widget.group.persons.remove(p);
                    notChecked = getNotChecked();
                    widget.onChanged();
                  });
                },
              ),
        ],
      ),
    );
  }
}
