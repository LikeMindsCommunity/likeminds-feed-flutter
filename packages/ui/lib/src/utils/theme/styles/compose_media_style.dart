import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedComposeMediaStyle {
  final LMFeedPostImageStyle? imageStyle;
  final LMFeedPostVideoStyle? videoStyle;
  final LMFeedPostLinkPreviewStyle? linkStyle;
  final LMFeedPostDocumentStyle? documentStyle;
  final LMFeedPollStyle? pollStyle;

  LMFeedComposeMediaStyle({
    this.imageStyle,
    this.videoStyle,
    this.linkStyle,
    this.documentStyle,
    this.pollStyle,
  });

  LMFeedComposeMediaStyle copyWith({
    LMFeedPostImageStyle? imageStyle,
    LMFeedPostVideoStyle? videoStyle,
    LMFeedPostLinkPreviewStyle? linkStyle,
    LMFeedPostDocumentStyle? documentStyle,
    LMFeedPollStyle? pollStyle,
  }) {
    return LMFeedComposeMediaStyle(
      imageStyle: imageStyle ?? this.imageStyle,
      videoStyle: videoStyle ?? this.videoStyle,
      linkStyle: linkStyle ?? this.linkStyle,
      documentStyle: documentStyle ?? this.documentStyle,
      pollStyle: pollStyle ?? this.pollStyle,
    );
  }

  factory LMFeedComposeMediaStyle.basic() => LMFeedComposeMediaStyle(
        imageStyle: LMFeedPostImageStyle.basic(),
        videoStyle: LMFeedPostVideoStyle.basic(),
        linkStyle: LMFeedPostLinkPreviewStyle.basic(),
        documentStyle: LMFeedPostDocumentStyle.basic(),
        pollStyle: LMFeedPollStyle.basic(isComposable: true),
      );
}
