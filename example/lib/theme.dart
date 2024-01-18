import 'package:flutter/material.dart';

final customThemeData = ThemeData(
  useMaterial3: false,
  colorSchemeSeed: Colors.green,
  scaffoldBackgroundColor: Colors.white,
  textTheme: const TextTheme(),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    outlineBorder: const BorderSide(
      color: Colors.deepPurple,
      width: 2,
    ),
    activeIndicatorBorder: const BorderSide(
      color: Colors.deepPurple,
      width: 2,
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.deepPurple,
        width: 2,
      ),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.deepPurple,
        width: 2,
      ),
    ),
  ),
);