import 'package:attendance/config/item.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data extends ChangeNotifier {
  // Singleton pattern
  static final Data _data = Data._();
  factory Data() => _data;
  Data._() {
    _init();
  }

  _init() async {
    _prefs = await SharedPreferences.getInstance();
    _mode = ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
    _sheets = _prefs.getStringList('sheets') ?? [];
    notifyListeners();
  }

  late SharedPreferences _prefs;

  ThemeMode _mode = ThemeMode.system;
  ThemeMode get mode => _mode;
  set mode(ThemeMode mode) {
    _mode = mode;
    notifyListeners();
  }

  String _current = '';
  String get current => _current;
  set current(String current) {
    _current = current;
    notifyListeners();
  }

  List _sheets = [];
  List get sheets => _sheets;
  Sheet get sheet =>
      getSheet() ??
      Sheet('Example', [
        Group('Group', [
          Person('Person1'),
          Person('Person2'),
        ]),
      ]);
  Sheet? getSheet() {
    if (_sheets.isEmpty) return null;
    final sheetJson = _prefs.getString(_current);
    if (sheetJson == null) return null;
    return Sheet.fromJson(sheetJson);
  }
}
