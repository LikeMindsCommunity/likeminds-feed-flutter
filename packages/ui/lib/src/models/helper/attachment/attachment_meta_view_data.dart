// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMAttachmentMetaViewData {
  String? url;
  String? path;
  Uint8List? bytes;
  String? format;
  int? size;
  int? duration;
  int? pageCount;
  LMOgTagsViewData? ogTags;
  double? height;
  double? width;
  double? aspectRatio;
  LMPostViewData? repost;
  Map<String, dynamic>? meta;
  String? id;
  String? postId;
  LMPostViewData? post;
  String? pollQuestion;
  int? expiryTime;
  List<String>? pollOptions;
  PollMultiSelectState? multiSelectState;
  PollType? pollType;
  int? multiSelectNo;
  bool? isAnonymous;
  bool? allowAddOption;
  List<LMPollOptionViewData>? options;
  bool? toShowResult;
  String? pollAnswerText;

  LMAttachmentMetaViewData._({
    this.url,
    this.path,
    this.bytes,
    this.format,
    this.size,
    this.duration,
    this.pageCount,
    this.ogTags,
    this.aspectRatio,
    this.width,
    this.height,
    this.repost,
    this.meta,
    this.id,
    this.pollQuestion,
    this.expiryTime,
    this.pollOptions,
    this.multiSelectState,
    this.pollType,
    this.multiSelectNo,
    this.isAnonymous,
    this.allowAddOption,
    this.options,
    this.toShowResult,
    this.pollAnswerText,
    this.post,
    this.postId,
  });

  /// copyWith method
  LMAttachmentMetaViewData copyWith({
    String? url,
    String? path,
    Uint8List? bytes,
    String? format,
    int? size,
    int? duration,
    int? pageCount,
    LMOgTagsViewData? ogTags,
    double? height,
    double? width,
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
    return LMAttachmentMetaViewData._(
      url: url ?? this.url,
      bytes: bytes ?? this.bytes,
      path: path ?? this.path,
      format: format ?? this.format,
      size: size ?? this.size,
      duration: duration ?? this.duration,
      pageCount: pageCount ?? this.pageCount,
      ogTags: ogTags ?? this.ogTags,
      height: height ?? this.height,
      width: width ?? this.width,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      meta: meta ?? this.meta,
      repost: repost ?? this.repost,
      id: id ?? this.id,
      pollQuestion: pollQuestion ?? this.pollQuestion,
      expiryTime: expiryTime ?? this.expiryTime,
      pollOptions: pollOptions ?? this.pollOptions,
      multiSelectState: multiSelectState ?? this.multiSelectState,
      pollType: pollType ?? this.pollType,
      multiSelectNo: multiSelectNo ?? this.multiSelectNo,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      allowAddOption: allowAddOption ?? this.allowAddOption,
      options: options ?? this.options,
      toShowResult: toShowResult ?? this.toShowResult,
      pollAnswerText: pollAnswerText ?? this.pollAnswerText,
      post: post ?? this.post,
      postId: postId ?? this.postId,
    );
  }

  factory LMAttachmentMetaViewData.fromMediaBytes({
    Uint8List? bytes,
    String? path,
    String? format,
    int? size,
    int? duration,
    int? pageCount,
    LMOgTagsViewData? ogTags,
    double? height,
    double? width,
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
    return LMAttachmentMetaViewData._(
      bytes: bytes,
      path: path,
      format: format,
      size: size,
      duration: duration,
      pageCount: pageCount,
      ogTags: ogTags,
      height: height,
      width: width,
      aspectRatio: aspectRatio,
      repost: repost,
      meta: meta,
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
      post: post,
      postId: postId,
    );
  }

  factory LMAttachmentMetaViewData.fromMediaPath({
    required String path,
    Uint8List? bytes,
    String? format,
    int? size,
    int? duration,
    int? pageCount,
    LMOgTagsViewData? ogTags,
    double? height,
    double? width,
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
    return LMAttachmentMetaViewData._(
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
      repost: repost,
      meta: meta,
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
      post: post,
      postId: postId,
    );
  }

  factory LMAttachmentMetaViewData.fromMediaUrl({
    required String url,
    String? format,
    int? size,
    int? duration,
    int? pageCount,
    LMOgTagsViewData? ogTags,
    double? height,
    double? width,
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
    return LMAttachmentMetaViewData._(
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
      post: post,
      postId: postId,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'LMAttachmentMetaViewData(url: $url, format: $format, size: $size, duration: $duration, pageCount: $pageCount, ogTags: $ogTags, height: $height, width: $width, aspectRatio: $aspectRatio, meta: $meta, repost: $repost, pollQuestion: $pollQuestion, expiryTime: $expiryTime, pollOptions: $pollOptions, multiSelectState: $multiSelectState, pollType: $pollType, multiSelectNo: $multiSelectNo, isAnonymous: $isAnonymous, allowAddOption: $allowAddOption, options: $options, toShowResult: $toShowResult)';
  }
}

class LMAttachmentMetaViewDataBuilder {
  String? _url;
  String? _format;
  int? _size;
  int? _duration;
  int? _pageCount;
  LMOgTagsViewData? _ogTags;
  double? _height;
  double? _width;
  double? _aspectRatio;
  Map<String, dynamic>? _meta;
  LMPostViewData? _repost;
  String? _id;
  String? _pollQuestion;
  int? _expiryTime;
  List<String>? _pollOptions;
  PollMultiSelectState? _multiSelectState;
  PollType? _pollType;
  int? _multiSelectNo;
  bool? _isAnonymous;
  bool? _allowAddOption;
  List<LMPollOptionViewData>? _options;
  bool? _toShowResult;
  String? _pollAnswerText;
  String? _postId;
  LMPostViewData? _post;

  void url(String url) {
    _url = url;
  }

  void format(String format) {
    _format = format;
  }

  void size(int size) {
    _size = size;
  }

  void duration(int duration) {
    _duration = duration;
  }

  void pageCount(int pageCount) {
    _pageCount = pageCount;
  }

  void ogTags(LMOgTagsViewData ogTags) {
    _ogTags = ogTags;
  }

  void height(double height) {
    _height = height;
  }

  void width(double width) {
    _width = width;
  }

  void aspectRatio(double aspectRatio) {
    _aspectRatio = aspectRatio;
  }

  void meta(Map<String, dynamic> meta) {
    _meta = meta;
  }

  void repost(LMPostViewData repost) {
    _repost = repost;
  }

  void id(String id) {
    _id = id;
  }

  void pollQuestion(String? pollQuestion) {
    _pollQuestion = pollQuestion;
  }

  void expiryTime(int? expiryTime) {
    _expiryTime = expiryTime;
  }

  void pollOptions(List<String>? pollOptions) {
    _pollOptions = pollOptions;
  }

  void multiSelectState(PollMultiSelectState? multiSelectState) {
    _multiSelectState = multiSelectState;
  }

  void pollType(PollType? pollType) {
    _pollType = pollType;
  }

  void multiSelectNo(int? multiSelectNo) {
    _multiSelectNo = multiSelectNo;
  }

  void isAnonymous(bool? isAnonymous) {
    _isAnonymous = isAnonymous;
  }

  void allowAddOption(bool? allowAddOption) {
    _allowAddOption = allowAddOption;
  }

  void options(List<LMPollOptionViewData>? options) {
    _options = options;
  }

  void toShowResult(bool? toShowResult) {
    _toShowResult = toShowResult;
  }

  void pollAnswerText(String? pollAnswerText) {
    _pollAnswerText = pollAnswerText;
  }

  void postId(String? postId) {
    _postId = postId;
  }

  void post(LMPostViewData? post) {
    _post = post;
  }

  LMAttachmentMetaViewData build() {
    return LMAttachmentMetaViewData._(
      url: _url,
      format: _format,
      size: _size,
      duration: _duration,
      pageCount: _pageCount,
      ogTags: _ogTags,
      height: _height,
      width: _width,
      aspectRatio: _aspectRatio,
      meta: _meta,
      repost: _repost,
      id: _id,
      pollQuestion: _pollQuestion,
      expiryTime: _expiryTime,
      pollOptions: _pollOptions,
      multiSelectState: _multiSelectState,
      pollType: _pollType,
      multiSelectNo: _multiSelectNo,
      isAnonymous: _isAnonymous,
      allowAddOption: _allowAddOption,
      options: _options,
      toShowResult: _toShowResult,
      pollAnswerText: _pollAnswerText,
      postId: _postId,
      post: _post,
    );
  }
}

enum PollMultiSelectState { exactly, atLeast, atMax }

extension PollMultiSelectStateExtension on PollMultiSelectState {
  String get value {
    switch (this) {
      case PollMultiSelectState.exactly:
        return 'exactly';
      case PollMultiSelectState.atLeast:
        return 'at_least';
      case PollMultiSelectState.atMax:
        return 'at_max';
    }
  }

  String get name {
    switch (this) {
      case PollMultiSelectState.exactly:
        return 'exactly';
      case PollMultiSelectState.atLeast:
        return 'at least';
      case PollMultiSelectState.atMax:
        return 'at most';
    }
  }
}

PollMultiSelectState pollMultiSelectStateFromString(String value) {
  switch (value) {
    case 'exactly':
      return PollMultiSelectState.exactly;
    case 'at_least':
      return PollMultiSelectState.atLeast;
    case 'at_max':
      return PollMultiSelectState.atMax;
    default:
      return PollMultiSelectState.exactly;
  }
}

enum PollType { instant, deferred }

extension PollTypeExtension on PollType {
  String get value {
    switch (this) {
      case PollType.instant:
        return 'instant';
      case PollType.deferred:
        return 'deferred';
    }
  }
}

PollType pollTypeFromString(String value) {
  switch (value) {
    case 'instant':
      return PollType.instant;
    case 'deferred':
      return PollType.deferred;
    default:
      return PollType.instant;
  }
}
