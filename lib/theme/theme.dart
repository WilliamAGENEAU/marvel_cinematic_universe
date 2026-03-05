// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../helpers/static-data.dart';

class AppTheme {
  static final Color primary = DefaultColors.primary;
  static final Color dark = DefaultColors.dark;
  static final Color grey = DefaultColors.grey;

  static void configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: dark,
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
  }

  static ThemeData get darkTheme {
    final baseLabelStyle = TextStyle(
      color: dark,
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );

    return ThemeData(
      useMaterial3: true,
      primaryColor: primary,
      scaffoldBackgroundColor: dark,
      splashColor: dark.withOpacity(0.1),

      textTheme: TextTheme(
        labelSmall: baseLabelStyle,
        labelMedium: baseLabelStyle,
        labelLarge: baseLabelStyle,
        displaySmall: TextStyle(color: dark, fontSize: 12),
        displayMedium: TextStyle(color: dark, fontSize: 14),
        displayLarge: TextStyle(color: dark, fontSize: 16),
        bodySmall: TextStyle(color: grey, fontSize: 12),
        bodyMedium: TextStyle(color: grey, fontSize: 14),
        bodyLarge: TextStyle(color: grey, fontSize: 16),
      ),

      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: const TextStyle(color: Colors.white),
        menuStyle: MenuStyle(backgroundColor: WidgetStateProperty.all(dark)),
      ),
    );
  }
}
