import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:attendance/config/data.dart';
import 'package:attendance/config/item.dart';
import 'package:attendance/style/text.dart';
import 'package:attendance/widget/group_widget.dart';
import 'package:attendance/widget/search_widget.dart';
import 'package:attendance/widget/share_widget.dart';
import 'package:attendance/widget/sheet_edit_widget.dart';
import 'package:attendance/widget/update_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

class SheetWidget extends StatefulWidget {
  const SheetWidget({super.key});

  @override
  State<SheetWidget> createState() => _SheetWidgetState();
}

class _SheetWidgetState extends State<SheetWidget> {
  bool flag = false;
  bool update = true;

  addSheet(BuildContext context, Data data) async {
    GlobalKey formKey = GlobalKey<FormState>();
    String name = "";
    String nameList = "";
    int count = 0;
    String? lastName;
    await MyDialog.alertModal(
      Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          children: [
            TextFormField(
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '表名',
              ),
              validator: (v) {
                return v!.trim().isNotEmpty ? null : "表名不能为空";
              },
              onChanged: (v) {
                name = v;
              },
            ),
            const SizedBox(height: 8),
            TextFormField(
              maxLines: 10,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '人名',
                hintText: '每行一个人名',
              ),
              validator: (v) {
                return v!.trim().isNotEmpty ? null : "人名不能为空";
              },
              onChanged: (v) {
                nameList = v;
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
              if (data.sheets.contains(name) &&
                  count == 0 &&
                  lastName != name) {
                MyDialog.snack('$name已存在, 若继续将覆盖原表');
                lastName = name;
                count++;
                return;
              }
              final nameListData = nameList.split('\n')
                ..removeWhere((element) => element.isEmpty);
              final sh = Sheet.fromNameList(name, nameListData);
              if (sh == null) {
                return;
              }
              data.addSheet(sh);
              flag = !flag;
              Navigator.of(context).pop();
            }
          },
          child: const Text('OK'),
        ),
      ],
      title: "新建表",
      barrierDismissible: true,
    );
  }

  changeSheet(BuildContext context, Data data, Sheet sheet) {
    String selected = sheet.name;
    MyDialog.alertModal(
      CustomDropdown<String>(
        items: data.sheets,
        initialItem: sheet.name,
        onChanged: (value) {
          selected = value;
        },
      ),
      [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            data.current = selected;
            Navigator.of(context).pop();
          },
          child: const Text('OK'),
        ),
      ],
      title: "切换当前表",
      barrierDismissible: true,
    );
  }

  manageSheets(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('管理表'),
        content: const SizedBox(
          width: 300,
          child: SheetEditWidget(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<Data>();
    final sheet = data.getSheet(update);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            child: Stack(
              children: [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: StText.medium(sheet.name),
                  ),
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed:
                            update ? () => addSheet(context, data) : null,
                      ),
                      IconButton(
                        icon: const Icon(Icons.info_outline),
                        onPressed: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => const UpdateWidget(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.upload),
                        onPressed: () => data.importSheetsFromFile(),
                      ),
                    ],
                  ),
                ),
                Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.download),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (context) {
                                  return AlertDialog(
                                    content: ShareWidget(data: data),
                                  );
                                });
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, size: 20),
                          onPressed:
                              update ? () => manageSheets(context) : null,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_right),
                          onPressed: update
                              ? () => changeSheet(context, data, sheet)
                              : null,
                        ),
                      ],
                    )),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 12, right: 12, bottom: 8),
          child: SearchWidget(
            width: double.infinity,
            onEditingComplete: (v) {
              setState(() {
                update = v.isEmpty;
              });
              sheet.search(v);
            },
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
            child: ListView.builder(
              itemCount: sheet.groups.length,
              itemBuilder: (context, index) {
                final group = sheet.groups[index];
                return GroupWidget(
                    key: ValueKey(sheet.name + group.name + flag.toString()),
                    group: group,
                    onChanged: () async {
                      await data.updateSheet(sheet);
                    });
              },
            ),
          ),
        ),
      ],
    );
  }
}
