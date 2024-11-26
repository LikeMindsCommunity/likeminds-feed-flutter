import 'package:likeminds_feed_flutter_core/src/views/likes/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/likes/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/likes/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/likes/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/likes/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/likes/configurations/style.dart';

/// {@template lm_feed_like_screen_config}
/// Configuration class for Like Screen
/// Holds configuration classes for Like Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedLikeScreenConfig {
  /// {@macro lm_feed_like_screen_builder_delegate}
  final LMFeedLikeScreenBuilderDelegate builder;

  /// {@macro lm_feed_like_screen_setting}
  final LMFeedLikeScreenSetting setting;

  /// {@macro lm_feed_like_screen_style}
  final LMFeedLikeScreenStyle style;

  /// {@macro lm_feed_like_screen_config}
  LMFeedLikeScreenConfig({
    this.builder = const LMFeedLikeScreenBuilderDelegate(),
    this.setting = const LMFeedLikeScreenSetting(),
    this.style = const LMFeedLikeScreenStyle(),
  });
}
