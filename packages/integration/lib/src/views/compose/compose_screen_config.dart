import 'package:flutter/services.dart';

/// The type of topic selector to be shown
enum LMFeedComposeTopicSelectorType {
  /// The topic selector will be shown as a modal
  popup,

  /// The topic selector will be shown as a bottom sheet
  bottomSheet,
}

/// The type of user display to be shown
enum LMFeedComposeUserDisplayType {
  /// The user display will be shown as a tile
  tile,

  /// The user display will be shown as a profile picture
  profilePicture,

  /// The user display will be shown as none
  none,
}

class LMFeedComposeScreenConfig {
  const LMFeedComposeScreenConfig({
    this.composeSystemOverlayStyle = SystemUiOverlayStyle.dark,
    this.composeHint = "Write something here..",
    this.headingHint = "Add a heading",
    this.enableDocuments = true,
    this.enableImages = true,
    this.enableLinkPreviews = true,
    this.enableTagging = true,
    this.enableTopics = true,
    this.enableVideos = true,
    this.enableHeading = false,
    this.topicRequiredToCreatePost = false,
    this.topicSelectorType = LMFeedComposeTopicSelectorType.popup,
    this.userDisplayType = LMFeedComposeUserDisplayType.profilePicture,
    this.multipleTopicsSelectable = false,
  });

  /// The [SystemUiOVerlayStyle] for the [LMFeedComposeScreen]
  /// to support changing light and dark style of overall system
  /// elements in accordance to the screen's background
  final SystemUiOverlayStyle composeSystemOverlayStyle;

  /// The topic selector type to be shown
  final LMFeedComposeTopicSelectorType topicSelectorType;

  /// The user display type to be shown
  final LMFeedComposeUserDisplayType userDisplayType;

  /// The hint text shown to a user while inputting text for post
  final String composeHint;

  /// The hint text shown to a user while inputting heading for post
  final String headingHint;

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

  /// [bool] to enable/disable heading feature
  /// This feature is used to add a heading to the post
  final bool enableHeading;

  /// [bool] to make topic required for post creation
  final bool topicRequiredToCreatePost;

  /// [bool] to make multiple topics selectable
  final bool multipleTopicsSelectable;

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
    LMFeedComposeTopicSelectorType? topicSelectorType,
    LMFeedComposeUserDisplayType? userDisplayType,
    bool? enableHeading,
    String? headingHint,
    bool? multipleTopicsSelectable,
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
      enableHeading: enableHeading ?? this.enableHeading,
      headingHint: headingHint ?? this.headingHint,
      multipleTopicsSelectable:
          multipleTopicsSelectable ?? this.multipleTopicsSelectable,
      topicSelectorType: topicSelectorType ?? this.topicSelectorType,
      userDisplayType: userDisplayType ?? this.userDisplayType,
    );
  }
}
