import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

enum PostActions { like, comment, share, save }

enum LMAlignment { left, centre, right }

/// {@template post_header_builder}
/// Builder function to build the post header.
/// i.e. user image, name, time, menu button
/// must return a widget, takes in [BuildContext] and [PostViewData] as params.
/// {@endtemplate}
typedef LMPostHeaderBuilder = Widget Function(
    BuildContext context, PostViewData post);

/// {@template post_footer_builder}
/// Builder function to build the post footer.
/// i.e. like, comment, share, save buttons
/// must return a widget, takes in [BuildContext] and [PostViewData] as params.
/// {@endtemplate}
typedef LMPostFooterBuilder = Widget Function(
    BuildContext context, PostViewData post);

/// {@template post_menu_builder}
/// Builder function to build the post widget.
/// i.e. edit, delete, report, pin etc.
/// must return a widget, takes in [BuildContext] and [PostViewData] as params.
/// {@endtemplate}
typedef LMPostMenuBuilder = Widget Function(
    BuildContext context, PostViewData post);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext] and [PostViewData] as params.
/// {@endtemplate}
typedef LMPostMediaBuilder = Widget Function(
    BuildContext context, PostViewData post);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext] and [PostViewData] as params.
/// {@endtemplate}
typedef LMPostContentBuilder = Widget Function(
    BuildContext context, PostViewData post);

/// {@template post_widget_builder}
/// Builder function to build the post widget.
/// must return a widget, takes in [BuildContext] and [PostViewData] as params.
/// {@endtemplate}
typedef LMPostWidgetBuilder = Widget Function(
    BuildContext context, PostViewData post);

///{@template post_callback}
/// A callback to handle interactions with the post.
/// {@endtemplate}
typedef OnPostTap = void Function(BuildContext context, PostViewData activity);

///{@template post_appbar_builder}
/// Builder function to build the post appbar.
/// must return a PreferredSizeWidget,
/// takes in [BuildContext] and [PostViewData] as params.
/// {@endtemplate}
typedef LMPostAppBarBuilder = PreferredSizeWidget Function(
    BuildContext context, PostViewData post);

/// {@template post_comment_builder}
/// Builder function to build the post comment.
/// must return a widget,
/// takes in [BuildContext] and [CommentViewData] as params.
/// {@endtemplate}
typedef LMPostCommentBuilder = Widget Function(
    BuildContext context, CommentViewData comment);
