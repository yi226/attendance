import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

int _errorCount = 0;

T? standardTryCatch<T>(Function code) {
  try {
    return code() as T?;
  } catch (e) {
    if (_errorCount > 0) {
      return null;
    }
    _errorCount++;
    _callDialog(e);
    return null;
  }
}

void _callDialog(e) async {
  await MyDialog.alert(
    Text(e.toString()),
  );
  _errorCount = 0;
}
