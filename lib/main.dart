import 'package:attendance/config/data.dart';
import 'package:attendance/style/__init__.dart';
import 'package:attendance/widget/app_layout.dart';
import 'package:attendance/widget/sheet_widget.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:attendance/platform/platform.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  Data.init().args = Args(path: args.firstOrNull);
  runApp(const App());
  if (IntegratePlatform.isDesktop) {
    doWhenWindowReady(() {
      const initialSize = Size(600, 600);
      appWindow.minSize = const Size(350, 450);
      appWindow.size = initialSize;
      appWindow.show();
    });
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => Data(),
      builder: (context, child) {
        final data = context.watch<Data>();
        return MaterialApp(
          title: 'attendance',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
          ).copyWith(extensions: [const ShirneDialogTheme()]),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            colorSchemeSeed: Colors.blue,
            useMaterial3: true,
          ).copyWith(extensions: [const ShirneDialogTheme()]),
          navigatorKey: MyDialog.navigatorKey,
          localizationsDelegates: const [
            ShirneDialogLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en'),
            Locale('zh', 'CN'),
            Locale('zh'),
          ],
          themeMode: data.mode,
          home: AppLayout(
            body: data.args.isEmpty
                ? const SheetWidget()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StText.medium(data.args.path),
                      const SizedBox(height: 8),
                      FilledButton(
                        onPressed: () async {
                          if (data.args.error != null) {
                            MyDialog.alert(data.args.error);
                          } else if (data.args.content != null) {
                            final content = data.args.content;
                            await data.importSheetsFromFile(content: content);
                          } else {
                            final path = data.args.path;
                            await data.importSheetsFromFile(path: path);
                          }
                          data.args = Args();
                        },
                        child: const Text("从该文件导入"),
                      ),
                    ],
                  ),
          ),
        );
      },
    );
  }
}
