import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/widget_source.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/bottom_textfield.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/comment_count_widget.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/comment_list_widget.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_post_detail_screen_builder_delegate}
/// Builder delegate for PostDetail Screen
/// Used to customise the PostDetail Screen's Widgets
/// {@endtemplate}
class LMFeedPostDetailScreenBuilderDelegate
    extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_post_detail_screen_builder_delegate}
  const LMFeedPostDetailScreenBuilderDelegate();

  /// AppBar builder for the PostDetail Screen
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
  ) {
    return appBar;
  }

  /// Builds a bottom text field for the feed screen.
  /// This is used to add a comment to a post.
  Widget bottomTextFieldBuilder(
    BuildContext context,
    LMFeedBottomTextField textField,
    TextEditingController controller,
    FocusNode focusNode,
    LMFeedWidgetSource source,
  ) {
    return textField;
  }

  /// Comment list builder for the PostDetail Screen
  Widget commentListBuilder(
    BuildContext context,
    LMFeedCommentList commentList,
  ) {
    return commentList;
  }

  Widget commentCountBuilder(
    BuildContext context,
    int commentCount,
    LMFeedCommentCount commentCountWidget,
  ) {
    return commentCountWidget;
  }
}
