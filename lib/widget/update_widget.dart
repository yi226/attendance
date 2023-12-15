import 'package:attendance/config/version.dart';
import 'package:attendance/platform/platform.dart';
import 'package:attendance/style/__init__.dart';
import 'package:attendance/widget/window.dart';
import 'package:flutter/material.dart';

class UpdateWidget extends StatelessWidget {
  const UpdateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WindowBar(
          logo: IconButton(
            icon: const Icon(Icons.arrow_back, size: 15),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const StText.big('Update')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AboutDialog(
              applicationName: 'Attendance',
              applicationVersion: version,
              applicationIcon: Image.asset(
                'assets/icons/icon.png',
                width: 50,
              ),
              children: const [
                StText.medium(
                    'Attendance is an application for checking attendance.'),
              ],
            ),
            FutureBuilder(
              future: Version.instance.shouldUpdate(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Container(
                      constraints: BoxConstraints.tight(const Size(40, 40)),
                      child: Center(
                        child: Container(
                            constraints:
                                BoxConstraints.tight(const Size(20, 20)),
                            child: const CircularProgressIndicator()),
                      ));
                }
                return Container(
                  child: snapshot.data == true
                      ? IconButton(
                          icon: const Icon(
                            Icons.new_releases,
                            color: Colors.redAccent,
                          ),
                          onPressed: () => Version.instance.showUpdate(context),
                        )
                      : const StText.medium('You are using the latest version'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
