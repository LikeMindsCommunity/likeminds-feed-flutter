import 'package:likeminds_feed_flutter_core/src/views/feed/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/configurations/styles.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/feed/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/feed/configurations/styles.dart';

class LMFeedScreenConfig {
  final LMFeedScreenBuilderDelegate builder;
  final LMFeedScreenSetting setting;
  final LMFeedScreenStyle style;

  const LMFeedScreenConfig({
    this.builder = const LMFeedScreenBuilderDelegate(),
    this.setting = const LMFeedScreenSetting(),
    this.style = const LMFeedScreenStyle(),
  });
}
