import 'package:attendance/config/data.dart';
import 'package:attendance/widget/app_layout.dart';
import 'package:attendance/widget/sheet_widget.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:integrate_platform/integrate_platform.dart';
import 'package:provider/provider.dart';
import 'package:shirne_dialog/shirne_dialog.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const App());
  if (IntegratePlatform.isDesktop) {
    doWhenWindowReady(() {
      const initialSize = Size(600, 600);
      appWindow.minSize = const Size(300, 450);
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
        final mode = context.select<Data, ThemeMode>((value) => value.mode);
        return MaterialApp(
          title: 'attendance',
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.blue,
          ).copyWith(extensions: [const ShirneDialogTheme()]),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
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
          themeMode: mode,
          home: const AppLayout(body: SheetWidget()),
        );
      },
    );
  }
}
