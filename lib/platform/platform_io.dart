import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:attendance/config/version.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:integrate_platform/integrate_platform.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:shirne_dialog/shirne_dialog.dart';

class Version {
  final Dio _dio = Dio(BaseOptions(
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 3),
  ));

  String get now => version;
  String? newer;
  String? info;
  String? url;
  String? name;

  static Version? _instance;
  static Version get instance => _getInstance();
  static Version _getInstance() {
    _instance ??= Version._internal();
    return _instance!;
  }

  Version._internal();

  bool get update => newer != null && newer != now;

  Future<bool> shouldUpdate() async {
    if (newer != null) {
      return now != newer;
    }
    try {
      await Future.delayed(const Duration(seconds: 1));

      var response = await _dio.get(
        "https://github.com/yi226/Config/releases/download/attendance/version.json",
      );

      var data = json.decode(response.data);
      newer = data["version"];
      info = data["info"];
      if (Platform.isAndroid) {
        url = data["android"];
      } else if (Platform.isWindows) {
        url = data["windows"];
      } else if (Platform.isLinux) {
        url = data["linux"];
      }
      if (url != null) {
        name = url!.split('/').last;
      }
      return now != newer;
    } catch (e) {
      MyDialog.alert(e.toString());
    }
    // newer = now;
    return false;
  }

  Future<void> _showError(BuildContext context, {String? info}) async {
    await showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text(info ?? "更新失败"),
              actions: [
                ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text("确定"))
              ],
            ));
  }

  Future<void> _updateProcess(BuildContext context) async {
    if (url == null || name == null) {
      await _showError(context, info: "该系统暂不支持在线更新");
      return;
    }
    var percent = ValueNotifier<double>(0);
    BuildContext contextSaved = context;
    String path = "";
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          contextSaved = context;
          return AlertDialog(
            title: const Text("下载中"),
            content: SizedBox(
              height: 60,
              child: ValueListenableBuilder(
                  valueListenable: percent,
                  builder: (context, value, child) {
                    if (value == 1) {
                      OpenFilex.open(path);
                      percent.dispose();
                      if (IntegratePlatform.isDesktop) {
                        appWindow.close();
                      }
                    }
                    return Column(
                      children: [
                        Text("进度: ${(value * 100).toStringAsFixed(1)}%"),
                        LinearProgressIndicator(value: value),
                      ],
                    );
                  }),
            ),
          );
        });

    String dir = (await IntegratePlatform.getApplicationDocumentsDirectory())!;
    path = dir + Platform.pathSeparator + name!;
    if (kDebugMode) {
      print(path);
    }
    try {
      await _dio.download(url!, path, onReceiveProgress: (count, total) {
        if (total != -1) {
          percent.value = count / total;
        }
      }, options: Options(contentType: "stream"));
    } catch (e) {
      // ignore: use_build_context_synchronously
      Navigator.of(contextSaved).pop();
      // ignore: use_build_context_synchronously
      _showError(contextSaved, info: e.toString());
    }
  }

  Future<void> showUpdate(BuildContext context) async {
    if (newer == null || newer == now) return;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("新版本"),
          content: SizedBox(
            height: 150,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("版本号: $newer"),
                Text("更新内容:\n$info"),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text("取消"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            ElevatedButton(
              child: const Text("更新"),
              onPressed: () {
                Navigator.of(context).pop();
                _updateProcess(context);
              },
            ),
          ],
        );
      },
    );
  }
}
