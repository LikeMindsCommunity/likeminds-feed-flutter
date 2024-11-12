part of 'social/social_feed_screen.dart';

/// {@template topic_selection_widget_type}
/// [LMFeedTopicSelectionWidgetType] to select the type of topic selection widget
/// to be shown
/// [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet] to show a
/// bottom sheet with a list of topics
/// [LMFeedTopicSelectionWidgetType.showTopicSelectionScreen] to show a
/// screen with a list of topics
/// defaults to [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet]
/// if not provided
/// {@endtemplate}
enum LMFeedTopicSelectionWidgetType {
  showTopicSelectionBottomSheet,
  showTopicSelectionScreen,
}

/// {@template feed_screen_config}
/// Configuration for the [LMFeedSocialUniversalScreen]
/// to support changing light and dark style of overall system
/// elements in accordance to the screen's background
/// to enable/disable features on the fly
/// to enable/disable topic selection
/// to enable/disable multiple topic selection
/// to select the type of topic selection widget
/// to be shown
/// {@endtemplate}
class LMFeedScreenConfig {
  const LMFeedScreenConfig({
    this.feedSystemOverlayStyle = SystemUiOverlayStyle.light,
    this.enableTopicFiltering = true,
    this.topicSelectionWidgetType =
        LMFeedTopicSelectionWidgetType.showTopicSelectionScreen,
    this.showCustomWidget = false,
    this.showPendingPostHeader = true,
    this.showNotificationFeedIcon = true,
  });

  /// The [SystemUiOVerlayStyle] for the [LMFeedComposeScreen]
  /// to support changing light and dark style of overall system
  /// elements in accordance to the screen's background
  final SystemUiOverlayStyle feedSystemOverlayStyle;

  /// [bool] to enable/disable topic selection
  final bool enableTopicFiltering;

  /// [LMFeedTopicSelectionWidgetType] to select the type of topic selection widget
  /// to be shown
  /// [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet] to show a
  /// bottom sheet with a list of topics
  /// [LMFeedTopicSelectionWidgetType.showTopicSelectionScreen] to show a
  /// screen with a list of topics
  /// defaults to [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet]
  /// if not provided
  final LMFeedTopicSelectionWidgetType topicSelectionWidgetType;

  final bool showCustomWidget;

  /// [bool] to enable/disable pending post header
  /// on feed screen
  final bool showPendingPostHeader;

  /// [bool] to enable/disable notification feed icon
  /// on feed screen
  final bool showNotificationFeedIcon;

  LMFeedScreenConfig copyWith({
    SystemUiOverlayStyle? composeSystemOverlayStyle,
    bool? enableTopicFiltering,
    bool? allowMultipleTopicsSelection,
    LMFeedTopicSelectionWidgetType? topicSelectionWidgetType,
    bool? showCustomWidget,
    bool? showPendingPostHeader,
    bool? showNotificationFeedIcon,
  }) {
    return LMFeedScreenConfig(
      feedSystemOverlayStyle:
          composeSystemOverlayStyle ?? this.feedSystemOverlayStyle,
      enableTopicFiltering: enableTopicFiltering ?? this.enableTopicFiltering,
      topicSelectionWidgetType:
          topicSelectionWidgetType ?? this.topicSelectionWidgetType,
      showCustomWidget: showCustomWidget ?? this.showCustomWidget,
      showNotificationFeedIcon:
          showNotificationFeedIcon ?? this.showNotificationFeedIcon,
      showPendingPostHeader:
          showPendingPostHeader ?? this.showPendingPostHeader,
    );
  }
}
