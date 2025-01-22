/// {@template lm_feed_video_metadata}
/// Video metadata class to store video metadata
/// like width, height, duration and file size
/// {@endtemplate}
class LMFeedVideoMetaData {
  /// Width of video
  int? width;

  /// Height of video
  int? height;

  /// Duration of video
  double? duration;

  /// File size of video
  int? fileSize;

  /// {@macro lm_feed_video_metadata}
  LMFeedVideoMetaData({
    this.width,
    this.height,
    this.duration,
    this.fileSize,
  });
}
