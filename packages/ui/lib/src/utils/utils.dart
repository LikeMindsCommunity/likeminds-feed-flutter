import 'package:flutter/material.dart';

const String feedUIVersion = "1.3.9";

extension StringColor on String {
  Color? toColor() {
    // if (primaryColor != null) {
    if (int.tryParse(this) != null) {
      return Color(int.tryParse(this)!);
    } else {
      return Colors.blue;
    }
  }
}

String getInitials(String name) => name.isNotEmpty
    ? name
        .trim()
        .split(' ')
        .where((element) => element.isNotEmpty)
        .map((l) => l[0])
        .take(2)
        .join()
    : '';
