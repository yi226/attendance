import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'dart:ui' as ui;

import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart' as provider;
import 'package:attendance/config/version.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
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

class IntegratePlatform {
  /// A string representing the version of the operating system or platform.
  ///
  /// The format of this string will vary by operating system, platform and
  /// version and is not suitable for parsing. For example:
  ///   "Linux 5.11.0-1018-gcp #20~20.04.2-Ubuntu SMP Fri Sep 3 01:01:37 UTC 2021"
  ///   "Version 14.5 (Build 18E182)"
  ///   '"Windows 10 Pro" 10.0 (Build 19043)'
  static String get operatingSystemVersion => Platform.operatingSystemVersion;

  /// Whether the operating system is a version of
  /// [Linux](https://en.wikipedia.org/wiki/Linux).
  ///
  /// This value is `false` if the operating system is a specialized
  /// version of Linux that identifies itself by a different name,
  /// for example Android (see [isAndroid]).
  static bool get isLinux => Platform.isLinux;

  /// Whether the operating system is a version of
  /// [macOS](https://en.wikipedia.org/wiki/MacOS).
  static bool get isMacOS => Platform.isMacOS;

  /// Whether the operating system is a version of
  /// [Microsoft Windows](https://en.wikipedia.org/wiki/Microsoft_Windows).
  static bool get isWindows => Platform.isWindows;

  /// Whether the operating system is a version of
  /// [Android](https://en.wikipedia.org/wiki/Android_%28operating_system%29).
  static bool get isAndroid => Platform.isAndroid;

  /// Whether the operating system is a version of
  /// [iOS](https://en.wikipedia.org/wiki/IOS).
  static bool get isIOS => Platform.isIOS;

  /// Whether the operating system is desktop.
  static bool get isDesktop =>
      Platform.isLinux || Platform.isWindows || Platform.isMacOS;

  /// Whether the operating system is mobile.
  static bool get isMobile => Platform.isAndroid || Platform.isIOS;

  /// Whether the operating system is web.
  static bool get isWeb => false;

  /// The path separator used by the operating system to separate components in file paths.
  static String get pathSeparator => Platform.pathSeparator;

  static Future<String> _getCurrentDirectory() async {
    String path;
    if (isDesktop) {
      path = Directory.current.path;
    } else {
      Directory appDocDir = await provider.getApplicationDocumentsDirectory();
      path = appDocDir.path;
    }
    return path;
  }

  /// Get the current directory path.
  ///
  /// Desktop: [Directory].current.path
  ///
  /// Mobile: Application documents directory
  ///
  /// Web: null
  static Future<String?> getCurrentDirectory() => _getCurrentDirectory();

  /// Get the application documents directory path.
  ///
  /// IO: https://github.com/flutter/plugins/tree/main/packages/path_provider/path_provider
  ///
  /// Web: null
  static Future<String?> getApplicationDocumentsDirectory() async {
    Directory appDocDir = await provider.getApplicationDocumentsDirectory();
    return appDocDir.path;
  }

  /// Get the temporary documents directory path.
  ///
  /// IO: https://github.com/flutter/plugins/tree/main/packages/path_provider/path_provider
  ///
  /// Web: null
  static Future<String?> getTemporaryDirectory() async {
    Directory appDocDir = await provider.getTemporaryDirectory();
    return appDocDir.path;
  }

  /// Write content to a file
  ///
  /// [name] needs to be suffixed, such as "hello.txt"
  ///
  /// If [recursive] is false, the default, the file is created only if all directories in its path already exist. If [recursive] is true, any non-existing parent paths are created first.
  ///
  /// If [autoRename] is false, the default, the file name will not change.If [autoRename] is true, the name will be added number to avoid duplication.
  ///
  /// If [path] is null, the default path is current path [getCurrentDirectory].
  ///
  /// The named parameters will not take effect in Web.Instead, users will get the file by automatic download.
  static Future<FileResult> writeFile(String content, String name,
      {bool recursive = false, bool autoRename = false, String? path}) async {
    assert(name.split('.').length == 2);
    int index = 0;
    String filePath = path ?? (await _getCurrentDirectory());
    String fileType = name.split('.').last;
    String fileName = name.split('.').first;
    String fileWholeName = '$filePath$pathSeparator$fileName.$fileType';
    File file = File(fileWholeName);
    if (autoRename) {
      while (file.existsSync()) {
        index++;
        fileWholeName = '$filePath$pathSeparator$fileName($index).$fileType';
        file = File(fileWholeName);
      }
    }
    try {
      await file.create(recursive: recursive);
      await file.writeAsString(content);
    } catch (e) {
      return FileResult(
          success: false, path: fileWholeName, errorMessage: e.toString());
    }
    return FileResult(success: true, path: fileWholeName);
  }

  /// Pick a single file.
  ///
  /// IO: https://github.com/miguelpruivo/flutter_file_picker
  ///
  /// Web: null
  static Future<String?> pickSingleFile({
    FileType fileType = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: fileType, allowedExtensions: allowedExtensions);

    if (result != null) {
      return result.files.single.path!;
    } else {
      return null;
    }
  }

  /// Read a File
  ///
  /// If [path] is null, the path will be picked by users using [pickSingleFile].
  ///
  /// The [path] will not take effect in Web.
  ///
  /// [contentType] determines the result type to be [String] or [Uint8List].
  ///
  /// Users will get [String] or [Uint8List] in io and [Uint8List] in web.
  static Future<FileResult> readFile({
    String? path,
    ContentType contentType = ContentType.string,
    FileType fileType = FileType.any,
    List<String>? allowedExtensions,
  }) async {
    if (IntegratePlatform.isMobile) {
      final status = await Permission.manageExternalStorage.request();
      if (status.isDenied) {
        return FileResult(success: false, errorMessage: "请授予文件读写权限");
      }
    }
    String? filePath = path ??
        (await pickSingleFile(
            fileType: fileType, allowedExtensions: allowedExtensions));
    if (filePath == null) {
      return FileResult(success: false, errorMessage: "No path.");
    }
    File file = File(filePath);
    if (!file.existsSync()) {
      return FileResult(success: false, errorMessage: "File is not exist.");
    }
    try {
      switch (contentType) {
        case ContentType.string:
          return FileResult(
              success: true,
              content: await file.readAsString(),
              path: filePath);
        case ContentType.byte:
          return FileResult(
              success: true, bytes: await file.readAsBytes(), path: filePath);
      }
    } catch (e) {
      return FileResult(success: false, errorMessage: e.toString());
    }
  }

  /// Get [ui.Image] in 'dart:ui' by the given path.
  ///
  /// If [path] is null, the path will be picked by users using [pickSingleFile].
  ///
  /// The [path] will not take effect in Web.
  static Future<ui.Image?> getImage(String? path) async {
    String? filePath = path ?? (await pickSingleFile(fileType: FileType.image));
    if (filePath == null) {
      return null;
    }
    final list = await File(filePath).readAsBytes();
    ui.Codec codec = await ui.instantiateImageCodec(list);
    ui.FrameInfo frame = await codec.getNextFrame();
    return frame.image;
  }

  static Future<(int, int)> getImageInfo(String path) async {
    final list = await File(path).readAsBytes();
    ui.Codec codec = await ui.instantiateImageCodec(list);
    ui.FrameInfo frame = await codec.getNextFrame();
    final width = frame.image.width;
    final height = frame.image.height;
    codec.dispose();
    return (width, height);
  }
}

enum ContentType {
  string,
  byte,
}

class FileResult {
  /// The result of operation on file.
  FileResult({
    required this.success,
    this.path,
    this.content,
    this.bytes,
    this.errorMessage,
  });

  /// Indicates whether the file operation was successful.
  bool success;

  /// The full path to the final file.
  String? path;

  /// The Content of the file in [String].
  String? content;

  /// The Content of the file in [Uint8List].
  Uint8List? bytes;

  /// Information about the reason for the failure.
  String? errorMessage;

  /// Information about the operation.
  String get message => success ? 'success' : errorMessage ?? 'error';
}
