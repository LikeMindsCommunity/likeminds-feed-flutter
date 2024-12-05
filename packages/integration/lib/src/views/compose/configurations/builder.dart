import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/core/core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

/// {@template lm_feed_compose_screen_builder_delegate}
/// Builder delegate for Compose Screen
/// Used to customise the Compose Screen's Widgets
/// {@endtemplate}
class LMFeedComposeScreenBuilderDelegate extends LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_compose_screen_builder_delegate}
  const LMFeedComposeScreenBuilderDelegate();

  /// feedWidgetBuilder
  static final LMFeedWidgetBuilderDelegate _widgetBuilderDelegate =
      LMFeedCore.config.widgetBuilderDelegate;

  /// app bar builder
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar oldAppBar,
    LMResponse<void> Function() onPostCreate,
    LMResponse<void> Function() validatePost,
    LMFeedButton createPostButton,
    LMFeedButton cancelButton,
    void Function(String) onValidationFailed,
  ) {
    return oldAppBar;
  }

  /// Builds the user header for the compose screen.
  Widget composeScreenUserHeaderBuilder(
      BuildContext context, LMUserViewData user, LMFeedUserTile userTile) {
    return userTile;
  }

  /// Builds the topic selector for the compose screen.
  Widget composeScreenTopicSelectorBuilder(BuildContext context,
      Widget topicSelector, List<LMTopicViewData> selectedTopics) {
    return topicSelector;
  }

  /// Builds the heading text field for the compose screen.
  Widget composeScreenHeadingTextfieldBuilder(
      BuildContext context, TextField headingTextField) {
    return headingTextField;
  }

  /// Builds the content text field for the compose screen.
  Widget composeScreenContentTextfieldBuilder(
      BuildContext context, LMTaggingAheadTextField contentTextField) {
    return contentTextField;
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
    LMFeedWidgetSource source = LMFeedWidgetSource.createPostScreen,
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
}
