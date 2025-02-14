import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/core/core.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedTopicSelectScreenBuilderDelegate {
  const LMFeedTopicSelectScreenBuilderDelegate();

  static final LMFeedWidgetBuilderDelegate _widgetBuilderDelegate =
      LMFeedCore.config.widgetBuilderDelegate;

  /// scaffold builder for the Topic Select Screen
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
    LMFeedWidgetSource source = LMFeedWidgetSource.topicSelectScreen,
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

  /// app bar builder for the Topic Select Screen
  PreferredSizeWidget appBarBuilder(BuildContext context, LMFeedAppBar appBar) {
    return appBar;
  }

  /// builder for the Topic tile
  Widget topicTileBuilder(
    BuildContext context,
    LMFeedTopicTile topicTile,
    LMTopicViewData topic,
    bool isSelected,
  ) {
    return topicTile;
  }

  /// no item indicator builder
  Widget noItemIndicatorBuilder(BuildContext context, Widget child) {
    return child;
  }

  /// no more items indicator builder
  Widget Function(BuildContext)? noMoreItemsIndicatorBuilder(
      BuildContext context) {
    return null;
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
}
