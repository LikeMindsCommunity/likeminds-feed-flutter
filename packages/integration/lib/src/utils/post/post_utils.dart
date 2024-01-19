import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

class LMFeedPostUtils {
  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

// Returns file size in double in MBs
  static double getFileSizeInDouble(int bytes) {
    return (bytes / pow(1024, 2));
  }

  static String? getPostType(int postType) {
    String? postTypeString;
    switch (postType) {
      case 1: // Image
        postTypeString = "image";
        break;
      case 2: // Video
        postTypeString = "video";
        break;
      case 3: // Document
        postTypeString = "document";
        break;
      case 4: // Link
        postTypeString = "link";
        break;
    }
    return postTypeString;
  }

  static Future<Map<String, int>> getImageFileDimensions(File image) async {
    Map<String, int> dimensions = {};
    final decodedImage = await decodeImageFromList(image.readAsBytesSync());
    dimensions.addAll({"width": decodedImage.width});
    dimensions.addAll({"height": decodedImage.height});
    return dimensions;
  }

  static Future<Map<String, int>> getNetworkImageDimensions(
      String image) async {
    Map<String, int> dimensions = {};
    final response = await http.get(Uri.parse(image));
    final bytes = response.bodyBytes;
    final decodedImage = await decodeImageFromList(bytes);
    dimensions.addAll({"width": decodedImage.width});
    dimensions.addAll({"height": decodedImage.height});
    return dimensions;
  }

  static String getLikeCountText(int likes) {
    if (likes == 1) {
      return 'Like';
    } else {
      return 'Likes';
    }
  }

  static String getLikeCountTextWithCount(int likes) {
    if (likes == 1) {
      return '$likes Like';
    } else {
      return '$likes Likes';
    }
  }

  static String getCommentCountText(int comment) {
    if (comment == 1) {
      return 'Comment';
    } else {
      return 'Comments';
    }
  }

  static String getCommentCountTextWithCount(int comment) {
    if (comment == 0) {
      return 'Add Comment';
    } else if (comment == 1) {
      return '1 Comment';
    } else {
      return '$comment Comments';
    }
  }
}
