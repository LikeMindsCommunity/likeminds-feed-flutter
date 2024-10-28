import 'package:flutter/foundation.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// Enum representing different types of media attachments.
enum LMMediaType {
  none,
  video,
  image,
  document,
  link,
  widget,
  repost,
  poll,
  reel
}

/// {@template lm_attachment_meta_view_data}
/// Class representing the view data for an attachment.
/// {@endtemplate}
class LMAttachmentViewData {
  /// The type of the attachment.
  final LMMediaType attachmentType;

  /// The metadata of the attachment.
  final LMAttachmentMetaViewData attachmentMeta;

  /// Private constructor for `LMAttachmentViewData`.
  LMAttachmentViewData._({
    required this.attachmentType,
    required this.attachmentMeta,
  });

  // Constants representing media type integers.
  static const int imageMediaType = 1;
  static const int videoMediaType = 2;
  static const int documentMediaType = 3;
  static const int linkMediaType = 4;
  static const int widgetMediaType = 5;
  static const int repostMediaType = 8;
  static const int pollMediaType = 6;
  static const int reelMediaType = 11;

  /// Maps the media type to its corresponding integer value.
  int mapMediaTypeToInt() {
    if (attachmentType == LMMediaType.image) {
      return imageMediaType;
    } else if (attachmentType == LMMediaType.video) {
      return videoMediaType;
    } else if (attachmentType == LMMediaType.document) {
      return documentMediaType;
    } else if (attachmentType == LMMediaType.link) {
      return linkMediaType;
    } else if (attachmentType == LMMediaType.widget) {
      return widgetMediaType;
    } else if (attachmentType == LMMediaType.repost) {
      return repostMediaType;
    } else if (attachmentType == LMMediaType.poll) {
      return pollMediaType;
    } else if (attachmentType == LMMediaType.reel) {
      return reelMediaType;
    } else {
      throw 'no valid media type provided';
    }
  }

  /// Factory constructor to create `LMAttachmentViewData` from
  /// attachment metadata.
  factory LMAttachmentViewData.fromAttachmentMeta({
    required LMMediaType attachmentType,
    required LMAttachmentMetaViewData attachmentMeta,
  }) {
    return LMAttachmentViewData._(
      attachmentType: attachmentType,
      attachmentMeta: attachmentMeta,
    );
  }

  /// Factory constructor to create `LMAttachmentViewData` from a media URL.
  factory LMAttachmentViewData.fromMediaUrl({
    required String url,
    required LMMediaType attachmentType,
    String? format,
    int? size,
    int? duration,
    int? pageCount,
    LMOgTagsViewData? ogTags,
    int? height,
    int? width,
    double? aspectRatio,
    LMPostViewData? repost,
    Map<String, dynamic>? meta,
    String? id,
    String? pollQuestion,
    int? expiryTime,
    List<String>? pollOptions,
    PollMultiSelectState? multiSelectState,
    PollType? pollType,
    int? multiSelectNo,
    bool? isAnonymous,
    bool? allowAddOption,
    List<LMPollOptionViewData>? options,
    bool? toShowResult,
    String? pollAnswerText,
  }) {
    return LMAttachmentViewData._(
      attachmentType: attachmentType,
      attachmentMeta: LMAttachmentMetaViewData.fromMediaUrl(
        url: url,
        format: format,
        size: size,
        duration: duration,
        pageCount: pageCount,
        ogTags: ogTags,
        height: height,
        width: width,
        aspectRatio: aspectRatio,
        meta: meta,
        repost: repost,
        id: id,
        pollQuestion: pollQuestion,
        expiryTime: expiryTime,
        pollOptions: pollOptions,
        multiSelectState: multiSelectState,
        pollType: pollType,
        multiSelectNo: multiSelectNo,
        isAnonymous: isAnonymous,
        allowAddOption: allowAddOption,
        options: options,
        toShowResult: toShowResult,
        pollAnswerText: pollAnswerText,
      ),
    );
  }

  /// Factory constructor to create `LMAttachmentViewData` from media bytes.
  factory LMAttachmentViewData.fromMediaBytes({
    Uint8List? bytes,
    required LMMediaType attachmentType,
    String? path,
    String? format,
    int? size,
    int? duration,
    int? pageCount,
    LMOgTagsViewData? ogTags,
    int? height,
    int? width,
    double? aspectRatio,
    LMPostViewData? repost,
    Map<String, dynamic>? meta,
    String? id,
    String? pollQuestion,
    int? expiryTime,
    List<String>? pollOptions,
    PollMultiSelectState? multiSelectState,
    PollType? pollType,
    int? multiSelectNo,
    bool? isAnonymous,
    bool? allowAddOption,
    List<LMPollOptionViewData>? options,
    bool? toShowResult,
    String? pollAnswerText,
    LMPostViewData? post,
    String? postId,
  }) {
    return LMAttachmentViewData._(
      attachmentType: attachmentType,
      attachmentMeta: LMAttachmentMetaViewData.fromMediaBytes(
        bytes: bytes,
        post: post,
        postId: postId,
        path: path,
        format: format,
        size: size,
        duration: duration,
        pageCount: pageCount,
        ogTags: ogTags,
        height: height,
        width: width,
        aspectRatio: aspectRatio,
        meta: meta,
        repost: repost,
        id: id,
        pollQuestion: pollQuestion,
        expiryTime: expiryTime,
        pollOptions: pollOptions,
        multiSelectState: multiSelectState,
        pollType: pollType,
        multiSelectNo: multiSelectNo,
        isAnonymous: isAnonymous,
        allowAddOption: allowAddOption,
        options: options,
        toShowResult: toShowResult,
        pollAnswerText: pollAnswerText,
      ),
    );
  }

  /// Factory constructor to create `LMAttachmentViewData` from a media path.
  factory LMAttachmentViewData.fromMediaPath({
    required String path,
    required LMMediaType attachmentType,
    Uint8List? bytes,
    String? format,
    int? size,
    int? duration,
    int? pageCount,
    LMOgTagsViewData? ogTags,
    int? height,
    int? width,
    double? aspectRatio,
    LMPostViewData? repost,
    Map<String, dynamic>? meta,
    String? id,
    String? pollQuestion,
    int? expiryTime,
    List<String>? pollOptions,
    PollMultiSelectState? multiSelectState,
    PollType? pollType,
    int? multiSelectNo,
    bool? isAnonymous,
    bool? allowAddOption,
    List<LMPollOptionViewData>? options,
    bool? toShowResult,
    String? pollAnswerText,
  }) {
    return LMAttachmentViewData._(
      attachmentType: attachmentType,
      attachmentMeta: LMAttachmentMetaViewData.fromMediaPath(
        path: path,
        bytes: bytes,
        format: format,
        size: size,
        duration: duration,
        pageCount: pageCount,
        ogTags: ogTags,
        height: height,
        width: width,
        aspectRatio: aspectRatio,
        meta: meta,
        repost: repost,
        id: id,
        pollQuestion: pollQuestion,
        expiryTime: expiryTime,
        pollOptions: pollOptions,
        multiSelectState: multiSelectState,
        pollType: pollType,
        multiSelectNo: multiSelectNo,
        isAnonymous: isAnonymous,
        allowAddOption: allowAddOption,
        options: options,
        toShowResult: toShowResult,
        pollAnswerText: pollAnswerText,
      ),
    );
  }

  /// Creates a new builder for `LMAttachmentViewData`.
  static LMAttachmentViewDataBuilder builder() {
    return LMAttachmentViewDataBuilder();
  }
}

/// Builder class for `LMAttachmentViewData`.
class LMAttachmentViewDataBuilder {
  LMMediaType? _attachmentType;
  LMAttachmentMetaViewData? _attachmentMeta;

  /// Sets the attachment type.
  void attachmentType(LMMediaType attachmentType) {
    _attachmentType = attachmentType;
  }

  /// Sets the attachment metadata.
  void attachmentMeta(LMAttachmentMetaViewData attachmentMeta) {
    _attachmentMeta = attachmentMeta;
  }

  /// Builds and returns an `LMAttachmentViewData` instance.
  LMAttachmentViewData build() {
    return LMAttachmentViewData._(
      attachmentType: _attachmentType!,
      attachmentMeta: _attachmentMeta!,
    );
  }
}

/// Maps an integer to its corresponding `LMMediaType`.
LMMediaType mapIntToMediaType(int attachmentType) {
  if (attachmentType == 1) {
    return LMMediaType.image;
  } else if (attachmentType == 2) {
    return LMMediaType.video;
  } else if (attachmentType == 3) {
    return LMMediaType.document;
  } else if (attachmentType == 4) {
    return LMMediaType.link;
  } else if (attachmentType == 5) {
    return LMMediaType.widget;
  } else if (attachmentType == 8 || attachmentType == 9) {
    return LMMediaType.repost;
  } else if (attachmentType == 6) {
    return LMMediaType.poll;
  } else if (attachmentType == 11) {
    return LMMediaType.reel;
  } else {
    return LMMediaType.none;
  }
}
