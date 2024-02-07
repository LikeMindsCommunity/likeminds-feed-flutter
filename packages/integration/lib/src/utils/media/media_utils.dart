import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

String getFileSizeString({required int bytes, int decimals = 0}) {
  const suffixes = ["b", "kb", "mb", "gb", "tb"];
  var i = (log(bytes) / log(1024)).floor();
  return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
}

// Returns file size in double in MBs
double getFileSizeInDouble(int bytes) {
  return (bytes / pow(1024, 2));
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
