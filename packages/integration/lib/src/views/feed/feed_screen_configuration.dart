part of 'feed_screen.dart';

/// {@template topic_selection_widget_type}
/// [LMFeedTopicSelectionWidgetType] to select the type of topic selection widget
/// to be shown
/// [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet] to show a
/// bottom sheet with a list of topics
/// [LMFeedTopicSelectionWidgetType.showTopicSelectionScreen] to show a
/// screen with a list of topics
/// defaults to [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet]
/// if not provided
enum LMFeedTopicSelectionWidgetType {
  showTopicSelectionBottomSheet,
  showTopicSelectionScreen,
}

/// {@template feed_screen_config}
/// Configuration for the [LMFeedScreen]
/// to support changing light and dark style of overall system
/// elements in accordance to the screen's background
/// to enable/disable features on the fly
/// to enable/disable topic selection
/// to enable/disable multiple topic selection
/// to select the type of topic selection widget
/// to be shown
class LMFeedScreenConfig {
  const LMFeedScreenConfig({
    this.composeSystemOverlayStyle = SystemUiOverlayStyle.dark,
    this.enableTopics = true,
    this.allowMultipleTopicsSelection = false,
    this.topicSelectionWidgetType =
        LMFeedTopicSelectionWidgetType.showTopicSelectionScreen,
  });

  /// The [SystemUiOVerlayStyle] for the [LMFeedComposeScreen]
  /// to support changing light and dark style of overall system
  /// elements in accordance to the screen's background
  final SystemUiOverlayStyle composeSystemOverlayStyle;

  /// [bool] to enable/disable topic selection
  final bool enableTopics;

  /// [bool] to enable/disable multiple topic selection
  /// if true, multiple topics can be selected
  /// if false, only one topic can be selected
  /// defaults to false if not provided
  /// only applicable if [enableTopics] is true
  final bool allowMultipleTopicsSelection;

  /// [LMFeedTopicSelectionWidgetType] to select the type of topic selection widget
  /// to be shown
  /// [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet] to show a
  /// bottom sheet with a list of topics
  /// [LMFeedTopicSelectionWidgetType.showTopicSelectionScreen] to show a
  /// screen with a list of topics
  /// defaults to [LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet]
  /// if not provided
  final LMFeedTopicSelectionWidgetType topicSelectionWidgetType;
}
