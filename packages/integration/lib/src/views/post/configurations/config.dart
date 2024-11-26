import 'package:likeminds_feed_flutter_core/src/views/post/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/post/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/post/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/post/configurations/style.dart';

/// {@template lm_feed_post_detail_screen_config}
/// Configuration class for PostDetail Screen
/// Holds configuration classes for PostDetail Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedPostDetailScreenConfig {
  /// {@macro lm_feed_post_detail_screen_builder_delegate}
  final LMFeedPostDetailScreenBuilderDelegate builder;

  /// {@macro lm_feed_post_detail_screen_setting}
  final LMFeedPostDetailScreenSetting setting;

  /// {@macro lm_feed_post_detail_screen_style}
  final LMFeedPostDetailScreenStyle style;

  /// {@macro lm_feed_post_detail_screen_config}
  LMFeedPostDetailScreenConfig({
    this.builder = const LMFeedPostDetailScreenBuilderDelegate(),
    this.setting = const LMFeedPostDetailScreenSetting(),
    this.style = const LMFeedPostDetailScreenStyle(),
  });
}
