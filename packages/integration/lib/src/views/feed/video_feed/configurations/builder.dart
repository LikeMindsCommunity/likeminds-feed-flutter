import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/core/core.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/video_feed/widget/vertical_post.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedVideoFeedScreenBuilderDelegate {
  const LMFeedVideoFeedScreenBuilderDelegate();

  /// Default widget builder delegate for the feed screen.
  static final LMFeedWidgetBuilderDelegate _widgetBuilderDelegate =
      LMFeedCore.config.widgetBuilderDelegate;

  // scaffold builder
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
    LMFeedWidgetSource source = LMFeedWidgetSource.videoFeed,
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

  // app bar builder
  /// Override this method to provide a custom app bar for the QnA screen.
  PreferredSizeWidget appBarBuilder(BuildContext context, LMFeedAppBar appBar) {
    return appBar;
  }

  /// page view builder
  Widget pageViewBuilder(BuildContext context, PagedPageView pageView) {
    return pageView;
  }

  /// vertical post view builder
  Widget postViewBuilder(BuildContext context,
      LMFeedVerticalVideoPost postWidget, LMPostViewData postViewData) {
    return postWidget;
  }

  /// no item indicator builder
  Widget noItemIndicatorBuilder(BuildContext context, Widget child) {
    return child;
  }

  /// no more items indicator builder
  Widget noMoreItemsIndicatorBuilder(BuildContext context, Widget child) {
    return child;
  }

  /// first page progress indicator builder
  Widget firstPageProgressIndicatorBuilder(
      BuildContext context, LMFeedLoader child) {
    return child;
  }

  /// new page progress indicator builder
  Widget newPageProgressIndicatorBuilder(
      BuildContext context, LMFeedLoader child) {
    return child;
  }

  /// first page error indicator builder
  Widget Function(BuildContext)? firstPageErrorIndicatorBuilder(
      BuildContext context) {
    return null;
  }

  /// new page error indicator builder
  Widget Function(BuildContext)? newPageErrorIndicatorBuilder(
      BuildContext context) {
    return null;
  }

  /// uploading post content builder
  Widget uploadingPostContentBuilder(
    BuildContext context,
    Container child,
    LMFeedLoader loader,
    LMFeedText text,
    bool isUploading,
    bool isEditing,
  ) {
    return child;
  }

  /// text builder for uploading post
  Widget uploadingPostTextBuilder(BuildContext context, LMFeedText text) {
    return text;
  }

  /// loader builder for uploading post
  Widget uploadingPostLoaderBuilder(BuildContext context, LMFeedLoader loader) {
    return loader;
  }
}
