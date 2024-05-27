part of './pending_posts_screen.dart';

class LMFeedPendingPostScreenBuilderDeletegate {
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
