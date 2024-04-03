import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedWidgetUtility {
  LMFeedWidgetUtility();

  static LMFeedWidgetUtility? _instance;

  static LMFeedWidgetUtility get instance =>
      _instance ??= LMFeedWidgetUtility();

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
      child: PopScope(
        canPop: canPop,
        onPopInvoked: onPopInvoked,
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

  Widget postWidgetBuilder(
      BuildContext context, LMFeedPostWidget post, LMPostViewData postViewData,
      {LMFeedWidgetSource source = LMFeedWidgetSource.universalFeed}) {
    return post.copyWith(
      headerBuilder: this.headerBuilder,
      contentBuilder: this.postContentBuilder,
      mediaBuilder: this.postMediaBuilder,
      footerBuilder: this.postFooterBuilder,
      menuBuilder: this.menuBuilder,
      topicBuilder: this.topicBuilder,
    );
  }

  Widget commentBuilder(BuildContext context, LMFeedCommentWidget commentWidget,
      LMPostViewData postViewData) {
    return commentWidget;
  }

  Widget headerBuilder(BuildContext context, LMFeedPostHeader postHeader,
      LMPostViewData postViewData) {
    return postHeader;
  }

  Widget menuBuilder(
      BuildContext context, LMFeedMenu menu, LMPostViewData postViewData) {
    return menu;
  }

  Widget topicBuilder(BuildContext context, LMFeedPostTopic postTopic,
      LMPostViewData postViewData) {
    return postTopic;
  }

  Widget postContentBuilder(BuildContext context, LMFeedPostContent postContent,
      LMPostViewData postViewData) {
    return postContent;
  }

  Widget postMediaBuilder(BuildContext context, LMFeedPostMedia postMedia,
      LMPostViewData postViewData) {
    return postMedia.copyWith(
        carouselIndicatorBuilder: this.postMediaCarouselIndicatorBuilder);
  }

  Widget postFooterBuilder(BuildContext context, LMFeedPostFooter postFooter,
      LMPostViewData postViewData) {
    return postFooter;
  }

  Widget imageBuilder(LMFeedImage image) {
    return image;
  }

  Widget videoBuilder(LMFeedVideo video) {
    return video;
  }

  Widget postMediaCarouselIndicatorBuilder(BuildContext context, int currIndex,
      int mediaLength, Widget carouselIndicator) {
    return carouselIndicator;
  }

  /// Feed Screen Builder Widgets
  /// These widgets are used to build the feed screen
  Widget customWidgetBuilder(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget floatingActionButtonBuilder(
      BuildContext context, LMFeedButton floatingActionButton) {
    return floatingActionButton;
  }

  Widget noItemsFoundIndicatorBuilderFeed(BuildContext context,
      {LMFeedButton? createPostButton}) {
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
            text: 'No posts to show',
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: feedThemeData.onContainer,
              ),
            ),
          ),
          const SizedBox(height: 12),
          LMFeedText(
            text: "Be the first one to post here",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
                color: feedThemeData.onContainer,
              ),
            ),
          ),
          const SizedBox(height: 28),
          if (createPostButton != null) createPostButton,
        ],
      ),
    );
  }

  Widget noPostUnderTopicFeed(BuildContext context,
      {LMFeedButton? actionable}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const LMFeedText(
            text: "Looks like there are no posts for this topic yet.",
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

  Widget firstPageProgressIndicatorBuilderFeed(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return LMFeedLoader(
      style: feedThemeData.loaderStyle,
    );
  }

  Widget newPageProgressIndicatorBuilderFeed(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return LMFeedLoader(
      style: feedThemeData.loaderStyle,
    );
  }

  Widget firstPageErrorIndicatorBuilderFeed(BuildContext context) {
    return const SizedBox();
  }

  Widget newPageErrorIndicatorBuilderFeed(BuildContext context) {
    return const SizedBox();
  }

  Widget noMoreItemsIndicatorBuilderFeed(BuildContext context) {
    return const SizedBox.shrink();
  }

  Widget topicBarBuilder(LMFeedTopicBar topicBar) {
    return const SizedBox();
  }

  Widget composeScreenUserHeaderBuilder(
      BuildContext context, LMUserViewData user) {
    return const SizedBox.shrink();
  }

  Widget composeScreenTopicSelectorBuilder(BuildContext context,
      Widget topicSelector, List<LMTopicViewData> selectedTopics) {
    return topicSelector;
  }
}
