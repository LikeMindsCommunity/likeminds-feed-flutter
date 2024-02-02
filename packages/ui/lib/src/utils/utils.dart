import 'package:http/http.dart' as http;
import 'dart:io';

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

Future<Map<String, int>> getImageFileDimensions(File image) async {
  Map<String, int> dimensions = {};
  final decodedImage = await decodeImageFromList(image.readAsBytesSync());
  dimensions.addAll({"width": decodedImage.width});
  dimensions.addAll({"height": decodedImage.height});
  return dimensions;
}

Future<Map<String, int>> getNetworkImageDimensions(String image) async {
  Map<String, int> dimensions = {};
  final response = await http.get(Uri.parse(image));
  final bytes = response.bodyBytes;
  final decodedImage = await decodeImageFromList(bytes);
  dimensions.addAll({"width": decodedImage.width});
  dimensions.addAll({"height": decodedImage.height});
  return dimensions;
}

String getInitials(String name) => name.isNotEmpty
    ? name.trim().split(' ').map((l) => l[0]).take(2).join()
    : '';
