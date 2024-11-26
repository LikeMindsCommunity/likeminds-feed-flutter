import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';

/// enum to describe which type of feed to render
enum LMFeedType {
  /// render universal feed
  universal,

  /// render personalised feed
  personalised
}

/// {@template lm_feed_config}
/// Configuration class for Likeminds Feed
/// Holds configurations classes for each screen
/// {@endtemplate}
class LMFeedConfig {
  /// {@macro lm_feed_widget_builder_delegate}
  final LMFeedWidgetBuilderDelegate widgetBuilderDelegate;

  /// [globalSystemOverlayStyle] is the system overlay style for the app.
  final SystemUiOverlayStyle? globalSystemOverlayStyle;

  /// {@macro lm_feed_config}
  LMFeedConfig({
    this.widgetBuilderDelegate = const LMFeedWidgetBuilderDelegate(),
    this.globalSystemOverlayStyle,
  });
}
