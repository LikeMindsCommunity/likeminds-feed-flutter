import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/core/core.dart';

/// {@template lm_feed_activity_screen_builder_delegate}
/// Builder delegate for Activity Screen
/// Used to customize the Activity Screen's Widgets
/// It extends [LMFeedWidgetBuilderDelegate] to provide the default implementations
/// for the Feed Widgets. You must override these methods to customize the widgets specifically for the Activity Screen.
/// otherwise, the default implementations will be used from [LMFeedWidgetBuilderDelegate].
/// {@endtemplate}
class LMFeedActivityScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_activity_screen_builder_delegate}
  const LMFeedActivityScreenBuilderDelegate();

  // feedWidgetBuilder
  static final LMFeedWidgetBuilderDelegate _widgetBuilderDelegate =
      LMFeedWidgetBuilderDelegate();
}
