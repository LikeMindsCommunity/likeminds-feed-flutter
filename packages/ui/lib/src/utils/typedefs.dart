import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

/// {@template post_header_builder}
/// Builder function to build the post header.
/// i.e. user image, name, time, menu button
/// must return a widget, takes in [BuildContext], [LMFeedPostHeader],
///  and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostHeaderBuilder = Widget Function(
    BuildContext, LMFeedPostHeader, LMPostViewData);

/// {@template post_footer_builder}
/// Builder function to build the post footer.
/// i.e. like, comment, share, save buttons
/// must return a widget, takes in [BuildContext], [LMFeedPostFooter],
/// and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostFooterBuilder = Widget Function(
    BuildContext, LMFeedPostFooter, LMPostViewData);

/// {@template post_menu_builder}
/// Builder function to build the post widget.
/// i.e. edit, delete, report, pin etc.
/// must return a widget, takes in [BuildContext], [LMFeedMenu],
/// and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostMenuBuilder = Widget Function(
    BuildContext, LMFeedMenu, LMPostViewData);

/// {@template post_topic_builder}
/// Builder function to build the topic widget.
/// must return a widget, takes in [BuildContext], [LMFeedPostTopic],
/// and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostTopicBuilder = Widget Function(
    BuildContext, LMFeedPostTopic, LMPostViewData);

/// {@template post_media_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext], [LMFeedPostMedia],
/// and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostMediaBuilder = Widget Function(
    BuildContext, LMFeedPostMedia, LMPostViewData);

/// {@template post_content_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext], [LMFeedPostContent],
/// and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostContentBuilder = Widget Function(
    BuildContext, LMFeedPostContent, LMPostViewData);

/// {@template post_review_banner_builder}
/// Builder function to build the post widget review banner.
/// must return a widget, takes in [BuildContext], [LMFeedPostReviewBanner],
/// and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostReviewBannerBuilder = Widget Function(
    BuildContext, LMFeedPostReviewBanner, LMPostViewData);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext], [LMFeedPostWidget],
/// and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostWidgetBuilder = Widget Function(
    BuildContext, LMFeedPostWidget, LMPostViewData);

/// {@template feed_image_builder}
/// Builder function to build the image widget.
/// must return a widget, takes in [LMFeedImage] as params
/// {@endtemplate}
typedef LMFeedImageBuilder = Widget Function(LMFeedImage);

/// {@template feed_video_builder}
/// Builder function to build the video widget.
/// must return a widget, takes in [LMFeedVideo] as params
/// {@endtemplate}
typedef LMFeedVideoBuilder = Widget Function(LMFeedVideo);

/// {@template feed_poll_builder}
/// Builder function to build the poll widget.
/// must return a widget, takes in [BuildContext] and [LMFeedPoll] as params
/// {@endtemplate}
typedef LMFeedPollBuilder = Widget Function(BuildContext, LMFeedPoll);

/// {@template feed_carousel_indicator_builder}
/// Builder function to build the carousel indicator widget.
/// must return a widget, takes in [BuildContext], [int], [int],
/// and [Widget] as params
/// [int] is the current index of the carousel
/// {@endtemplate}
typedef LMFeedCarouselIndicatorBuilder = Widget Function(
    BuildContext, int, int, Widget);

/// {@template post_callback}
/// A callback to handle interactions with the post.
/// {@endtemplate}
typedef LMFeedOnPostTap = void Function(BuildContext, LMPostViewData);

/// {@template post_appbar_builder}
/// Builder function to build the post appbar.
/// must return a PreferredSizeWidget,
/// takes in [BuildContext] and [LMFeedAppBar] as params.
/// {@endtemplate}
typedef LMFeedAppBarBuilder = PreferredSizeWidget Function(
    BuildContext, LMFeedAppBar);

/// {@template post_comment_builder}
/// Builder function to build the post comment.
/// must return a widget,
/// takes in [BuildContext], [LMFeedCommentWidget],
/// and [LMPostViewData] as params.
/// {@endtemplate}
typedef LMFeedPostCommentBuilder = Widget Function(
    BuildContext, LMFeedCommentWidget, LMPostViewData);

/// {@template feed_topic_bar_builder}
/// Builder function to build the topic bar widget.
/// must return a widget, takes in [LMFeedTopicBar] as params
/// {@endtemplate}
typedef LMFeedTopicBarBuilder = Widget Function(LMFeedTopicBar topicBar);

/// {@template feed_error_handler}
/// A callback to handle errors in the feed.
/// {@endtemplate}
typedef LMFeedErrorHandler = Function(String, StackTrace);

/// {@template feed_on_tag_tap}
/// A callback to handle tag tap in the feed.
/// {@endtemplate}
typedef LMFeedOnTagTap = void Function(String);

/// {@template feed_button_builder}
/// Builder function to build the button widget.
/// must return a widget, takes in [LMFeedButton] as params
/// {@endtemplate}
typedef LMFeedButtonBuilder = Widget Function(LMFeedButton);

/// {@template feed_room_tile_builder}
/// Builder function to build the room tile widget.
/// must return a widget, takes in [BuildContext], [LMFeedRoomViewData],
/// and [LMFeedTile] as params
/// {@endtemplate}
typedef LMFeedRoomTileBuilder = Widget Function(
  BuildContext context,
  LMFeedRoomViewData viewData,
  LMFeedTile oldWidget,
);

/// {@template lm_feed_text_builder}
/// Builder function to build the text widget.
/// must return a widget, takes in [BuildContext] and [LMFeedText] as params
/// {@endtemplate}
typedef LMFeedTextBuilder = Widget Function(BuildContext, LMFeedText);

/// {@template lm_feed_profile_picture_builder}
/// Builder function to build the profile picture widget.
/// must return a widget, takes in [BuildContext]
/// and [LMFeedProfilePicture] as params
/// {@endtemplate}
typedef LMFeedProfilePictureBuilder = Widget Function(
  BuildContext context,
  LMFeedProfilePicture profilePicture,
);

/// {@template lm_feed_context_builder}
/// Builder function to build the feed context widget.
/// must return a widget, takes in [BuildContext] as params
/// {@endtemplate}
typedef LMFeedContextBuilder = Widget Function(
  BuildContext context,
);

/// {@template lm_feed_loader_builder}
/// Builder function to build the loader widget.
/// must return a widget, takes in [BuildContext] and [LMFeedLoader] as params
/// {@endtemplate}
typedef LMFeedLoaderBuilder = Widget Function(BuildContext context);

/// {@template lm_feed_icon_builder}
/// Builder function to build the icon widget.
/// must return a widget, takes in [LMFeedIcon] as params
/// {@endtemplate}
typedef LMFeedIconBuilder = Widget Function(BuildContext, LMFeedIcon);
