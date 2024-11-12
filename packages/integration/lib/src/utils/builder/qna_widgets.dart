part of 'widget_utility.dart';

class LMFeedQnAWidgets extends LMFeedWidgetUtility {
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
    return post.copyWith(
      footerBuilder: (context, footer, postViewData) {
        return LMQnAPostFooter(
          footer: footer,
          postViewData: postViewData,
          source: source,
        );
      },
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
                    // color: textTertiary,
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
              // backgroundColor: dividerDark,
              ),
        ),
      ),
    );
  }

  @override
  Widget noMoreItemsIndicatorBuilderFeed(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 35,
        ),
        LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.check_circle,
          // assetPath: qNaAssetTickCircleIcon,
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
              // color: textSecondary,
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
              // color: textSecondary,
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
                    // color: textPrimary,
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
                      // color: textSecondary,
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
}

class LMQnAPostWidget extends StatefulWidget {
  final LMFeedPostWidget postWidget;
  final LMPostViewData postViewData;
  final LMFeedWidgetSource source;

  const LMQnAPostWidget({
    super.key,
    required this.postWidget,
    required this.postViewData,
    this.source = LMFeedWidgetSource.universalFeed,
  });

  @override
  State<LMQnAPostWidget> createState() => _LMQnAPostWidgetState();
}

class _LMQnAPostWidgetState extends State<LMQnAPostWidget> {
  LMPostViewData? postViewData;
  LMFeedPostWidget? postWidget;
  LMUserViewData userViewData = LMFeedLocalPreference.instance.fetchUserData()!;

  LMUserViewData? postCreator;
  String userSubText = "";

  @override
  void initState() {
    super.initState();
    postViewData = widget.postViewData;
    postWidget = widget.postWidget;
    postCreator = postViewData?.user;
    userSubText = generateUserSubText(userSubText);
  }

  @override
  void didUpdateWidget(covariant LMQnAPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    postViewData = widget.postViewData;
    postWidget = widget.postWidget;
    postCreator = postViewData?.user;
    userSubText = "";
    userSubText = generateUserSubText(userSubText);
  }

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedThemeData = LMFeedCore.theme;
    return GestureDetector(
      onTap: () {
        postWidget?.onPostTap?.call(context, postViewData!);
      },
      child: Container(
        padding: postWidget!.style?.padding,
        margin: postWidget!.style?.margin,
        decoration: BoxDecoration(
          boxShadow: postWidget!.style?.boxShadow,
          borderRadius: postWidget!.style?.borderRadius,
          border: postWidget!.style?.border,
          color: postWidget!.style?.backgroundColor ?? feedThemeData.container,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (postWidget!.header != null)
              postWidget!.header!.copyWith(
                createdAt: null,
                customTitle: LMFeedText(
                  text:
                      "• ${LMFeedTimeAgo.instance.format(postViewData!.createdAt)}",
                  style: const LMFeedTextStyle(
                    textStyle: TextStyle(
                      // color: textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
                subTextSeparator: LMFeedText(
                  text: "•",
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      color: feedThemeData.onContainer,
                      fontSize: 10,
                      fontWeight: FontWeight.w400,
                      letterSpacing: 0.15,
                    ),
                  ),
                ),
                subText: userSubText.isEmpty
                    ? null
                    : LMFeedText(
                        text: userSubText,
                        style: LMFeedTextStyle(
                          textStyle: TextStyle(
                            color: feedThemeData.onContainer,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                            letterSpacing: 0.15,
                          ),
                        ),
                      ),
                menuBuilder: (menu) => menu.copyWith(
                    removeItemIds: {},
                    action: menu.action?.copyWith(onPostReport: () {})),
              ),
            if (((postViewData!.heading?.isNotEmpty ?? false) ||
                    postViewData!.text.isNotEmpty) &&
                postWidget!.content != null)
              postWidget!.content!,
            if (postWidget!.media != null) postWidget!.media!,
            if (postWidget!.topicWidget != null) postWidget!.topicWidget!,
            //postTopics,
            if (postWidget!.footer != null)
              LMQnAPostFooter(
                footer: postWidget!.footer!,
                postViewData: postViewData!,
                source: widget.source,
              ),
          ],
        ),
      ),
    );
  }

  // This functions calculates the no of countries followed by the user
  // and the tag that they are given
  String generateUserSubText(String subText) {
    if (postCreator != null) {
      // calculate the no of countries followed by the user
      // and add it in the subtext string
      // userSubText = LMQnAFeedUtils.calculateNoCountriesFollowedByUser(
      //     userSubText, postCreator!.topics ?? []);

      // parse the tag given to user from
      // widgets and append it in the subtext string
      LMWidgetViewData? widgetViewData =
          postViewData!.widgets?[postCreator!.sdkClientInfo.widgetId];

      if (widgetViewData != null) {
        // userSubText =
        //     LMQnAFeedUtils.getUserTagFromWidget(userSubText, widgetViewData);
      }

      if (userViewData.uuid == postCreator!.uuid) {
        LMCache cache = (LMCacheBuilder()
              ..key("user_sub_text")
              ..value(userSubText))
            .build();
        LMFeedCore.client.insertOrUpdateCache(cache);
      }

      return userSubText;
    } else {
      return "";
    }
  }
}

class LMQnAPostFooter extends StatelessWidget {
  final LMFeedPostFooter footer;
  final LMPostViewData postViewData;
  final LMFeedWidgetSource? source;

  const LMQnAPostFooter({
    super.key,
    required this.footer,
    required this.postViewData,
    this.source,
  });

  @override
  Widget build(BuildContext context) {
    final LMFeedThemeData themeData = LMFeedCore.theme;
    LMFeedButton? likeButton = footer.likeButton?.copyWith(
      text: footer.likeButton?.text?.copyWith(
        text: postViewData.likeCount.toString(),
      ),
      onTap: () {
        footer.likeButton?.onTap.call();
      },
      onTextTap: () {
        footer.likeButton?.onTextTap?.call();
      },
      style: footer.likeButton?.style?.copyWith(
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmUpvoteSvg,
        ),
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmUpvoteFilledSvg,
        ),
        border: Border.all(
          color: themeData.inActiveColor,
        ),
        borderRadius: 100,
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.only(left: 20),
      ),
    );

    LMFeedButton? commentButton = footer.commentButton?.copyWith(
      text: footer.commentButton?.text?.copyWith(
        text: postViewData.commentCount.toString(),
      ),
    );
    LMFeedButton? shareButton = footer.shareButton
        ?.copyWith(style: footer.shareButton?.style?.copyWith(showText: false));

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: (postViewData.topComments != null) ? 10 : 7.5,
        ),
        if (postViewData.commentCount >= 1 &&
            postViewData.topComments != null &&
            postViewData.topComments!.isNotEmpty)
          LMQnATopResponseWidget(
            topResponses: postViewData.topComments!,
            postViewData: postViewData,
          ),
        if (source != null && source != LMFeedWidgetSource.postDetailScreen)
          QnAAddResponse(
            postCreatorUUID: postViewData.uuid,
            onTap: () {
              commentButton?.onTap.call();
            },
          ),
        const Divider(
          // color: dividerDark,
          thickness: 1,
          height: 1,
        ),
        const SizedBox(
          height: 15,
        ),
        SizedBox(
          height: 20,
          child: Row(children: [
            likeButton ?? const SizedBox(),
            const SizedBox(width: 20),
            commentButton ?? const SizedBox(),
            const Spacer(),
            if (footer.saveButton != null) footer.saveButton!,
            const SizedBox(width: 10),
            shareButton ?? const SizedBox(),
          ]),
        ),
      ],
    );
  }
}

class QnAAddResponse extends StatelessWidget {
  final void Function()? onTap;
  final String postCreatorUUID;

  const QnAAddResponse({super.key, this.onTap, required this.postCreatorUUID});

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData theme = LMFeedCore.theme;
    String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
        LMFeedPluralizeWordAction.allSmallSingular);
    LMUserViewData currentUser =
        LMFeedLocalPreference.instance.fetchUserData()!;
    return postCreatorUUID == currentUser.uuid
        ? const SizedBox()
        : GestureDetector(
            onTap: onTap,
            behavior: HitTestBehavior.translucent,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LMFeedProfilePicture(
                    fallbackText: currentUser.name,
                    imageUrl: currentUser.imageUrl,
                    onTap: () {},
                    style: LMFeedProfilePictureStyle(
                      size: 35,
                      fallbackTextStyle: LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.onPrimary,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Container(
                      height: 40,
                      alignment: Alignment.bottomLeft,
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: theme.backgroundColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: LMFeedText(
                        text: "+ Add your $commentTitleSmallCapSingular",
                        style: const LMFeedTextStyle(
                          textStyle: TextStyle(
                            fontFamily: "Inter",
                            fontWeight: FontWeight.w400,
                            fontSize: 12,
                            letterSpacing: 0.2,
                            // color: textSecondary,
                          ),
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          );
  }
}

class LMQnATopResponseWidget extends StatefulWidget {
  final List<LMCommentViewData> topResponses;
  final LMPostViewData postViewData;

  const LMQnATopResponseWidget(
      {super.key, required this.postViewData, required this.topResponses});

  @override
  State<LMQnATopResponseWidget> createState() => _LMQnATopResponseWidgetState();
}

class _LMQnATopResponseWidgetState extends State<LMQnATopResponseWidget> {
  LMCommentViewData? commentViewData;
  LMPostViewData? postViewData;
  LMUserViewData? commentCreator;
  String userSubText = "";

  String commentTitle = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  @override
  void initState() {
    super.initState();
    commentViewData = widget.topResponses.first;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
    userSubText = generateUserSubText(userSubText);
  }

  @override
  void didUpdateWidget(covariant LMQnATopResponseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    commentViewData = widget.topResponses.first;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
  }

  @override
  Widget build(BuildContext context) {
    return widget.topResponses.isEmpty
        ? const SizedBox.shrink()
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LMFeedText(
                text: "Top $commentTitle",
                style: const LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontFamily: "Inter",
                    fontWeight: FontWeight.w600,
                    // color: textTertiary,
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: LMFeedProfilePicture(
                      fallbackText: widget.topResponses.first.user.name,
                      imageUrl: widget.topResponses.first.user.imageUrl ?? "",
                      style: LMFeedProfilePictureStyle(
                        size: 35,
                        fallbackTextStyle: LMFeedTextStyle(
                          textStyle: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onTap: () {
                        LMFeedProfileBloc.instance.add(
                          LMFeedRouteToUserProfileEvent(
                            uuid: widget.topResponses.first.user.uuid,
                            context: context,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    width: 7,
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.zero,
                          topRight: Radius.circular(10.0),
                          bottomLeft: Radius.circular(10.0),
                          bottomRight: Radius.circular(10.0),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          GestureDetector(
                            behavior: HitTestBehavior.translucent,
                            onTap: () {
                              LMFeedProfileBloc.instance.add(
                                LMFeedRouteToUserProfileEvent(
                                  uuid: widget.topResponses.first.user.uuid,
                                  context: context,
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                LMFeedText(
                                  text: widget.topResponses.first.user.name,
                                  style: const LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      // color: textSecondary,
                                    ),
                                  ),
                                ),
                                if (userSubText.isNotEmpty)
                                  LMFeedText(
                                    text: userSubText,
                                    style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        color: LMFeedCore.theme.onContainer,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w400,
                                        height: 1.75,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            height: 10.0,
                          ),
                          LMFeedExpandableText(
                            LMFeedTaggingHelper.convertRouteToTag(
                                widget.topResponses.first.text),
                            expandText: "Read More",
                            prefixStyle: const TextStyle(
                              // color: textSecondary,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                              height: 1.66,
                            ),
                            expandOnTextTap: true,
                            onTagTap: (String uuid) {
                              LMFeedProfileBloc.instance.add(
                                LMFeedRouteToUserProfileEvent(
                                  uuid: uuid,
                                  context: context,
                                ),
                              );
                            },
                            style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              // color: textSecondary,
                              height: 1.66,
                            ),
                            maxLines: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 15,
              ),
            ],
          );
  }

  // This functions calculates the no of countries followed by the user
  // and the tag that they are given
  String generateUserSubText(String subText) {
    if (commentCreator != null) {
      // calculate the no of countries followed by the user
      // and add it in the subtext string
      // userSubText = LMQnAFeedUtils.calculateNoCountriesFollowedByUser(
      //     userSubText, commentCreator!.topics ?? []);

      // parse the tag given to user from
      // widgets and append it in the subtext string
      LMWidgetViewData? widgetViewData =
          postViewData!.widgets?[commentCreator!.sdkClientInfo.widgetId];

      if (widgetViewData != null) {
        // userSubText =
        //     LMQnAFeedUtils.getUserTagFromWidget(userSubText, widgetViewData);
      }
      return userSubText;
    } else {
      return "";
    }
  }
}

class LMQnACommentWidget extends StatefulWidget {
  final LMCommentViewData commentViewData;
  final LMPostViewData postViewData;
  final LMFeedCommentWidget commentWidget;

  const LMQnACommentWidget({
    super.key,
    required this.commentViewData,
    required this.postViewData,
    required this.commentWidget,
  });

  @override
  State<LMQnACommentWidget> createState() => _LMQnACommentWidgetState();
}

class _LMQnACommentWidgetState extends State<LMQnACommentWidget> {
  LMCommentViewData? commentViewData;
  LMPostViewData? postViewData;
  LMUserViewData? commentCreator;
  String userSubText = "";
  LMFeedThemeData feedThemeData = LMFeedCore.theme;

  @override
  void initState() {
    super.initState();
    commentViewData = widget.commentViewData;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
    userSubText = generateUserSubText(userSubText);
  }

  @override
  void didUpdateWidget(covariant LMQnACommentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    commentViewData = widget.commentViewData;
    postViewData = widget.postViewData;
    commentCreator = commentViewData?.user;
    userSubText = "";
    userSubText = generateUserSubText(userSubText);
  }

  @override
  Widget build(BuildContext context) {
    return widget.commentWidget.copyWith(
      customTitle: LMFeedText(
        text: " • ${LMFeedTimeAgo.instance.format(commentViewData!.createdAt)}",
        style: const LMFeedTextStyle(
          textStyle: TextStyle(
            // color: textSecondary,
            fontSize: 10,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.15,
          ),
        ),
      ),
      menu: (menu) {
        return menu.copyWith(
          removeItemIds: {},
          action: menu.action?.copyWith(),
        );
      },
      likeButtonBuilder: (button) {
        return button.copyWith(
          activeText: LMFeedText(
            text: commentViewData!.likesCount.toString(),
            style: const LMFeedTextStyle(
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                // color: textSecondary,
                fontFamily: 'Inter',
                height: 1.25,
              ),
            ),
          ),
          text: LMFeedText(
            text: commentViewData!.likesCount.toString(),
            style: const LMFeedTextStyle(
              textStyle: TextStyle(
                fontWeight: FontWeight.w400,
                // color: textSecondary,
                fontFamily: 'Inter',
                height: 1.25,
              ),
            ),
          ),
        );
      },
      subtitleText: LMFeedText(
        text: userSubText,
        style: const LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            // color: kSecondaryColor700,
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  // This functions calculates the no of countries followed by the user
  // and the tag that they are given
  String generateUserSubText(String subText) {
    if (commentCreator != null) {
      // calculate the no of countries followed by the user
      // and add it in the subtext string
      // userSubText = LMQnAFeedUtils.calculateNoCountriesFollowedByUser(
      //     userSubText, commentCreator!.topics ?? []);

      // parse the tag given to user from
      // widgets and append it in the subtext string
      LMWidgetViewData? widgetViewData =
          postViewData!.widgets?[commentCreator!.sdkClientInfo.widgetId];

      if (widgetViewData != null) {
        // userSubText =
        //     LMQnAFeedUtils.getUserTagFromWidget(userSubText, widgetViewData);
      }

      return userSubText;
    } else {
      return "";
    }
  }
}
