import 'package:attendance/config/data.dart';
import 'package:attendance/style/__init__.dart';
import 'package:flutter/material.dart';

class ShareWidget extends StatefulWidget {
  final Data data;
  const ShareWidget({super.key, required this.data});

  @override
  State<ShareWidget> createState() => _ShareWidgetState();
}

class _ShareWidgetState extends State<ShareWidget> {
  final Map<String, bool> _saveData = {};

  @override
  initState() {
    super.initState();
    for (var sheet in widget.data.sheets) {
      _saveData[sheet] = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final keys = _saveData.keys.toList();
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
              itemCount: keys.length,
              itemBuilder: (context, index) {
                return CheckboxListTile(
                  title: Text(keys[index]),
                  value: _saveData[keys[index]],
                  onChanged: (v) {
                    setState(() {
                      if (v == null) return;
                      _saveData[keys[index]] = v;
                    });
                  },
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
                  child: const Text('Find'),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    widget.data.exportSheetsToFile(
                        _saveData.keys.where((k) => _saveData[k]!).toList());
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
