import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_report_screen_builder_delegate}
/// Builder delegate for Report Screen
/// Used to customise the Report Screen's Widgets
/// {@endtemplate}
class LMFeedReportScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_report_screen_builder_delegate}
  const LMFeedReportScreenBuilderDelegate();

  /// AppBar builder for the Report Screen
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
  ) {
    return appBar;
  }
}
