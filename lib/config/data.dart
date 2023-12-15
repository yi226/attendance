import 'package:attendance/config/item.dart';
import 'package:flutter/foundation.dart';
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
    _current = _prefs.getString('current') ?? '';

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
    _prefs.setString('current', current);
    notifyListeners();
  }

  List<String> _sheets = [];
  List<String> get sheets => _sheets.isEmpty ? ['Example'] : _sheets;
  Sheet? _sheet;
  Sheet getSheet(bool update) {
    if (update) {
      _sheet = _getSheet() ??
          Sheet('Example', [
            Group('Group', [
              Person('Person1'),
              Person('Person2'),
            ]),
          ]);
    }
    return _sheet ??= _getSheet() ??
        Sheet('Example', [
          Group('Group', [
            Person('Person1'),
            Person('Person2'),
          ]),
        ]);
  }

  Sheet? _getSheet() {
    if (_sheets.isEmpty) return null;
    final sheetJson = _prefs.getString(_current);
    if (sheetJson == null) return null;
    return Sheet.fromJson(sheetJson);
  }

  Future<void> addSheet(Sheet sheet) async {
    if (!_sheets.contains(sheet.name)) {
      _sheets.add(sheet.name);
      _sheets.sort();
    }

    await _prefs.setStringList('sheets', _sheets);
    await _prefs.setString(sheet.name, sheet.toJson());
    current = sheet.name;
    notifyListeners();
  }

  Future<void> updateSheet(Sheet sheet) async {
    await _prefs.setString(_current, sheet.toJson());
    if (kDebugMode) {
      print('updateSheet: $_current');
    }
  }

  Future<void> deleteSheet(String name) async {
    _sheets.remove(name);
    await _prefs.setStringList('sheets', _sheets);
    await _prefs.remove(name);
    if (_current == name) {
      current = _sheets.first;
    }
    notifyListeners();
  }

  Future<void> changeSheetName(String oldName, String newName) async {
    _sheets.remove(oldName);
    _sheets.add(newName);
    _sheets.sort();
    await _prefs.setStringList('sheets', _sheets);
    final sheet = Sheet.fromJson(_prefs.getString(oldName)!)!;
    sheet.name = newName;
    await _prefs.setString(newName, sheet.toJson());
    await _prefs.remove(oldName);
    if (_current == oldName) {
      current = newName;
    }
    notifyListeners();
  }
}
