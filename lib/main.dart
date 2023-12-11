import 'package:attendance/config/data.dart';
import 'package:attendance/pages/check_page.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:integrate_platform/integrate_platform.dart';
import 'package:provider/provider.dart';

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
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
          ),
          themeMode: mode,
          home: const CheckPage(),
        );
      },
    );
  }
}
