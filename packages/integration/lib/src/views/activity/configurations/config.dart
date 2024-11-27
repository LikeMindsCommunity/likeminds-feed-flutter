import 'package:likeminds_feed_flutter_core/src/views/activity/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/activity/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/activity/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/activity/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/activity/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/activity/configurations/style.dart';

/// {@template lm_feed_activity_screen_config}
/// Configuration class for Activity Screen
/// Holds configuration classes for Activity Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedActivityScreenConfig {
  /// {@macro lm_feed_activity_screen_builder_delegate}
  final LMFeedActivityScreenBuilderDelegate builder;

  /// {@macro lm_feed_activity_screen_setting}
  final LMFeedActivityScreenSetting setting;

  /// {@macro lm_feed_activity_screen_style}
  final LMFeedActivityScreenStyle style;

  /// {@macro lm_feed_activity_screen_config}
 const LMFeedActivityScreenConfig({
    this.builder = const LMFeedActivityScreenBuilderDelegate(),
    this.setting = const LMFeedActivityScreenSetting(),
    this.style = const LMFeedActivityScreenStyle(),
  });
}
