// ignore: avoid_web_libraries_in_flutter
import 'dart:html';
import 'dart:async';

import 'package:attendance/config/version.dart';
import 'package:flutter/material.dart';

class WebFile {
  static outFile({required String notes, required String fileName}) {
    var blob = Blob([notes], 'text/plain', 'native');

    AnchorElement(
      href: Url.createObjectUrlFromBlob(blob).toString(),
    )
      ..setAttribute("download", fileName)
      ..click();
  }
}

class Version {
  String get now => version;
  String newer = version;

  static Version? _instance;
  static Version get instance => _getInstance();
  static Version _getInstance() {
    _instance ??= Version._internal();
    return _instance!;
  }

  Version._internal();

  bool get update => false;

  Future<bool> shouldUpdate() async {
    return false;
  }

  Future<void> showUpdate(BuildContext context) async {}
}
