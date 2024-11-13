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
      )
    );
  }
  // @override
  // Widget postReviewBannerBuilder(BuildContext context,
  //     LMFeedPostReviewBanner postReviewBanner, LMPostViewData postViewData) {
  //   // TODO: implement postReviewBannerBuilder
  //   return Card(
  //     child: Row(
  //       children: [
  //         if (postReviewBanner.reviewStatusIcon != null)
  //           postReviewBanner.reviewStatusIcon!,
  //         const SizedBox(width: 10.0),
  //         if (postReviewBanner.reviewStatusText != null)
  //           postReviewBanner.reviewStatusText!,
  //         const Spacer(),
  //         if (postReviewBanner.infoIcon != null) postReviewBanner.infoIcon!,
  //       ],
  //     ),
  //   );
  // }
}
