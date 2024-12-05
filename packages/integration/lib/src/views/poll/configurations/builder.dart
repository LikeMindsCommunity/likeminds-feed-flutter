import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_poll_screen_builder_delegate}
/// Builder delegate for Poll Screen
/// Used to customise the Poll Screen's Widgets
/// {@endtemplate}
class LMFeedPollScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_poll_screen_builder_delegate}
  const LMFeedPollScreenBuilderDelegate();

  /// feedWidgetBuilder
  static final LMFeedWidgetBuilderDelegate _widgetBuilderDelegate =
      LMFeedCore.config.widgetBuilderDelegate;

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
}
