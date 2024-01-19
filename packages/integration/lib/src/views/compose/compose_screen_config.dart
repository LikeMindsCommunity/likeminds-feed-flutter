import 'package:flutter/services.dart';

class LMFeedComposeScreenConfig {
  const LMFeedComposeScreenConfig({
    this.composeSystemOverlayStyle = SystemUiOverlayStyle.dark,
    this.composeHint = "Write something here..",
    this.enableDocuments = true,
    this.enableImages = true,
    this.enableLinkPreviews = true,
    this.enableTagging = true,
    this.enableTopics = true,
    this.enableVideos = true,
    this.topicRequiredToCreatePost = false,
  });

  /// The [SystemUiOVerlayStyle] for the [LMFeedComposeScreen]
  /// to support changing light and dark style of overall system
  /// elements in accordance to the screen's background
  final SystemUiOverlayStyle composeSystemOverlayStyle;

  /// The hint text shown to a user while inputting text for post
  final String composeHint;

  ///@{template}
  /// Feature booleans to enable/disable features on the fly
  /// [bool] to enable/disable image upload
  final bool enableImages;

  /// [bool] to enable/disable documents upload
  final bool enableDocuments;

  /// [bool] to enable/disable videos upload
  final bool enableVideos;

  /// [bool] to enable/disable tagging feature
  final bool enableTagging;

  /// [bool] to enable/disable topic selection
  final bool enableTopics;

  /// [bool] to enable/disable link previews
  final bool enableLinkPreviews;

  /// [bool] to make topic required for post creation
  final bool topicRequiredToCreatePost;

  LMFeedComposeScreenConfig copyWith({
    SystemUiOverlayStyle? composeSystemOverlayStyle,
    String? composeHint,
    bool? enableDocuments,
    bool? enableImages,
    bool? enableLinkPreviews,
    bool? enableTagging,
    bool? enableTopics,
    bool? enableVideos,
    bool? topicRequiredToCreatePost,
  }) {
    return LMFeedComposeScreenConfig(
      composeSystemOverlayStyle:
          composeSystemOverlayStyle ?? this.composeSystemOverlayStyle,
      composeHint: composeHint ?? this.composeHint,
      enableDocuments: enableDocuments ?? this.enableDocuments,
      enableImages: enableImages ?? this.enableImages,
      enableLinkPreviews: enableLinkPreviews ?? this.enableLinkPreviews,
      enableTagging: enableTagging ?? this.enableTagging,
      enableTopics: enableTopics ?? this.enableTopics,
      enableVideos: enableVideos ?? this.enableVideos,
      topicRequiredToCreatePost:
          topicRequiredToCreatePost ?? this.topicRequiredToCreatePost,
    );
  }
}
