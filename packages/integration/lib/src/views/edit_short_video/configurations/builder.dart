import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/core/core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedEditShortVideoBuilderDelegate {
  const LMFeedEditShortVideoBuilderDelegate();

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
    LMFeedWidgetSource source = LMFeedWidgetSource.createShortVideoScreen,
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

  /// app bar builder
  PreferredSizeWidget appBarBuilder(
    BuildContext context,
    LMFeedAppBar appBar,
    VoidCallback onPostCreate,
    LMResponse<void> Function() validatePost,
    LMFeedButton createPostButton,
    LMFeedButton cancelButton,
    void Function(String) onValidationFailed,
  ) {
    return appBar;
  }

  /// edit button builder
  Widget editButtonBuilder(
    BuildContext context,
    LMFeedButton editButton,
  ) {
    return editButton;
  }

  /// video preview builder
  Widget videoPreviewBuilder(
    BuildContext context,
    LMFeedVideo videoPreviewWidget,
    LMAttachmentViewData attachmentViewData,
  ) {
    return videoPreviewWidget;
  }

  /// video preview container builder
  Widget videoPreviewContainerBuilder(
    BuildContext context,
    Container videoPreviewContainer,
    Widget videoPreviewWidget,
  ) {
    return videoPreviewContainer;
  }

  /// select topic button builder
  Widget selectTopicButtonBuilder(
    BuildContext context,
    LMFeedButton selectTopicButton,
  ) {
    return selectTopicButton;
  }

  /// edit topic button builder
  Widget editTopicButtonBuilder(
    BuildContext context,
    LMFeedButton editTopicButton,
  ) {
    return editTopicButton;
  }

  /// topic chip builder
  Widget topicChipBuilder(
    BuildContext context,
    LMFeedTopicChip topicChip,
  ) {
    return topicChip;
  }

  /// topic chip container builder
  /// This is the container that holds the topic chips
  Widget topicChipContainerBuilder(
    BuildContext context,
    Container topicChipContainer,
    List<LMTopicViewData> selectedTopics,
    LMFeedButton selectTopicButton,
    LMFeedButton editTopicButton,
  ) {
    return topicChipContainer;
  }

  /// text field builder
  Widget textFieldBuilder(
    BuildContext context,
    LMTaggingAheadTextField textField,
    TextEditingController controller,
    FocusNode focusNode,
  ) {
    return textField;
  }
}
