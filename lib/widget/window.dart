import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:attendance/platform/platform.dart';

class WindowBar extends StatelessWidget implements PreferredSizeWidget {
  const WindowBar({super.key, required this.logo, required this.title});

  final Widget logo;
  final Widget title;

  Widget _getDesktopWindowBar(BuildContext context) => PreferredSize(
        preferredSize: preferredSize,
        child: Row(children: [
          WindowTitleBarBox(
            child: MoveWindow(
                child: Padding(
              padding: const EdgeInsets.only(left: 9, right: 9),
              child: logo,
            )),
          ),
          WindowTitleBarBox(
            child: MoveWindow(
              child: Padding(
                padding: const EdgeInsets.only(left: 9, right: 9),
                child: title,
              ),
            ),
          ),
          Expanded(
            child: Column(
              children: [
                WindowTitleBarBox(
                  child: Row(
                    children: [
                      Expanded(child: MoveWindow()),
                      const WindowButtons(),
                    ],
                  ),
                ),
              ],
            ),
          )
        ]),
      );

  Widget _getMobileWindowBar(BuildContext context) {
    if (IntegratePlatform.isMobile) {
      SystemUiOverlayStyle style = SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Theme.of(context).brightness == Brightness.light
            ? Brightness.dark
            : Brightness.light,
        statusBarIconBrightness:
            Theme.of(context).brightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      );
      SystemChrome.setSystemUIOverlayStyle(style);
    }
    return PreferredSize(
        preferredSize: preferredSize,
        child: SafeArea(
          child: Row(children: [
            Padding(
              padding: const EdgeInsets.only(left: 9, right: 9),
              child: logo,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 9, right: 9),
              child: title,
            ),
            Expanded(child: Container()),
          ]),
        ));
  }

  @override
  Size get preferredSize => const Size.fromHeight(40.0);

  @override
  Widget build(BuildContext context) {
    return IntegratePlatform.isDesktop
        ? _getDesktopWindowBar(context)
        : _getMobileWindowBar(context);
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final buttonColors = WindowButtonColors(
        iconNormal: Theme.of(context).iconTheme.color,
        mouseOver: Colors.grey.shade300,
        mouseDown: Colors.grey.shade400,
        iconMouseOver: Colors.black,
        iconMouseDown: Colors.black);

    final closeButtonColors = WindowButtonColors(
      mouseOver: const Color(0xFFD32F2F),
      mouseDown: const Color(0xFFB71C1C),
      iconNormal: Theme.of(context).iconTheme.color,
      iconMouseOver: Colors.white,
    );
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        MaximizeWindowButton(colors: buttonColors),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}
