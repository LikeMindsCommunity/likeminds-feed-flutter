import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/core/configurations/feed_builder.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/activity/notification_tile.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_notification_screen_builder_delegate}
/// Builder delegate for Notification Screen
/// Used to customise the Notification Screen's Widgets
/// {@endtemplate}
class LMFeedNotificationScreenBuilderDelegate
    extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_notification_screen_builder_delegate}
  const LMFeedNotificationScreenBuilderDelegate();

  /// feedWidgetBuilder
  static final LMFeedWidgetBuilderDelegate _widgetBuilderDelegate =
      LMFeedCore.config.widgetBuilderDelegate;

  /// AppBar builder for the Notification Screen
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
  ) {
    return appBar;
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
    LMFeedWidgetSource source = LMFeedWidgetSource.notificationScreen,
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

  /// Notification Tile Builder
  Widget notificationTileBuilder(
      BuildContext context,
      LMNotificationFeedItemViewData notificationData,
      LMFeedNotificationTile tile) {
    return tile;
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
}
