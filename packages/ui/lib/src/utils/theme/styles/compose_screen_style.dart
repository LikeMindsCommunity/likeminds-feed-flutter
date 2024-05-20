import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedComposeScreenStyle {
  final EdgeInsets? mediaPadding;
  final LMFeedComposeMediaStyle? mediaStyle;

  final LMFeedIcon? addImageIcon;
  final LMFeedIcon? addVideoIcon;
  final LMFeedIcon? addDocumentIcon;
  final LMFeedIcon? addPollIcon;

  const LMFeedComposeScreenStyle({
    this.mediaPadding,
    this.mediaStyle,
    this.addImageIcon,
    this.addVideoIcon,
    this.addDocumentIcon,
    this.addPollIcon,
  });

  LMFeedComposeScreenStyle copyWith({
    EdgeInsets? mediaPadding,
    LMFeedComposeMediaStyle? mediaStyle,
    LMFeedIcon? addImageIcon,
    LMFeedIcon? addVideoIcon,
    LMFeedIcon? addDocumentIcon,
    LMFeedIcon? addPollIcon,
  }) {
    return LMFeedComposeScreenStyle(
      mediaPadding: mediaPadding ?? this.mediaPadding,
      mediaStyle: mediaStyle ?? this.mediaStyle,
      addImageIcon: addImageIcon ?? addImageIcon,
      addVideoIcon: addVideoIcon ?? addVideoIcon,
      addDocumentIcon: addDocumentIcon ?? addDocumentIcon,
      addPollIcon: addPollIcon ?? addPollIcon,
    );
  }

  factory LMFeedComposeScreenStyle.basic({Color? primaryColor}) =>
      LMFeedComposeScreenStyle(
        mediaPadding: EdgeInsets.zero,
        mediaStyle: LMFeedComposeMediaStyle.basic(),
        addImageIcon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.photo_outlined,
          style: LMFeedIconStyle(
            color: primaryColor ?? LikeMindsTheme.primaryColor,
            size: 32,
            boxPadding: 0,
            fit: BoxFit.contain,
          ),
        ),
        addVideoIcon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.videocam_outlined,
          style: LMFeedIconStyle(
            color: primaryColor ?? LikeMindsTheme.primaryColor,
            size: 32,
            boxPadding: 0,
            fit: BoxFit.contain,
          ),
        ),
        addDocumentIcon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.file_open_outlined,
          style: LMFeedIconStyle(
            color: primaryColor ?? LikeMindsTheme.primaryColor,
            size: 32,
            boxPadding: 0,
            fit: BoxFit.contain,
          ),
        ),
        addPollIcon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.poll_outlined,
          style: LMFeedIconStyle(
            color: primaryColor ?? LikeMindsTheme.primaryColor,
            size: 32,
            boxPadding: 0,
            fit: BoxFit.contain,
          ),
        ),
      );
}

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
        pollStyle: LMFeedPollStyle.composable(),
      );
}
