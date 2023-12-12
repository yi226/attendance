import 'package:attendance/config/data.dart';
import 'package:attendance/style/text.dart';
import 'package:attendance/widget/group_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SheetWidget extends StatelessWidget {
  const SheetWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final data = context.watch<Data>();
    final sheet = data.sheet;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Card(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: StText.medium(sheet.name),
                ),
              ],
            ),
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
                    group: group,
                    onChanged: () {
                      print(group.persons[0].checked);
                    });
              },
            ),
          ),
        ),
      ],
    );
  }
}
