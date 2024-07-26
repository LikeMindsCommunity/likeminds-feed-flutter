import 'package:flutter/gestures.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/comment/qna_comment_widget.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/post/lm_qna_post_footer.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/post/lm_qna_post_widget.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/topic/compose_topic_selector.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';

class LMFeedQnAWidgets extends LMFeedWidgetUtility {
  static LMFeedQnAWidgets? _instance;

  static LMFeedQnAWidgets get instance => _instance ??= LMFeedQnAWidgets._();

  LMFeedQnAWidgets._();

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
    LMFeedWidgetSource source = LMFeedWidgetSource.universalFeed,
    bool canPop = true,
    Function(bool)? onPopInvoked,
  }) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: LMFeedCore.config.globalSystemOverlayStyle ??
          SystemUiOverlayStyle.dark,
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
    );
  }

  @override
  Widget postWidgetBuilder(
      BuildContext context, LMFeedPostWidget post, LMPostViewData postViewData,
      {LMFeedWidgetSource source = LMFeedWidgetSource.universalFeed}) {
    return LMQnAPostWidget(
      postWidget: post,
      postViewData: postViewData,
      source: source,
    );
  }

  @override
  Widget commentBuilder(BuildContext context, LMFeedCommentWidget commentWidget,
      LMPostViewData postViewData) {
    return LMQnACommentWidget(
      commentViewData: commentWidget.comment,
      postViewData: postViewData,
      commentWidget: commentWidget,
    );
  }

  @override
  Widget headerBuilder(BuildContext context, LMFeedPostHeader postHeader,
      LMPostViewData postViewData) {
    return postHeader;
  }

  @override
  Widget menuBuilder(
      BuildContext context, LMFeedMenu menu, LMPostViewData postViewData) {
    return menu;
  }

  @override
  Widget topicBuilder(BuildContext context, LMFeedPostTopic postTopic,
      LMPostViewData postViewData) {
    return postTopic;
  }

  @override
  Widget postContentBuilder(BuildContext context, LMFeedPostContent postContent,
      LMPostViewData postViewData) {
    return postContent;
  }

  @override
  Widget postMediaBuilder(BuildContext context, LMFeedPostMedia postMedia,
      LMPostViewData postViewData) {
    return postMedia;
  }

  @override
  Widget postFooterBuilder(BuildContext context, LMFeedPostFooter postFooter,
      LMPostViewData postViewData) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;

    return LMQnAPostFooter(
      feedThemeData: feedThemeData,
      footer: postFooter,
      postViewData: postViewData,
    );
  }

  @override
  Widget postMediaCarouselIndicatorBuilder(
      context, int currIndex, int mediaLength, carouselIndicator) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;

    return mediaLength == 0
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(mediaLength, (index) {
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2.5),
                  decoration: BoxDecoration(
                    color: textTertiary,
                    borderRadius:
                        BorderRadius.circular(currIndex == index ? 100.0 : 6.0),
                  ),
                  height: index == currIndex ? null : 5,
                  width: index == currIndex ? null : 5,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10.0,
                    vertical: 5.0,
                  ),
                  child: currIndex == index
                      ? LMFeedText(
                          text: "${currIndex + 1}/$mediaLength",
                          style: LMFeedTextStyle(
                            textStyle: TextStyle(
                              fontSize: 10.0,
                              color: feedThemeData.container,
                            ),
                          ),
                        )
                      : null,
                );
              }),
            ),
          );
  }

  @override
  Widget newPageProgressIndicatorBuilderFeed(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return Container(
      margin: const EdgeInsets.only(bottom: 100),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: feedThemeData.container,
      ),
      child: Center(
        child: LMFeedLoader(
          style: feedThemeData.loaderStyle.copyWith(
            backgroundColor: dividerDark,
          ),
        ),
      ),
    );
  }

  @override
  Widget noMoreItemsIndicatorBuilderFeed(BuildContext context) {
    return const Column(
      children: <Widget>[
        SizedBox(
          height: 35,
        ),
        LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: qNaAssetTickCircleIcon,
          style: LMFeedIconStyle(
            size: 80,
            boxPadding: 10,
          ),
        ),
        SizedBox(
          height: 10,
        ),
        LMFeedText(
          text: "That's a wrap!",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontWeight: FontWeight.w600,
              fontFamily: "Inter",
              fontSize: 16,
              color: textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 10,
        ),
        LMFeedText(
          text: "You have reached the end of the page",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: "Inter",
              fontSize: 16,
              color: textSecondary,
            ),
          ),
        ),
        SizedBox(
          height: 100,
        ),
      ],
    );
  }

  @override
  Widget composeScreenUserHeaderBuilder(
      BuildContext context, LMUserViewData user) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    LMResponse userSubTextResponse =
        LMFeedCore.client.getCache('user_sub_text');

    String userSubText = "";

    if (userSubTextResponse.success) {
      userSubText = userSubTextResponse.data!.value;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      child: Row(
        children: [
          LMFeedProfilePicture(
            fallbackText: user.name,
            imageUrl: user.imageUrl,
            style: LMFeedProfilePictureStyle(
              size: 35,
              fallbackTextStyle: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 14,
                  color: feedThemeData.onPrimary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              LMFeedText(
                text: user.name,
                style: const LMFeedTextStyle(
                  textStyle: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (userSubText.isNotEmpty)
                LMFeedText(
                  text: userSubText,
                  style: const LMFeedTextStyle(
                    textStyle: TextStyle(
                      color: textSecondary,
                      fontSize: 10,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget composeScreenTopicSelectorBuilder(BuildContext context,
          Widget topicSelector, List<LMTopicViewData> selectedTopics) =>
      LMFeedQnAComposeScreenTopicSelector(selectedTopics: selectedTopics);
}
