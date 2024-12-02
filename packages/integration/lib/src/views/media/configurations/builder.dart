import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_media_preview_screen_builder_delegate}
/// Builder delegate for MediaPreview Screen
/// Used to customise the MediaPreview Screen's Widgets
/// {@endtemplate}
class LMFeedMediaPreviewScreenBuilderDelegate
    extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_media_preview_screen_builder_delegate}
  const LMFeedMediaPreviewScreenBuilderDelegate();

  /// AppBar builder for the MediaPreview Screen
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
  ) {
    return appBar;
  }
}
