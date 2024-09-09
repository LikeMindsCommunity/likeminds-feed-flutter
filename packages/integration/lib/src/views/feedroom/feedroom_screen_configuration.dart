part of 'feedroom_screen.dart';

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
/// Configuration for the [LMFeedUniversalScreen]
/// to support changing light and dark style of overall system
/// elements in accordance to the screen's background
/// to enable/disable features on the fly
/// to enable/disable topic selection
/// to enable/disable multiple topic selection
/// to select the type of topic selection widget
/// to be shown
/// {@endtemplate}
class LMFeedRoomScreenConfig {
  const LMFeedRoomScreenConfig({
    this.composeSystemOverlayStyle = SystemUiOverlayStyle.dark,
    this.enableTopicFiltering = true,
    this.topicSelectionWidgetType =
        LMFeedTopicSelectionWidgetType.showTopicSelectionScreen,
    this.showCustomWidget = false,
  });

  /// The [SystemUiOVerlayStyle] for the [LMFeedComposeScreen]
  /// to support changing light and dark style of overall system
  /// elements in accordance to the screen's background
  final SystemUiOverlayStyle composeSystemOverlayStyle;

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

  LMFeedRoomScreenConfig copyWith({
    SystemUiOverlayStyle? composeSystemOverlayStyle,
    bool? enableTopicFiltering,
    bool? allowMultipleTopicsSelection,
    LMFeedTopicSelectionWidgetType? topicSelectionWidgetType,
    bool? showCustomWidget,
  }) {
    return LMFeedRoomScreenConfig(
      composeSystemOverlayStyle:
          composeSystemOverlayStyle ?? this.composeSystemOverlayStyle,
      enableTopicFiltering: enableTopicFiltering ?? this.enableTopicFiltering,
      topicSelectionWidgetType:
          topicSelectionWidgetType ?? this.topicSelectionWidgetType,
      showCustomWidget: showCustomWidget ?? this.showCustomWidget,
    );
  }
}
