import 'package:likeminds_feed_flutter_core/src/views/feed/feed_screen_builder_delegate.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/pending_post/pending_posts_screen.dart';

export 'package:likeminds_feed_flutter_core/src/views/feed/feed_screen_builder_delegate.dart';
export 'package:likeminds_feed_flutter_core/src/views/post/pending_post/pending_posts_screen.dart';

class LMFeedBuilderDelegate {
  LMFeedBuilderDelegate({
    this.feedScreenBuilderDelegate = const LMFeedScreenBuilderDelegate(),
    this.pendingPostScreenBuilderDelegate =
        const LMFeedPendingPostScreenBuilderDeletegate(),
  });

  LMFeedScreenBuilderDelegate feedScreenBuilderDelegate;

  LMFeedPendingPostScreenBuilderDeletegate pendingPostScreenBuilderDelegate;
}
