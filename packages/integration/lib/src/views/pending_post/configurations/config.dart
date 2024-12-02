import 'package:likeminds_feed_flutter_core/src/views/pending_post/configurations/builder.dart';
import 'package:likeminds_feed_flutter_core/src/views/pending_post/configurations/settings.dart';
import 'package:likeminds_feed_flutter_core/src/views/pending_post/configurations/style.dart';

// export all the configurations
export 'package:likeminds_feed_flutter_core/src/views/pending_post/configurations/builder.dart';
export 'package:likeminds_feed_flutter_core/src/views/pending_post/configurations/settings.dart';
export 'package:likeminds_feed_flutter_core/src/views/pending_post/configurations/style.dart';

class LMFeedPendingPostsScreenConfig {
  final LMFeedPendingPostScreenBuilderDelegate builder;
  final LMFeedPendingPostsScreenSetting setting;
  final LMFeedPendingPostsScreenStyle style;

  const LMFeedPendingPostsScreenConfig({
    this.builder = const LMFeedPendingPostScreenBuilderDelegate(),
    this.setting = const LMFeedPendingPostsScreenSetting(),
    this.style = const LMFeedPendingPostsScreenStyle(),
  });
}
