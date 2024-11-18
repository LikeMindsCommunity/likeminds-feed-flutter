import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class ExampleWidgetUtility extends LMFeedWidgetUtility {
  @override
  Widget postWidgetBuilder(
      BuildContext context, LMFeedPostWidget post, LMPostViewData postViewData,
      {LMFeedWidgetSource source = LMFeedWidgetSource.universalFeed}) {
    return post.copyWith(
        style: post.style?.copyWith(
      backgroundColor: Colors.red,
    ));
  }
}
