part of './pending_posts_screen.dart';

class LMFeedPendingPostScreenBuilderDeletegate {
  const LMFeedPendingPostScreenBuilderDeletegate();

  Future<void> showPostApprovalDialog(BuildContext context,
      LMPostViewData postViewData, LMFeedPendingPostDialog dialog) async {
    await showAdaptiveDialog(
      context: context,
      builder: (childContext) => dialog,
      useRootNavigator: true,
    );
  }

  Future<void> showPostRejectionDialog(BuildContext context,
      LMPostViewData postViewData, LMFeedPendingPostDialog dialog) async {
    await showAdaptiveDialog(
      context: context,
      builder: (childContext) => dialog,
      useRootNavigator: true,
    );
  }
}
