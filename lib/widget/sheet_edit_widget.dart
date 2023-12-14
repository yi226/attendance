import 'package:attendance/config/data.dart';
import 'package:attendance/style/__init__.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

class SheetEditWidget extends StatefulWidget {
  const SheetEditWidget({super.key});

  @override
  State<SheetEditWidget> createState() => _SheetEditWidgetState();
}

class _SheetEditWidgetState extends State<SheetEditWidget> {
  changeSheetName(BuildContext context, Data data, String oldName) async {
    GlobalKey formKey = GlobalKey<FormState>();
    String name = oldName;
    final result = await MyDialog.alertModal(
      Form(
        key: formKey,
        autovalidateMode: AutovalidateMode.always,
        child: Column(
          children: [
            TextFormField(
              initialValue: oldName,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: '表名',
              ),
              validator: (v) {
                String? result;
                if (v!.trim().isEmpty) {
                  result = "表名不能为空";
                } else if (data.sheets.contains(v)) {
                  result = "表名已存在";
                }
                return result;
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
      title: "修改表名",
    );
    if (result == true) {
      data.changeSheetName(oldName, name);
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = context.watch<Data>();
    return ListView.builder(
      shrinkWrap: true,
      itemCount: data.sheets.length,
      itemBuilder: (context, index) {
        final sheetName = data.sheets[index];
        return Dismissible(
          key: ValueKey(sheetName),
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
            data.deleteSheet(sheetName);
            // Then show a snackbar.
            ScaffoldMessenger.of(context)
                .showSnackBar(SnackBar(content: Text('$sheetName dismissed')));
          },
          child: ListTile(
            title: StText.normal(sheetName),
            leading: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  changeSheetName(context, data, sheetName);
                }),
          ),
        );
      },
    );
  }
}
