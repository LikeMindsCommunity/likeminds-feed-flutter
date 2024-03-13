import 'package:flutter/cupertino.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

abstract class LMFeedWidgets {
  Widget postWidgetBuilder(
      BuildContext context, LMFeedPostWidget post, LMPostViewData postViewData);

  LMFeedPostCommentBuilder? commentBuilder;

  LMFeedPostHeaderBuilder? headerBuilder;

  LMFeedPostMenuBuilder? menuBuilder;

  LMFeedPostTopicBuilder? topicBuilder;

  LMFeedPostContentBuilder? contentBuilder;

  LMFeedPostMediaBuilder? mediaBuilder;

  LMFeedPostFooterBuilder? footerBuilder;

  LMFeedButtonBuilder? postlikeButtonBuilder;

  LMFeedButtonBuilder? postcommentButtonBuilder;

  LMFeedButtonBuilder? postshareButtonBuilder;

  LMFeedImageBuilder? imageBuilder;

  LMFeedVideoBuilder? videoBuilder;

  LMFeedCarouselIndicatorBuilder? carouselIndicatorBuilder;
}
