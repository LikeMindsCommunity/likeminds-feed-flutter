import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/post_approval_dialog.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedPendingPostScreenBuilderDeletegate
    extends LMFeedWidgetBuilderDelegate {
  const LMFeedPendingPostScreenBuilderDeletegate();

  Future<void> showPostApprovalDialog(BuildContext context,
      LMPostViewData postViewData, LMFeedPendingPostDialog dialog) async {
    await showDialog(
      context: context,
      builder: (childContext) => dialog,
      useRootNavigator: true,
    );
  }

  Future<void> showPostRejectionDialog(BuildContext context,
      LMPostViewData postViewData, LMFeedPendingPostDialog dialog) async {
    await showDialog(
      context: context,
      builder: (childContext) => dialog,
      useRootNavigator: true,
    );
  }

  AppBar appBarBuilder(
      BuildContext context, AppBar pendingPostAppBar, int postViewData) {
    return pendingPostAppBar;
  }
}
