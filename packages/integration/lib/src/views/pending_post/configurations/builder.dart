import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
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

  /// feedWidgetBuilder
  static final LMFeedWidgetBuilderDelegate _widgetBuilderDelegate =
      LMFeedCore.config.widgetBuilderDelegate;

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

  @override
  Widget scaffold({
    Key? key,
    bool extendBody = false,
    bool extendBodyBehindAppBar = false,
    PreferredSizeWidget? appBar,
    Widget? body,
    Widget? floatingActionButton,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    FloatingActionButtonAnimator? floatingActionButtonAnimator,
    List<Widget>? persistentFooterButtons,
    AlignmentDirectional persistentFooterAlignment =
        AlignmentDirectional.centerEnd,
    Widget? drawer,
    DrawerCallback? onDrawerChanged,
    Widget? endDrawer,
    DrawerCallback? onEndDrawerChanged,
    Color? drawerScrimColor,
    Color? backgroundColor,
    Widget? bottomNavigationBar,
    Widget? bottomSheet,
    bool? resizeToAvoidBottomInset,
    bool primary = true,
    DragStartBehavior drawerDragStartBehavior = DragStartBehavior.start,
    double? drawerEdgeDragWidth,
    bool drawerEnableOpenDragGesture = true,
    bool endDrawerEnableOpenDragGesture = true,
    String? restorationId,
    LMFeedWidgetSource source = LMFeedWidgetSource.activityScreen,
    bool canPop = true,
    Function(bool)? onPopInvoked,
  }) {
    return _widgetBuilderDelegate.scaffold(
      key: key,
      extendBody: extendBody,
      extendBodyBehindAppBar: extendBodyBehindAppBar,
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      floatingActionButtonLocation: floatingActionButtonLocation,
      floatingActionButtonAnimator: floatingActionButtonAnimator,
      persistentFooterButtons: persistentFooterButtons,
      persistentFooterAlignment: persistentFooterAlignment,
      drawer: drawer,
      onDrawerChanged: onDrawerChanged,
      endDrawer: endDrawer,
      onEndDrawerChanged: onEndDrawerChanged,
      drawerScrimColor: drawerScrimColor,
      backgroundColor: backgroundColor,
      bottomNavigationBar: bottomNavigationBar,
      bottomSheet: bottomSheet,
      resizeToAvoidBottomInset: resizeToAvoidBottomInset,
      primary: primary,
      drawerDragStartBehavior: drawerDragStartBehavior,
      drawerEdgeDragWidth: drawerEdgeDragWidth,
      drawerEnableOpenDragGesture: drawerEnableOpenDragGesture,
      endDrawerEnableOpenDragGesture: endDrawerEnableOpenDragGesture,
      restorationId: restorationId,
      source: source,
      canPop: canPop,
      onPopInvoked: onPopInvoked,
    );
  }

  /// Builds a post widget with customized builders.
  @override
  Widget postWidgetBuilder(
      BuildContext context, LMFeedPostWidget post, LMPostViewData postViewData,
      {LMFeedWidgetSource source = LMFeedWidgetSource.universalFeed}) {
    final postWidget = post.copyWith(
      headerBuilder: this.postHeaderBuilder,
      contentBuilder: this.postContentBuilder,
      mediaBuilder: this.postMediaBuilder,
      footerBuilder: this.postFooterBuilder,
      menuBuilder: this.postMenuBuilder,
      topicBuilder: this.topicBuilder,
      reviewBannerBuilder: this.postReviewBannerBuilder,
    );

    return _widgetBuilderDelegate.postWidgetBuilder(
        context, postWidget, postViewData);
  }

  /// Builds a post review banner widget.
  @override
  Widget postReviewBannerBuilder(BuildContext context,
      LMFeedPostReviewBanner postReviewBanner, LMPostViewData postViewData) {
    return _widgetBuilderDelegate.postReviewBannerBuilder(
        context, postReviewBanner, postViewData);
  }

  /// Builds a comment widget.
  @override
  Widget commentBuilder(BuildContext context, LMFeedCommentWidget commentWidget,
      LMPostViewData postViewData) {
    return _widgetBuilderDelegate.commentBuilder(
        context, commentWidget, postViewData);
  }

  /// Builds a post header widget.
  @override
  Widget postHeaderBuilder(BuildContext context, LMFeedPostHeader postHeader,
      LMPostViewData postViewData) {
    return _widgetBuilderDelegate.postHeaderBuilder(
        context, postHeader, postViewData);
  }

  /// Builds a menu widget.
  @override
  Widget postMenuBuilder(
      BuildContext context, LMFeedMenu menu, LMPostViewData postViewData) {
    return _widgetBuilderDelegate.postMenuBuilder(context, menu, postViewData);
  }

  /// Builds a topic widget.
  @override
  Widget topicBuilder(BuildContext context, LMFeedPostTopic postTopic,
      LMPostViewData postViewData) {
    return _widgetBuilderDelegate.topicBuilder(
        context, postTopic, postViewData);
  }

  /// Builds a post content widget.
  @override
  Widget postContentBuilder(BuildContext context, LMFeedPostContent postContent,
      LMPostViewData postViewData) {
    return _widgetBuilderDelegate.postContentBuilder(
        context, postContent, postViewData);
  }

  /// Builds a post media widget.
  @override
  Widget postMediaBuilder(BuildContext context, LMFeedPostMedia postMedia,
      LMPostViewData postViewData) {
    return _widgetBuilderDelegate.postMediaBuilder(
        context,
        postMedia.copyWith(
          carouselIndicatorBuilder: this.postMediaCarouselIndicatorBuilder,
        ),
        postViewData);
  }

  /// Builds a post footer widget.
  @override
  Widget postFooterBuilder(BuildContext context, LMFeedPostFooter postFooter,
      LMPostViewData postViewData) {
    return _widgetBuilderDelegate.postFooterBuilder(
        context, postFooter, postViewData);
  }

  /// Builds an image widget.
  @override
  Widget imageBuilder(LMFeedImage image) {
    return _widgetBuilderDelegate.imageBuilder(image);
  }

  /// Builds a video widget.
  @override
  Widget videoBuilder(LMFeedVideo video) {
    return _widgetBuilderDelegate.videoBuilder(video);
  }

  /// Builds a poll widget.
  @override
  Widget pollWidgetBuilder(BuildContext context, LMFeedPoll pollWidget) {
    return _widgetBuilderDelegate.pollWidgetBuilder(context, pollWidget);
  }

  /// Builds a carousel indicator widget for post media.
  @override
  Widget postMediaCarouselIndicatorBuilder(BuildContext context, int currIndex,
      int mediaLength, Widget carouselIndicator) {
    return _widgetBuilderDelegate.postMediaCarouselIndicatorBuilder(
        context, currIndex, mediaLength, carouselIndicator);
  }

  /// Builds an indicator when no items are found in the feed.
  @override
  Widget noItemsFoundIndicatorBuilder(BuildContext context,
      {LMFeedButton? createPostButton, bool isSelfPost = true, Widget? child}) {
    return _widgetBuilderDelegate.noItemsFoundIndicatorBuilder(
      context,
      createPostButton: createPostButton,
      isSelfPost: isSelfPost,
      child: child,
    );
  }

  /// Builds a progress indicator for the first page of the feed.
  @override
  Widget firstPageProgressIndicatorBuilder(BuildContext context,
      {Widget? child}) {
    return _widgetBuilderDelegate.firstPageProgressIndicatorBuilder(
      context,
      child: child,
    );
  }

  /// Builds a progress indicator for subsequent pages of the feed.
  @override
  Widget newPageProgressIndicatorBuilder(BuildContext context,
      {Widget? child}) {
    return _widgetBuilderDelegate.newPageProgressIndicatorBuilder(
      context,
      child: child,
    );
  }

  /// Builds an error indicator for the first page of the feed.
  @override
  Widget firstPageErrorIndicatorBuilder(BuildContext context, {Widget? child}) {
    return _widgetBuilderDelegate.firstPageErrorIndicatorBuilder(
      context,
      child: child,
    );
  }

  /// Builds an error indicator for subsequent pages of the feed.
  @override
  Widget newPageErrorIndicatorBuilder(BuildContext context, {Widget? child}) {
    return _widgetBuilderDelegate.newPageErrorIndicatorBuilder(
      context,
      child: child,
    );
  }

  /// Builds an indicator when there are no more items to load in the feed.
  @override
  Widget noMoreItemsIndicatorBuilder(BuildContext context, {Widget? child}) {
    return _widgetBuilderDelegate.noMoreItemsIndicatorBuilder(
      context,
      child: child,
    );
  }

  /// Builds a topic bar widget.
  @override
  Widget topicBarBuilder(LMFeedTopicBar topicBar) {
    return _widgetBuilderDelegate.topicBarBuilder(topicBar);
  }

  /// Builds a top response widget for the feed screen.
  /// This is used to show the top response to a post below the post content.
  @override
  Widget topResponseBuilder(
    BuildContext context,
    LMFeedTopResponseWidget topResponseWidget,
    LMCommentViewData commentViewData,
    LMPostViewData postViewData,
  ) {
    return _widgetBuilderDelegate.topResponseBuilder(
        context, topResponseWidget, commentViewData, postViewData);
  }

  /// Builds a widget to display a banner when there are no comments on a post.
  @override
  Widget addACommentBuilder(
    BuildContext context,
    LMFeedAddResponse addACommentWidget,
    LMPostViewData postViewData,
  ) {
    return _widgetBuilderDelegate.addACommentBuilder(
        context, addACommentWidget, postViewData);
  }
}
