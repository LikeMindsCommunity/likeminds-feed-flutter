import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_like_screen_builder_delegate}
/// Builder delegate for Like Screen
/// Used to customise the Like Screen's Widgets
/// {@endtemplate}
class LMFeedLikeScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_like_screen_builder_delegate}
  const LMFeedLikeScreenBuilderDelegate();

  /// AppBar builder for the Like Screen
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
  ) {
    return appBar;
  }
}
