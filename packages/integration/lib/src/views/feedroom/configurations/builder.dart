import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feedroom_screen_builder_delegate}
/// Builder delegate for Feedroom Screen
/// Used to customise the Feedroom Screen's Widgets
/// {@endtemplate}
class LMFeedroomScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feedroom_screen_builder_delegate}
  const LMFeedroomScreenBuilderDelegate();

  /// AppBar builder for the Feedroom Screen
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
  ) {
    return appBar;
  }
}
