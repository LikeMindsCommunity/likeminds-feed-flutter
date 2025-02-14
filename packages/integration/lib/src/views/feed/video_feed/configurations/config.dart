import 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/configurations/styles.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/configurations/styles.dart';

class LMFeedVideoFeedScreenConfig {
  final LMFeedVideoFeedScreenBuilderDelegate builder;
  final LMFeedVideoFeedScreenSetting setting;
  final LMFeedVideoFeedScreenStyle style;

  const LMFeedVideoFeedScreenConfig({
    this.builder = const LMFeedVideoFeedScreenBuilderDelegate(),
    this.setting = const LMFeedVideoFeedScreenSetting(),
    this.style = const LMFeedVideoFeedScreenStyle(),
  });
}
