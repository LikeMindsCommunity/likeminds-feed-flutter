import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/topic_select_screen.dart';

/// {@template lm_feedroom_screen_setting}
/// Setting configuration for Feedroom Screen
/// {@endtemplate}
class LMFeedroomScreenSetting {
  /// {@macro lm_feedroom_screen_setting}
  const LMFeedroomScreenSetting(
      {this.composeSystemOverlayStyle = SystemUiOverlayStyle.dark,
      this.enableTopicFiltering = true,
      this.topicSelectionWidgetType =
          LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet,
      this.showCustomWidget = false});

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
}
