import 'package:flutter/foundation.dart';
import 'package:video_compress/video_compress.dart';

class LMFeedVideoThumbnail {
  /// Get thumbnail of video file
  /// [path] : path of video file
  /// [position] : position of thumbnail in video
  /// [quality] : quality of thumbnail
  /// Returns path of thumbnail file
  static Future<String?> thumbnailFile({
    required String path,
    int position = 0,
    int quality = 40,
  }) async {
    try {
      final thumbnail = await VideoCompress.getFileThumbnail(
        path,
        quality: quality,
        position: position,
      );
      return thumbnail.path;
    } on Exception catch (e) {
      debugPrint("Error in getting thumbnail: $e");
      return null;
    }
  }
}
