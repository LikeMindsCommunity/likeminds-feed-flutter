import 'package:flutter/material.dart';

final ThemeData clientTheme = ThemeData(
  useMaterial3: true,
  primaryColor: Colors.teal,
  colorScheme: ColorScheme.fromSeed(
      seedColor: Colors.teal, background: Colors.white, primary: Colors.teal),
  inputDecorationTheme: InputDecorationTheme(
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
    ),
    outlineBorder: const BorderSide(
      color: Colors.teal,
      width: 2,
    ),
    activeIndicatorBorder: const BorderSide(
      color: Colors.teal,
      width: 2,
    ),
    focusedBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.teal,
        width: 2,
      ),
    ),
    enabledBorder: const OutlineInputBorder(
      borderSide: BorderSide(
        color: Colors.teal,
        width: 2,
      ),
    ),
  ),
);
