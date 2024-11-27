import 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/feedroom/configurations/style.dart';

/// {@template lm_feedroom_screen_config}
/// Configuration class for Feedroom Screen
/// Holds configuration classes for Feedroom Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedroomScreenConfig {
  /// {@macro lm_feedroom_screen_builder_delegate}
  final LMFeedroomScreenBuilderDelegate builder;

  /// {@macro lm_feedroom_screen_setting}
  final LMFeedroomScreenSetting setting;

  /// {@macro lm_feedroom_screen_style}
  final LMFeedroomScreenStyle style;

  /// {@macro lm_feedroom_screen_config}
  const LMFeedroomScreenConfig({
    this.builder = const LMFeedroomScreenBuilderDelegate(),
    this.setting = const LMFeedroomScreenSetting(),
    this.style = const LMFeedroomScreenStyle(),
  });
}
