import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_compose_screen_style}
/// Style configuration for Compose Screen
/// {@endtemplate}
class LMFeedComposeScreenStyle {
  /// {@macro lm_feed_compose_screen_style}
  const LMFeedComposeScreenStyle(

      /// [EdgeInsets] for media padding
      {this.mediaPadding,

      /// [LMFeedComposeMediaStyle] for media style
      this.mediaStyle,

      /// [LMFeedIcon] for add image icon
      this.addImageIcon,

      /// [LMFeedIcon] for add video icon
      this.addVideoIcon,

      /// [LMFeedIcon] for add document icon
      this.addDocumentIcon,

      /// [LMFeedIcon] for add poll icon
      this.addPollIcon});

  final EdgeInsets? mediaPadding;
  final LMFeedComposeMediaStyle? mediaStyle;

  final LMFeedIcon? addImageIcon;
  final LMFeedIcon? addVideoIcon;
  final LMFeedIcon? addDocumentIcon;
  final LMFeedIcon? addPollIcon;
}
