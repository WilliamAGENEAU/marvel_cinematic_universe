import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:marvel_cinematic_universe/views/home/home.dart';

import 'helpers/static-data.dart';

void main() {
  runApp(const App());
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle.light.copyWith(
        systemNavigationBarColor: DefaultColors.dark,
        statusBarColor: DefaultColors.dark,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: DefaultColors.primary,
        splashColor: DefaultColors.dark,
        textTheme: TextTheme(
          labelSmall: TextStyle(
            color: DefaultColors.dark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          labelMedium: TextStyle(
            color: DefaultColors.dark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          labelLarge: TextStyle(
            color: DefaultColors.dark,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          displaySmall: TextStyle(color: DefaultColors.dark, fontSize: 12),
          displayMedium: TextStyle(color: DefaultColors.dark, fontSize: 14),
          displayLarge: TextStyle(color: DefaultColors.dark, fontSize: 16),
          bodySmall: TextStyle(color: DefaultColors.grey, fontSize: 12),
          bodyMedium: TextStyle(color: DefaultColors.grey, fontSize: 14),
          bodyLarge: TextStyle(color: DefaultColors.grey, fontSize: 16),
        ),
      ),
      home: const HomeScreen(), // 🚀 démarre directement sur Home
    );
  }
}
