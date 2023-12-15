import 'dart:convert';

import 'package:attendance/config/error.dart';

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
    return standardTryCatch<Person>(() {
      final name = map['name'];
      final checked = map['checked'];
      return Person(name, checked: checked);
    });
  }

  @override
  String toString() {
    return 'Person{name: $name, checked: $checked, show: $show}';
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
    return standardTryCatch<Group>(() {
      final name = map['name'];
      final persons = map['persons'] as List;
      return Group(name, persons.map((e) => Person.fromMap(e)!).toList());
    });
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
    return standardTryCatch<Sheet>(() {
      final name = map['name'];
      final groups = map['groups'] as List;
      return Sheet(name, groups.map((e) => Group.fromMap(e)!).toList());
    });
  }

  String toJson() {
    return jsonEncode(toMap());
  }

  static Sheet? fromJson(String json) {
    return standardTryCatch<Sheet>(() {
      final map = jsonDecode(json);
      return fromMap(map);
    });
  }

  static Sheet? fromNameList(String name, List<String> nameList) {
    return standardTryCatch<Sheet>(() {
      return Sheet(
          name, [Group('Group', nameList.map((e) => Person(e)).toList())]);
    });
  }

  void search(String keyword) {
    for (var group in groups) {
      for (var person in group.persons) {
        person.show = true;
        if (!person.name.contains(keyword)) {
          person.show = false;
        }
      }
    }
  }

  Sheet(this.name, this.groups);
}
