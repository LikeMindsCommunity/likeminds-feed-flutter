part of './widget_utility.dart';

class LMFeedQnAWidgets extends LMFeedWidgetUtility {
  @override
  LMFeedPostWidget postWidgetBuilder(
      BuildContext context, LMFeedPostWidget post, LMPostViewData postViewData,
      {LMFeedWidgetSource source = LMFeedWidgetSource.universalFeed}) {
    return post.copyWith(
      footerBuilder: (context, footer, postViewData) {
        return LMFeedQnAPostFooter(
          footer: footer,
          postViewData: postViewData,
          source: source,
        );
      },
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
  }

  @override
  void didUpdateWidget(covariant LMQnAPostWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    postViewData = widget.postViewData;
    postWidget = widget.postWidget;
    postCreator = postViewData?.user;
    userSubText = "";
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
              LMFeedQnAPostFooter(
                footer: postWidget!.footer!,
                postViewData: postViewData!,
                source: widget.source,
              ),
          ],
        ),
      ),
    );
  }
}

class LMFeedQnAPostFooter extends StatelessWidget {
  final LMFeedPostFooter footer;
  final LMPostViewData postViewData;
  final LMFeedWidgetSource? source;

  const LMFeedQnAPostFooter({
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
          text: "Upvote • " + postViewData.likeCount.toString(),
          style: LMFeedTextStyle.basic().copyWith(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: LikeMindsTheme.greyColor,
            ),
          )),
      onTap: () {
        footer.likeButton?.onTap.call();
      },
      onTextTap: () {
        footer.likeButton?.onTextTap?.call();
      },
      style: footer.likeButton?.style?.copyWith(
        backgroundColor: LikeMindsTheme.unSelectedColor.withOpacity(0.5),
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmUpvoteSvg,
          style: LMFeedIconStyle.basic().copyWith(
            size: 24,
          ),
        ),
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmUpvoteFilledSvg,
          style: LMFeedIconStyle.basic().copyWith(
            size: 24,
          ),
        ),
        border: Border.all(
          color: themeData.backgroundColor,
        ),
        borderRadius: 100,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        margin: EdgeInsets.only(left: 16),
      ),
    );

    final String answerText = postViewData.commentCount == 0
        ? "Answer "
        : postViewData.commentCount.toString();
    LMFeedButton? commentButton = footer.commentButton?.copyWith(
      text: footer.commentButton?.text?.copyWith(
        text: answerText,
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
        const Divider(
          thickness: 1,
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10.0),
          child: Row(
            children: [
              likeButton ?? const SizedBox(),
              const Spacer(),
              commentButton ?? const SizedBox(),
              const SizedBox(width: 20),
              if (footer.saveButton != null) footer.saveButton!,
              const SizedBox(width: 10),
              shareButton ?? const SizedBox(),
            ],
          ),
        ),
        if (postViewData.commentCount == 0 &&
            source != null &&
            source != LMFeedWidgetSource.postDetailScreen)
          Column(
            children: [
              const Divider(
                thickness: 1,
                height: 1,
              ),
              QnAAddResponse(
                onTap: () {
                  // navigate to post detail screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LMFeedPostDetailScreen(
                        postId: postViewData.id,
                        openKeyboard: true,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
      ],
    );
  }
}

class QnAAddResponse extends StatelessWidget {
  final void Function()? onTap;

  const QnAAddResponse({
    super.key,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData theme = LMFeedCore.theme;
    String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
        LMFeedPluralizeWordAction.allSmallSingular);
    LMUserViewData currentUser =
        LMFeedLocalPreference.instance.fetchUserData()!;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.translucent,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 12.0,
          horizontal: 16,
        ),
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
              child: LMFeedText(
                text: "Be the first one to answer",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: LikeMindsTheme.greyColor,
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
        : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LMFeedText(
                  text: "Top Response",
                  style: const LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w500,
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
                    LMFeedProfilePicture(
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
                    const SizedBox(
                      width: 7,
                    ),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color:
                              LikeMindsTheme.unSelectedColor.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(8),
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
                                  LMFeedText(
                                    text:
                                        "${LMFeedTimeAgo.instance.format(postViewData!.createdAt)}",
                                    style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        color: LMFeedCore.theme.inActiveColor,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 4.0,
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
