import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_widget_builder_delegate}
/// A delegate class that provides methods to build and customize widgets for the feed.
/// Implement this class to customize the widgets across different screens in the feed.
/// Use this class when you want to apply a consistent customization to widgets throughout the feed.
/// {@endtemplate}
class LMFeedWidgetBuilderDelegate {
  /// {@macro lm_feed_widget_builder_delegate}
  const LMFeedWidgetBuilderDelegate();

  static LMFeedWidgetBuilderDelegate? _instance;

  /// Returns the singleton instance of [LMFeedWidgetBuilderDelegate].
  static LMFeedWidgetBuilderDelegate get instance =>
      _instance ??= LMFeedWidgetBuilderDelegate();

  /// Builds a scaffold widget.
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
    LMFeedWidgetSource source = LMFeedWidgetSource.universalFeed,
    bool canPop = true,
    Function(bool)? onPopInvoked,
  }) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: LMFeedCore.config.globalSystemOverlayStyle ??
          SystemUiOverlayStyle.dark,
      child: WillPopScope(
        onWillPop: () async {
          onPopInvoked?.call(canPop);
          return Future.value(canPop);
        },
        child: Scaffold(
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
        ),
      ),
    );
  }

  /// Builds app bar widget.
  PreferredSizeWidget appBar(
    BuildContext context,
    LMFeedAppBar appBar, [
    LMFeedWidgetSource? source,
  ]) {
    return appBar;
  }

  /// Builds a post widget with customized builders.
  Widget postWidgetBuilder(
      BuildContext context, LMFeedPostWidget post, LMPostViewData postViewData,
      {LMFeedWidgetSource source = LMFeedWidgetSource.universalFeed}) {
    Size screenSize = MediaQuery.sizeOf(context);
    bool isDesktopWeb;
    if (screenSize.width > LMFeedCore.config.webConfiguration.maxWidth &&
        kIsWeb) {
      isDesktopWeb = true;
    } else {
      isDesktopWeb = false;
    }

    return post.copyWith(
      headerBuilder: this.postHeaderBuilder,
      contentBuilder: this.postContentBuilder,
      mediaBuilder: this.postMediaBuilder,
      footerBuilder: this.postFooterBuilder,
      menuBuilder: this.postMenuBuilder,
      topicBuilder: this.topicBuilder,
      reviewBannerBuilder: this.postReviewBannerBuilder,
      style: post.style?.copyWith(
          borderRadius: isDesktopWeb
              ? BorderRadius.circular(8.0)
              : post.style?.borderRadius),
    );
  }

  //TODO: remove from here
  /// Builds a post review banner widget.
  Widget postReviewBannerBuilder(BuildContext context,
      LMFeedPostReviewBanner postReviewBanner, LMPostViewData postViewData) {
    return postReviewBanner;
  }

  /// Builds a comment widget.
  Widget commentBuilder(BuildContext context, LMFeedCommentWidget commentWidget,
      LMPostViewData postViewData) {
    return commentWidget;
  }

  /// Builds a post header widget.
  Widget postHeaderBuilder(BuildContext context, LMFeedPostHeader postHeader,
      LMPostViewData postViewData) {
    return postHeader;
  }

  /// Builds a menu widget.
  Widget postMenuBuilder(
      BuildContext context, LMFeedMenu menu, LMPostViewData postViewData) {
    return menu;
  }

  /// Builds a topic widget.
  Widget topicBuilder(BuildContext context, LMFeedPostTopic postTopic,
      LMPostViewData postViewData) {
    return postTopic;
  }

  /// Builds a post content widget.
  Widget postContentBuilder(BuildContext context, LMFeedPostContent postContent,
      LMPostViewData postViewData) {
    return postContent;
  }

  /// Builds a post media widget.
  Widget postMediaBuilder(BuildContext context, LMFeedPostMedia postMedia,
      LMPostViewData postViewData) {
    return postMedia.copyWith(
        carouselIndicatorBuilder: this.postMediaCarouselIndicatorBuilder);
  }

  /// Builds a post footer widget.
  Widget postFooterBuilder(BuildContext context, LMFeedPostFooter postFooter,
      LMPostViewData postViewData) {
    return postFooter;
  }

  /// Builds an image widget.
  Widget imageBuilder(LMFeedImage image) {
    return image;
  }

  /// Builds a video widget.
  Widget videoBuilder(LMFeedVideo video) {
    return video;
  }

  /// Builds a poll widget.
  Widget pollWidgetBuilder(BuildContext context, LMFeedPoll pollWidget) {
    return pollWidget;
  }

  /// Builds a carousel indicator widget for post media.
  Widget postMediaCarouselIndicatorBuilder(BuildContext context, int currIndex,
      int mediaLength, Widget carouselIndicator) {
    return carouselIndicator;
  }

  // Feed Screen Builder Widgets
  //TODO: remove from here add to feed screen builder
  /// Builds a custom widget for the feed screen.
  Widget customWidgetBuilder(
      LMFeedPostSomething postSomethingWidget, BuildContext context) {
    return postSomethingWidget;
  }

  //TODO: remove from here add to feed screen builder
  /// Builds a floating action button for the feed screen.
  Widget floatingActionButtonBuilder(
      BuildContext context, LMFeedButton floatingActionButton) {
    return floatingActionButton;
  }

  /// Builds an indicator when no items are found in the feed.
  Widget noItemsFoundIndicatorBuilderFeed(BuildContext context,
      {LMFeedButton? createPostButton, bool isSelfPost = true}) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: Icons.post_add,
            style: LMFeedIconStyle(
              size: 48,
              color: feedThemeData.onContainer,
            ),
          ),
          const SizedBox(height: 12),
          LMFeedText(
            text:
                'No ${LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural)} to show',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: feedThemeData.onContainer,
              ),
            ),
          ),
          if (isSelfPost) const SizedBox(height: 12),
          if (isSelfPost)
            LMFeedText(
              text:
                  "Be the first one to create a ${LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular)} here",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: feedThemeData.onContainer,
                ),
              ),
            ),
          if (isSelfPost) const SizedBox(height: 28),
          if (createPostButton != null && isSelfPost) createPostButton,
        ],
      ),
    );
  }

  /// Builds an indicator when there are no posts under a topic in the feed.
  Widget noPostUnderTopicFeed(BuildContext context,
      {LMFeedButton? actionable}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LMFeedText(
            text:
                "Looks like there are no ${LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural)} for this topic yet.",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (actionable != null) actionable,
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a progress indicator for the first page of the feed.
  Widget firstPageProgressIndicatorBuilderFeed(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return LMFeedLoader(
      style: feedThemeData.loaderStyle,
    );
  }

  /// Builds a progress indicator for subsequent pages of the feed.
  Widget newPageProgressIndicatorBuilderFeed(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return LMFeedLoader(
      style: feedThemeData.loaderStyle,
    );
  }

  /// Builds an error indicator for the first page of the feed.
  Widget firstPageErrorIndicatorBuilderFeed(BuildContext context) {
    return const SizedBox();
  }

  /// Builds an error indicator for subsequent pages of the feed.
  Widget newPageErrorIndicatorBuilderFeed(BuildContext context) {
    return const SizedBox();
  }

  /// Builds an indicator when there are no more items to load in the feed.
  Widget noMoreItemsIndicatorBuilderFeed(BuildContext context) {
    return const SizedBox.shrink();
  }

  /// Builds a topic bar widget.
  Widget topicBarBuilder(LMFeedTopicBar topicBar) {
    return const SizedBox();
  }

  //TODO: remove from here add to compose screen builder
  /// Builds the app bar for the compose screen.
  PreferredSizeWidget composeScreenAppBar(
    BuildContext context,
    LMFeedAppBar appBar,
    LMResponse<void> Function() onPostCreate,
    LMResponse<void> Function() validatePost,
    LMFeedButton createPostButton,
    LMFeedButton cancelButton,
    void Function(String) onValidationFailed,
  ) {
    return appBar;
  }

  //TODO: remove from here add to feed screen builder
  /// Builds the user header for the compose screen.
  Widget composeScreenUserHeaderBuilder(
      BuildContext context, LMUserViewData user, LMFeedUserTile userTile) {
    return userTile;
  }

  //TODO: remove from here add to feed screen builder
  /// Builds the topic selector for the compose screen.
  Widget composeScreenTopicSelectorBuilder(BuildContext context,
      Widget topicSelector, List<LMTopicViewData> selectedTopics) {
    return topicSelector;
  }

  //TODO: remove from here add to feed screen builder
  /// Builds the heading text field for the compose screen.
  Widget composeScreenHeadingTextfieldBuilder(
      BuildContext context, TextField headingTextField) {
    return headingTextField;
  }

  //TODO: remove from here add to feed screen builder
  /// Builds the content text field for the compose screen.
  Widget composeScreenContentTextfieldBuilder(
      BuildContext context, LMTaggingAheadTextField contentTextField) {
    return contentTextField;
  }

  /// {@template snackbar_builder}
  /// Builds a [SnackBar] widget based on the provided [snackBar].
  /// {@endtemplate}
  SnackBar snackBarBuilder(
      BuildContext context, String snackBarMessage, LMFeedWidgetSource source,
      {LMFeedSnackBarStyle? style}) {
    Size size = MediaQuery.sizeOf(context);
    LMFeedSnackBarStyle inStyle = style ?? LMFeedCore.theme.snackBarTheme;
    double width = inStyle.width ?? size.width * 0.8;
    return LMFeedSnackBar(
      content: LMFeedText(text: snackBarMessage),
      style: inStyle.copyWith(
          width: min(
              LMFeedCore.config.webConfiguration.maxWidthForSnackBars, width)),
    );
  }

  /// Builds a bottom text field for the feed screen.
  /// This is used to add a comment to a post.
  ///   //TODO: remove from here add to post detail screen builder
  Widget bottomTextFieldBuilder(
    BuildContext context,
    LMFeedBottomTextField textField,
    TextEditingController controller,
    FocusNode focusNode,
    LMFeedWidgetSource source,
  ) {
    return textField;
  }

  /// Builds a top response widget for the feed screen.
  /// This is used to show the top response to a post below the post content.
  Widget topResponseBuilder(
    BuildContext context,
    LMFeedTopResponseWidget topResponseWidget,
    LMCommentViewData commentViewData,
    LMPostViewData postViewData,
  ) {
    return topResponseWidget;
  }

  /// Builds a widget to display a banner when there are no comments on a post.
  Widget addACommentBuilder(
    BuildContext context,
    LMFeedAddResponse addACommentWidget,
    LMPostViewData postViewData,
  ) {
    return addACommentWidget;
  }
}
