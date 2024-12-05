import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_media_preview_screen_builder_delegate}
/// Builder delegate for MediaPreview Screen
/// Used to customise the MediaPreview Screen's Widgets
/// {@endtemplate}
class LMFeedMediaPreviewScreenBuilderDelegate
    extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_media_preview_screen_builder_delegate}
  const LMFeedMediaPreviewScreenBuilderDelegate();

  /// feedWidgetBuilder
  static final LMFeedWidgetBuilderDelegate _widgetBuilderDelegate =
      LMFeedCore.config.widgetBuilderDelegate;

  /// AppBar builder for the MediaPreview Screen
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
    LMFeedWidgetSource source = LMFeedWidgetSource.mediaPreviewScreen,
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

  /// Builds a carousel indicator widget for post media.
  @override
  Widget postMediaCarouselIndicatorBuilder(BuildContext context, int currIndex,
      int mediaLength, Widget carouselIndicator) {
    return _widgetBuilderDelegate.postMediaCarouselIndicatorBuilder(
        context, currIndex, mediaLength, carouselIndicator);
  }
}
