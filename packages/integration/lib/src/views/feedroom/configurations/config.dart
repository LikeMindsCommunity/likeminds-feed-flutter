import 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/style.dart';

/// {@template lm_feed_feedroom_screen_config}
/// Configuration class for Feedroom Screen
/// Holds configuration classes for Feedroom Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedFeedroomScreenConfig {
  /// {@macro lm_feed_feedroom_screen_builder_delegate}
  final LMFeedFeedroomScreenBuilderDelegate builder;

  /// {@macro lm_feed_feedroom_screen_setting}
  final LMFeedFeedroomScreenSetting setting;

  /// {@macro lm_feed_feedroom_screen_style}
  final LMFeedFeedroomScreenStyle style;

  /// {@macro lm_feed_feedroom_screen_config}
  LMFeedFeedroomScreenConfig({
    this.builder = const LMFeedFeedroomScreenBuilderDelegate(),
    this.setting = const LMFeedFeedroomScreenSetting(),
    this.style = const LMFeedFeedroomScreenStyle(),
  });
}
