import 'package:likeminds_feed_flutter_core/src/views/select_topic/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/select_topic/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/select_topic/configurations/style.dart';

/// export the [LMFeedTopicSelectScreenConfig] class
/// which is used to configure the [LMFeedTopicSelectScreen]
export 'package:likeminds_feed_flutter_core/src/views/select_topic/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/select_topic/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/select_topic/configurations/style.dart';

/// {@template lm_feed_topic_select_screen_config}
/// Configuration class for Likeminds Feed Topic Select Screen
/// Holds configurations classes for the screen
/// {@endtemplate}
class LMFeedTopicSelectScreenConfig {
  final LMFeedTopicSelectScreenStyle style;
  final LMFeedTopicSelectScreenBuilderDelegate builder;
  final LMFeedTopicSelectScreenSetting setting;

  const LMFeedTopicSelectScreenConfig({
    this.style = const LMFeedTopicSelectScreenStyle(),
    this.builder = const LMFeedTopicSelectScreenBuilderDelegate(),
    this.setting = const LMFeedTopicSelectScreenSetting(),
  });
}
