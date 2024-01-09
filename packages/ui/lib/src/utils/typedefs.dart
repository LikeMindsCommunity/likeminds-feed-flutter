import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

/// {@template post_header_builder}
/// Builder function to build the post header.
/// i.e. user image, name, time, menu button
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMPostHeaderBuilder = Widget Function(BuildContext, LMFeedPostHeader);

/// {@template post_footer_builder}
/// Builder function to build the post footer.
/// i.e. like, comment, share, save buttons
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMPostFooterBuilder = LMFeedPostFooter Function(
    BuildContext, LMFeedPostFooter);

/// {@template post_menu_builder}
/// Builder function to build the post widget.
/// i.e. edit, delete, report, pin etc.
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMPostMenuBuilder = Widget Function(BuildContext, LMFeedMenu);

/// {@template post_topic_builder}
/// Builder function to build the topic widget.
/// must return a widget, takes in [BuildContext]
/// and [LMTopicViewData] as params
/// {@endtemplate}
typedef LMPostTopicBuilder = Widget Function(BuildContext, Widget);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMPostMediaBuilder = Widget Function(BuildContext, LMPostMedia);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMPostContentBuilder = Widget Function(BuildContext, LMPostContent);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext] and [LMPostViewData] as params
/// {@endtemplate}
typedef LMPostWidgetBuilder = Widget Function(BuildContext, LMPostWidget);

///{@template post_callback}
/// A callback to handle interactions with the post.
/// {@endtemplate}
typedef LMOnPostTap = void Function(BuildContext, LMPostViewData);

///{@template post_appbar_builder}
/// Builder function to build the post appbar.
/// must return a PreferredSizeWidget,
/// takes in [BuildContext] and [LMPostViewData] as params.
/// {@endtemplate}
typedef LMPostAppBarBuilder = PreferredSizeWidget Function(
    BuildContext, LMAppBar);

/// {@template post_comment_builder}
/// Builder function to build the post comment.
/// must return a widget,
/// takes in [BuildContext], [LMUserViewData] and [LMCommentViewData] as params.
/// {@endtemplate}
typedef LMPostCommentBuilder = Widget Function(BuildContext, LMCommentTile);
