import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/post_approval_dialog.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_pending_post_screen_builder_delegate}
/// Builder delegate for Pending Post Screen
/// Used to customise the Pending Post Screen's Widgets
/// {@endtemplate}
class LMFeedPendingPostScreenBuilderDelegate
    extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_pending_post_screen_builder_delegate}
  const LMFeedPendingPostScreenBuilderDelegate();

  /// AppBar builder for the Pending Post Screen

  PreferredSizeWidget appBarBuilder(BuildContext context,
      LMFeedAppBar pendingPostAppBar, int pendingPostCount) {
    return pendingPostAppBar;
  }

  /// Show Post Approval Dialog for the Pending Post Screen builder
  Future<void> showPostApprovalDialog(BuildContext context,
      LMPostViewData postViewData, LMFeedPendingPostDialog dialog) async {
    await showDialog(
      context: context,
      builder: (childContext) => dialog,
      useRootNavigator: true,
    );
  }

  /// Show Post Rejection Dialog for the Pending Post Screen builder
  Future<void> showPostRejectionDialog(BuildContext context,
      LMPostViewData postViewData, LMFeedPendingPostDialog dialog) async {
    await showDialog(
      context: context,
      builder: (childContext) => dialog,
      useRootNavigator: true,
    );
  }
}
