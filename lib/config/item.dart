import 'dart:convert';

import 'package:flutter/foundation.dart';

class Person {
  String name;
  bool checked = false;
  bool show = true;

  Map toMap() {
    return {
      'name': name,
      'checked': checked,
    };
  }

  static Person? fromMap(Map map) {
    try {
      final name = map['name'];
      final checked = map['checked'];
      return Person(name, checked: checked);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Person(this.name, {this.checked = false});
}

class Group {
  String name;
  List<Person> persons;
  bool show = true;

  Map toMap() {
    return {
      'name': name,
      'persons': persons.map((e) => e.toMap()).toList(),
    };
  }

  static Group? fromMap(Map map) {
    try {
      final name = map['name'];
      final persons = map['persons'] as List;
      return Group(name, persons.map((e) => Person.fromMap(e)!).toList());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Group(this.name, this.persons);
}

class Sheet {
  String name;
  List<Group> groups;

  Map toMap() {
    return {
      'name': name,
      'groups': groups.map((e) => e.toMap()).toList(),
    };
  }

  static Sheet? fromMap(Map map) {
    try {
      final name = map['name'];
      final groups = map['groups'] as List;
      return Sheet(name, groups.map((e) => Group.fromMap(e)!).toList());
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static Sheet? fromJson(String json) {
    try {
      final map = jsonDecode(json);
      return fromMap(map);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      return null;
    }
  }

  Sheet(this.name, this.groups);
}
