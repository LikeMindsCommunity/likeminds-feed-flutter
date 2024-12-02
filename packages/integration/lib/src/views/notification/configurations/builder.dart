import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_notification_screen_builder_delegate}
/// Builder delegate for Notification Screen
/// Used to customise the Notification Screen's Widgets
/// {@endtemplate}
class LMFeedNotificationScreenBuilderDelegate
    extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_notification_screen_builder_delegate}
  const LMFeedNotificationScreenBuilderDelegate();

  /// AppBar builder for the Notification Screen
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
  ) {
    return appBar;
  }
}
