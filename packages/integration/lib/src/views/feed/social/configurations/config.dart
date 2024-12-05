import 'package:likeminds_feed_flutter_core/src/views/feed/social/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/social/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/social/configurations/styles.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/feed/social/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/social/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/social/configurations/styles.dart';

class LMFeedSocialScreenConfig {
  final LMFeedSocialScreenBuilderDelegate builder;
  final LMFeedSocialScreenSetting setting;
  final LMFeedSocialScreenStyle style;

  const LMFeedSocialScreenConfig({
    this.builder = const LMFeedSocialScreenBuilderDelegate(),
    this.setting = const LMFeedSocialScreenSetting(),
    this.style = const LMFeedSocialScreenStyle(),
  });
}
