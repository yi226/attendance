import 'package:attendance/config/data.dart';
import 'package:attendance/style/__init__.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ShareWidget extends StatefulWidget {
  const ShareWidget({super.key});

  @override
  State<ShareWidget> createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  @override
  Widget build(BuildContext context) {
    final data = context.watch<Data>();
    return SizedBox(
      height: 500,
      width: 300,
      child: Column(
        children: [
          const StText.big("分享"),
          const Divider(),
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: data.sheets.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(data.sheets[index]),
                  value: false,
                  onChanged: (v) {},
                );
              },
            ),
          ),
          const Divider(),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Near'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Share'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
