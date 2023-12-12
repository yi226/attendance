import 'dart:convert';

import 'package:attendance/config/item.dart';

void main() {
  final person = Person('name');
  final group = Group('group', [person]);
  final sheet = Sheet('sheet', [group]);
  final sheetJsonString = sheet.toJson();
  print(sheetJsonString);
  final sheetJsonStringWrong = sheetJsonString.substring(1);
  final sheet2 = Sheet.fromJson(sheetJsonStringWrong);
  print(sheet2);
  final group2 = sheet2?.groups[0];
  print(group2);
  final person2 = group2?.persons[0];
  print(person2);
}
