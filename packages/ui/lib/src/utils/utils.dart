import 'dart:io';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart';

const String feedUIVersion = "1.3.9";

class LMFeedCustomMessages implements LookupMessages {
  @override
  String prefixAgo() => '';
  @override
  String prefixFromNow() => '';
  @override
  String suffixAgo() => '';
  @override
  String suffixFromNow() => '';
  @override
  String lessThanOneMinute(int seconds) => 'now';
  @override
  String aboutAMinute(int minutes) => '1m';
  @override
  String minutes(int minutes) => '${minutes}m';
  @override
  String aboutAnHour(int minutes) => '1h';
  @override
  String hours(int hours) => '${hours}h';
  @override
  String aDay(int hours) => '1d';
  @override
  String days(int days) => '${days}d';
  @override
  String aboutAMonth(int month) => '1mo';
  @override
  String months(int months) => '${months}mo';
  @override
  String aboutAYear(int months) => '1y';
  @override
  String years(int years) => '${years}y';
  @override
  String wordSeparator() => ' ';
}

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

// Convert DateTime to Time Ago String
extension DateTimeAgo on DateTime {
  String timeAgo() {
    return format(this);
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
