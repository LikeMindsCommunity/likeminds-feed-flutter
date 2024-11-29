import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/core.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/feed/feed_pending_post_banner.dart';

class LMFeedQnaScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  const LMFeedQnaScreenBuilderDelegate();

  Widget pendingPostBannerBuilder(BuildContext context, int pendingPostCount,
      LMFeedPendingPostBanner pendingPostBanner) {
    return pendingPostBanner;
  }
}
