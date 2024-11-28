import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/feed/feed_pending_post_banner.dart';

class LMFeedSocialScreenBuilderDelegate {
  const LMFeedSocialScreenBuilderDelegate();

  Widget pendingPostBannerBuilder(BuildContext context, int pendingPostCount,
      LMFeedPendingPostBanner pendingPostBanner) {
    return pendingPostBanner;
  }
}
