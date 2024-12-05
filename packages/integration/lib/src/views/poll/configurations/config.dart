import 'package:likeminds_feed_flutter_core/src/views/poll/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/poll/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/poll/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/poll/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/poll/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/poll/configurations/style.dart';

/// {@template lm_feed_poll_screen_config}
/// Configuration class for Poll Screen
/// Holds configuration classes for Poll Screen
/// i.e: Builder, Setting and Style
/// {@endtemplate}
class LMFeedPollScreenConfig {
  /// {@macro lm_feed_poll_screen_builder_delegate}
  final LMFeedPollScreenBuilderDelegate builder;

  /// {@macro lm_feed_poll_screen_setting}
  final LMFeedPollScreenSetting setting;

  /// {@macro lm_feed_poll_screen_style}
  final LMFeedPollScreenStyle style;

  /// {@macro lm_feed_poll_screen_config}
  const LMFeedPollScreenConfig({
    this.builder = const LMFeedPollScreenBuilderDelegate(),
    this.setting = const LMFeedPollScreenSetting(),
    this.style = const LMFeedPollScreenStyle(),
  });
}
