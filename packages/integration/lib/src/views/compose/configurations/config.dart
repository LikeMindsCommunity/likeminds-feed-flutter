import 'package:likeminds_feed_flutter_core/src/views/compose/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/compose/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/compose/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/compose/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/compose/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/compose/configurations/style.dart';

/// {@template lm_feed_compose_screen_config}
/// Configuration class for Compose Screen
/// Holds configuration classes for Compose Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedComposeScreenConfig {
  /// {@macro lm_feed_compose_screen_builder_delegate}
  final LMFeedComposeScreenBuilderDelegate builder;

  /// {@macro lm_feed_compose_screen_setting}
  final LMFeedComposeScreenSetting setting;

  /// {@macro lm_feed_compose_screen_style}
  final LMFeedComposeScreenStyle style;

  /// {@macro lm_feed_compose_screen_config}
  LMFeedComposeScreenConfig({
    this.builder = const LMFeedComposeScreenBuilderDelegate(),
    this.setting = const LMFeedComposeScreenSetting(),
    this.style = const LMFeedComposeScreenStyle(),
  });
}
