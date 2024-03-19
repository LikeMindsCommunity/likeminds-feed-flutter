import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

/// {@template post_header_builder}
/// Builder function to build the post header.
/// i.e. user image, name, time, menu button
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostHeaderBuilder = Widget Function(
    BuildContext, LMFeedPostHeader, LMPostViewData);

/// {@template post_footer_builder}
/// Builder function to build the post footer.
/// i.e. like, comment, share, save buttons
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostFooterBuilder = Widget Function(
    BuildContext, LMFeedPostFooter, LMPostViewData);

/// {@template post_menu_builder}
/// Builder function to build the post widget.
/// i.e. edit, delete, report, pin etc.
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostMenuBuilder = Widget Function(
    BuildContext, LMFeedMenu, LMPostViewData);

/// {@template post_topic_builder}
/// Builder function to build the topic widget.
/// must return a widget, takes in [BuildContext]
/// and [LMTopicViewData] as params
/// {@endtemplate}
typedef LMFeedPostTopicBuilder = Widget Function(
    BuildContext, LMFeedPostTopic, LMPostViewData);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostMediaBuilder = Widget Function(
    BuildContext, LMFeedPostMedia, LMPostViewData);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMFeedPostContentBuilder = Widget Function(
    BuildContext, LMFeedPostContent, LMPostViewData);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
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

/// {@template feed_carousel_indicator_builder}
/// Builder function to build the carousel indicator widget.
/// must return a widget, takes in [int] as params
/// [int] is the current index of the carousel
/// {@endtemplate}
typedef LMFeedCarouselIndicatorBuilder = Widget Function(
    BuildContext, int, int, Widget);

///{@template post_callback}
/// A callback to handle interactions with the post.
/// {@endtemplate}
typedef LMFeedOnPostTap = void Function(BuildContext, LMPostViewData);

///{@template post_appbar_builder}
/// Builder function to build the post appbar.
/// must return a PreferredSizeWidget,
/// takes in [BuildContext] and [LMPostViewData] as params.
/// {@endtemplate}
typedef LMFeedPostAppBarBuilder = PreferredSizeWidget Function(
    BuildContext, LMFeedAppBar);

/// {@template post_comment_builder}
/// Builder function to build the post comment.
/// must return a widget,
/// takes in [BuildContext], [LMUserViewData] and [LMCommentViewData] as params.
/// {@endtemplate}
typedef LMFeedPostCommentBuilder = Widget Function(
    BuildContext, LMFeedCommentWidget, LMPostViewData);

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
