import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_report_screen_builder_delegate}
/// Builder delegate for Report Screen
/// Used to customise the Report Screen's Widgets
/// {@endtemplate}
class LMFeedReportScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_report_screen_builder_delegate}
  const LMFeedReportScreenBuilderDelegate();

  /// feedWidgetBuilder
  static final LMFeedWidgetBuilderDelegate _widgetBuilderDelegate =
      LMFeedCore.config.widgetBuilderDelegate;

  /// AppBar builder for the Report Screen
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
    LMFeedWidgetSource source = LMFeedWidgetSource.reportScreen,
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

  /// Loader builder for the Report Screen
  Widget loaderBuilder(BuildContext context, LMFeedLoader loader) {
    return loader;
  }

  /// Builder for the Report Screen's Success icon
  Widget successIconBuilder(BuildContext context, LMFeedIcon successIcon) {
    return successIcon;
  }

  /// Builder for the Report Screen's Success text
  Widget successTextBuilder(BuildContext context, LMFeedText successText) {
    return successText;
  }

  /// Builder for the Report Screen's Success sub text
  Widget successSubTextBuilder(
      BuildContext context, LMFeedText successSubText) {
    return successSubText;
  }

  /// Builder for the Report Screen's Content widget
  Widget contentBuilder(BuildContext context, LMReportContentWidget content) {
    return content;
  }

  /// Builder for submit button
  Widget submitButtonBuilder(BuildContext context, LMFeedButton submitButton) {
    return submitButton;
  }

  /// Builder for the Report Screen's chip
  Widget chipBuilder(
      BuildContext context, Chip chip, LMDeleteReasonViewData data) {
    return chip;
  }

}
