import 'package:likeminds_feed_flutter_core/src/views/search/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/search/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/search/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/search/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/search/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/search/configurations/style.dart';

/// {@template lm_feed_search_screen_config}
/// Configuration class for Search Screen
/// Holds configuration classes for Search Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedSearchScreenConfig {
  /// {@macro lm_feed_search_screen_builder_delegate}
  final LMFeedSearchScreenBuilderDelegate builder;

  /// {@macro lm_feed_search_screen_setting}
  final LMFeedSearchScreenSetting setting;

  /// {@macro lm_feed_search_screen_style}
  final LMFeedSearchScreenStyle style;

  /// {@macro lm_feed_search_screen_config}
  const LMFeedSearchScreenConfig({
    this.builder = const LMFeedSearchScreenBuilderDelegate(),
    this.setting = const LMFeedSearchScreenSetting(),
    this.style = const LMFeedSearchScreenStyle(),
  });
}
