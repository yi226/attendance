import 'package:attendance/widget/window.dart';
import 'package:flutter/material.dart';
import 'package:attendance/style/__init__.dart';

class AppLayout extends StatelessWidget {
  final Widget body;
  const AppLayout({super.key, required this.body});

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width <= 500;

    return Scaffold(
      appBar: WindowBar(
        logo: Image.asset(
          'assets/icons/icon.png',
          width: 20,
        ),
        title: const StText.big('Attendance'),
      ),
      backgroundColor: ColorPlate.lightGray,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          width: double.infinity,
          margin: isMobile ? EdgeInsets.zero : const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).canvasColor,
            borderRadius: BorderRadius.circular(isMobile ? 0 : 12),
          ),
          // padding: EdgeInsets.only(
          //   top: MediaQuery.of(context).padding.top,
          //   bottom: MediaQuery.of(context).padding.bottom,
          // ),
          child: body,
        ),
      ),
    );
  }
}
