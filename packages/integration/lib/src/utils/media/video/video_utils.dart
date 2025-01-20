import 'package:flutter/foundation.dart';
import 'package:likeminds_feed_flutter_core/src/utils/media/video/video_metadata.dart';
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

  static Future<LMFeedVideoMetaData?> getVideoMetaData({
    required String? path,
  }) async {
    if (path == null) return null;
    try {
      final info = await VideoCompress.getMediaInfo(
        path,
      );
      // convert duration to seconds
      double? duration = info.duration != null ? info.duration! / 1000 : null;

      return LMFeedVideoMetaData(
        duration: duration,
        width: info.width,
        height: info.height,
        fileSize: info.filesize,
      );
    } on Exception catch (e) {
      debugPrint("Error in getting Video metadata: $e");
      return null;
    }
  }
}
