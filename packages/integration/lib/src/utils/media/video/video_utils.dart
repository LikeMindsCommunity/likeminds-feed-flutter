import 'package:flutter/foundation.dart';
import 'package:likeminds_feed_flutter_core/src/utils/media/video/video_info.dart';
import 'package:video_compress/video_compress.dart';

class LMFeedVideoUtils {
  /// Get thumbnail of video file
  /// [path] : path of video file
  /// [position] : position of thumbnail in video
  /// [quality] : quality of thumbnail
  /// Returns path of thumbnail file
  static Future<String?> getThumbnailFile({
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

  static Future<LMFeedVideoInfo?> getVideoInfo({
    required String path,
  }) async {
    try {
      final info = await VideoCompress.getMediaInfo(
        path,
      );
      return LMFeedVideoInfo(
        duration: info.duration,
        width: info.width,
        height: info.height,
        fileSize: info.filesize,
      );
    } on Exception catch (e) {
      debugPrint("Error in getting thumbnail: $e");
      return null;
    }
  }
}
