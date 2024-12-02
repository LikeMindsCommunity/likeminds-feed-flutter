// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_activity_screen}
/// A screen that displays the activity feed.
/// {@endtemplate}
class LMFeedActivityScreen extends StatefulWidget {
  /// uuid of the user whose activity feed is to be displayed.
  /// should be fetched from the user's sdkClientInfo.
  final String uuid;

  /// Builder for the post widget.
  final LMFeedPostWidgetBuilder? postBuilder;

  /// Builder for the comment widget.
  final LMFeedPostCommentBuilder? commentBuilder;

  /// Builder for app bar.
  final LMFeedAppBarBuilder? appBarBuilder;

  /// {@macro lm_feed_activity_screen}
  const LMFeedActivityScreen({
    super.key,
    required this.uuid,
    this.postBuilder,
    this.commentBuilder,
    this.appBarBuilder,
  });

  @override
  State<LMFeedActivityScreen> createState() => _LMFeedActivityScreenState();
}

class _LMFeedActivityScreenState extends State<LMFeedActivityScreen> {
  late Size screenSize;
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  LMFeedActivityScreenBuilderDelegate _widgetBuilder =
      LMFeedCore.config.activityScreenConfig.builder;
  final PagingController<int, UserActivityItem> _pagingController =
      PagingController(firstPageKey: 1);
  Map<String, LMUserViewData> users = {};
  Map<String, LMTopicViewData> topics = {};
  Map<String, LMWidgetViewData> widgets = {};
  Map<String, Post> repostedPosts = {};
  Map<String, Comment> filteredComments = {};

  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();

  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();

  LMFeedThemeData feedTheme = LMFeedCore.theme;

  LMFeedWidgetSource widgetSource = LMFeedWidgetSource.activityScreen;

  LMFeedWebConfiguration webConfig = LMFeedCore.config.webConfiguration;
  bool isDesktopWeb = false;
  LMFeedWidgetSource source = LMFeedWidgetSource.activityScreen;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.sizeOf(context);
    if (screenSize.width > webConfig.maxWidth && kIsWeb) {
      isDesktopWeb = true;
    } else {
      isDesktopWeb = false;
    }
  }

  @override
  void initState() {
    _pagingController.addPageRequestListener((pageKey) {
      _fetchPage(pageKey);
    });
    super.initState();
  }

  void _fetchPage(int pageKey) async {
    try {
      final request = (GetUserActivityRequestBuilder()
            ..uuid(widget.uuid)
            ..page(pageKey)
            ..pageSize(10))
          .build();

      GetUserActivityResponse userActivityResponse =
          await LMFeedCore.client.getUserActivity(request);

      if (userActivityResponse.success) {
        widgets.addAll(userActivityResponse.widgets?.map((key, value) =>
                MapEntry(
                    key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
            {});

        Map<String, LMTopicViewData> topics = userActivityResponse.topics?.map(
                (key, value) => MapEntry(
                    key,
                    LMTopicViewDataConvertor.fromTopic(value,
                        widgets: widgets))) ??
            {};

        this.topics.addAll(topics);

        Map<String, LMUserViewData> users =
            userActivityResponse.users?.map((key, value) => MapEntry(
                    key,
                    LMUserViewDataConvertor.fromUser(
                      value,
                      topics: this.topics,
                      widgets: widgets,
                    ))) ??
                {};

        this.users.addAll(users);

        final isLastPage = userActivityResponse.activities == null ||
            userActivityResponse.activities!.length < 10;
        if (isLastPage) {
          _pagingController
              .appendLastPage(userActivityResponse.activities ?? []);
        } else {
          final nextPageKey = pageKey + 1;
          _pagingController.appendPage(
              userActivityResponse.activities!, nextPageKey);
        }
      } else {
        _pagingController.error = userActivityResponse.errorMessage;
      }
    } catch (error) {
      _pagingController.error = error;
    }
  }

  @override
  void dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _widgetBuilder.scaffold(
      source: widgetSource,
      backgroundColor: feedTheme.backgroundColor,
      appBar: widget.appBarBuilder?.call(
            context,
            _defAppBar(),
          ) ??
          _widgetBuilder.appBarBuilder(
            context,
            _defAppBar(),
          ),
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: min(
              screenSize.width, LMFeedCore.config.webConfiguration.maxWidth),
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.only(top: isDesktopWeb ? 10 : 0),
          child: PagedListView<int, UserActivityItem>(
            pagingController: _pagingController,
            builderDelegate: PagedChildBuilderDelegate<UserActivityItem>(
              noItemsFoundIndicatorBuilder: (context) {
                return _defNoPostWidget();
              },
              itemBuilder: (context, item, index) {
                final LMPostViewData postViewData =
                    LMFeedPostUtils.postViewDataFromActivity(
                  item,
                  widgets,
                  users,
                  topics,
                );
                final user = users[item.activityEntityData.uuid]!;

                LMFeedPostWidget postWidget =
                    defPostWidget(feedTheme, postViewData, item);

                return Container(
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                      borderRadius:
                          kIsWeb ? feedTheme.postStyle.borderRadius : null),
                  child: Column(
                    children: [
                      widget.postBuilder
                              ?.call(context, postWidget, postViewData) ??
                          _widgetBuilder.postWidgetBuilder(
                            context,
                            postWidget,
                            postViewData,
                            source: widgetSource,
                          ),
                      if (item.action == 7)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 18),
                          decoration: BoxDecoration(
                            color: feedTheme.container,
                            border: Border(
                              bottom: BorderSide(
                                width: 0.5,
                                color: feedTheme.onContainer.withOpacity(0.2),
                              ),
                            ),
                          ),
                          child: Column(
                            children: [
                              StatefulBuilder(
                                builder: (context, setCommentState) {
                                  final commentData = item.activityEntityData;
                                  final LMCommentViewData commentViewData =
                                      LMFeedPostUtils
                                          .commentViewDataFromActivity(
                                              commentData,
                                              users.map((key, value) =>
                                                  MapEntry(
                                                      key,
                                                      LMUserViewDataConvertor
                                                          .toUser(value))));

                                  commentData.menuItems?.removeWhere(
                                      (element) =>
                                          element.id ==
                                              LMFeedMenuAction
                                                  .commentReportId ||
                                          element.id ==
                                              LMFeedMenuAction.commentEditId);

                                  LMFeedCommentWidget commentWidget =
                                      defCommentTile(feedTheme, commentViewData,
                                          postViewData, user);

                                  return widget.commentBuilder?.call(context,
                                          commentWidget, postViewData) ??
                                      _widgetBuilder.commentBuilder(
                                          context, commentWidget, postViewData);
                                },
                              ),
                            ],
                          ),
                        ),
                      LikeMindsTheme.kVerticalPaddingLarge,
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Center _defNoPostWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: kAssetNoPostsIcon,
            style: LMFeedIconStyle(
              size: 130,
            ),
          ),
          LMFeedText(
              text:
                  'No ${LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural)} to show',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              )),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
      style: LMFeedAppBarStyle(
        backgroundColor: feedTheme.container,
        height: 50,
      ),
      title: const LMFeedText(
        text: 'Activity',
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  LMFeedPostWidget defPostWidget(
      LMFeedThemeData? feedTheme, LMPostViewData post, UserActivityItem item) {
    return LMFeedPostWidget(
      activityHeader: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width,
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 6.0,
                top: 12.0,
              ),
              child: RichText(
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                text: TextSpan(
                  children: LMFeedPostUtils.extractNotificationTags(
                      item.activityText, widget.uuid),
                ),
              ),
            ),
          ),
          Divider(
            color: feedTheme?.onContainer.withOpacity(0.05),
            thickness: 1,
          ),
          LikeMindsTheme.kVerticalPaddingMedium,
        ],
      ),
      post: post,
      topics: post.topics,
      user: users[post.uuid]!,
      isFeed: false,
      onTagTap: (String uuid) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid,
            context: context,
          ),
        );
      },
      onMediaTap: (int index) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: users[post.uuid]!,
              position: index,
            ),
          ),
        );

        LMFeedVideoProvider.instance.playCurrentVideo();
      },
      onPostTap: (context, post) {
        navigateToLMFeedPostDetailsScreen(post.id);
      },
      footer: _defFooterWidget(
        context,
        post,
        widgetSource,
        ValueNotifier<bool>(false),
      ),
      header: _defPostHeader(feedTheme, post),
      content: _defContentWidget(feedTheme, post),
      media: _defPostMedia(feedTheme, post),
      topicWidget: _defTopicWidget(feedTheme, post),
      style: feedTheme?.postStyle.copyWith(
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.zero,
      ),
    );
  }

  LMFeedPostTopic _defTopicWidget(
      LMFeedThemeData? feedTheme, LMPostViewData postViewData) {
    return LMFeedPostTopic(
      topics: postViewData.topics,
      post: postViewData,
      style: feedTheme?.topicStyle,
      onTopicTap: (context, topicViewData) =>
          LMFeedPostUtils.handlePostTopicTap(
              context, postViewData, topicViewData, widgetSource),
    );
  }

  LMFeedPostContent _defContentWidget(
      LMFeedThemeData? feedTheme, LMPostViewData post) {
    return LMFeedPostContent(
      onHeadingTap: () async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedPostDetailScreen(
              postId: post.id,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
      onTagTap: (String? uuid) {},
      style: feedTheme?.contentStyle,
      text: post.text,
      heading: post.heading,
    );
  }

  LMFeedPostFooter _defFooterWidget(BuildContext context, LMPostViewData post,
      LMFeedWidgetSource source, ValueNotifier<bool> postUploading) {
    final LMFeedPostFooter socialFeedFooter = LMFeedPostFooter(
      likeButton: defLikeButton(context, post),
      commentButton: defCommentButton(context, post),
      saveButton: defSaveButton(feedTheme, post),
      shareButton: defShareButton(feedTheme, post),
      repostButton: defRepostButton(
        context,
        post,
        source,
        postUploading,
      ),
      postFooterStyle: feedTheme.footerStyle,
      showRepostButton: !post.isRepost,
    );
    final qnaFeedFooter = LMFeedQnAPostFooter(
      postViewData: post,
      source: source,
      likeButton: defLikeButton(context, post),
      commentButton: defCommentButton(context, post),
      saveButton: defSaveButton(feedTheme, post),
      shareButton: defShareButton(feedTheme, post),
      repostButton: defRepostButton(
        context,
        post,
        source,
        postUploading,
      ),
    );

    return LMFeedCore.config.feedThemeType == LMFeedThemeType.qna
        ? qnaFeedFooter
        : socialFeedFooter;
  }

  LMFeedPostHeader _defPostHeader(
      LMFeedThemeData? feedTheme, LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: users[postViewData.uuid]!,
      isFeed: true,
      postViewData: postViewData,
      onProfileNameTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfileName, widgetSource),
      onProfilePictureTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, widgetSource),
      subText: LMFeedText(
        text:
            "@${users[postViewData.uuid]!.name.toLowerCase().split(' ').join()} ",
      ),
      menuBuilder: (menu) {
        return menu.copyWith(
          removeItemIds: {
            LMFeedMenuAction.postReportId,
            LMFeedMenuAction.postEditId
          },
          onMenuOpen: () {
            LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
              eventName: LMFeedAnalyticsKeys.postMenu,
              eventProperties: {
                'uuid': postViewData.user.sdkClientInfo.uuid,
                'post_id': postViewData.id,
                'topics': postViewData.topics.map((e) => e.name).toList(),
                'post_type':
                    LMFeedPostUtils.getPostType(postViewData.attachments),
              },
            ));
          },
          action: LMFeedMenuAction(
            onPostReport: () => handlePostReportAction(postViewData),
            onPostPin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
            onPostUnpin: () =>
                LMFeedPostUtils.handlePostPinAction(postViewData),
            onPostDelete: () {
              String postCreatorUUID = postViewData.user.sdkClientInfo.uuid;

              showDialog(
                context: context,
                builder: (childContext) => LMFeedDeleteConfirmationDialog(
                  title: 'Delete $postTitleFirstCap',
                  uuid: postCreatorUUID,
                  widgetSource: widgetSource,
                  content:
                      'Are you sure you want to delete this $postTitleSmallCap. This action can not be reversed.',
                  action: (String reason) async {
                    Navigator.of(childContext).pop();

                    String postType =
                        LMFeedPostUtils.getPostType(postViewData.attachments);

                    LMFeedPostBloc.instance.add(
                      LMFeedDeletePostEvent(
                        postId: postViewData.id,
                        reason: reason,
                        isRepost: postViewData.isRepost,
                        postType: postType,
                        userId: postCreatorUUID,
                        userState: isCm ? "CM" : "member",
                      ),
                    );
                  },
                  actionText: 'Delete',
                ),
              );
            },
            onPostEdit: () {
              // Mute all video controllers
              // to prevent video from playing in background
              // while editing the post
              LMFeedVideoProvider.instance.forcePauseAllControllers();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LMFeedEditPostScreen(
                    postId: postViewData.id,
                  ),
                ),
              );
            },
          ),
        );
      },
      postHeaderStyle: feedTheme?.headerStyle,
    );
  }

  LMFeedPostMedia _defPostMedia(
      LMFeedThemeData? feedTheme, LMPostViewData post) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      style: feedTheme?.mediaStyle,
      postId: post.id,
      pollBuilder: _widgetBuilder.pollWidgetBuilder,
      poll: _defPollWidget(post),
      onMediaTap: (int index) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();

        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: users[post.uuid]!,
              position: index,
            ),
          ),
        );

        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );
  }

  LMFeedPoll? _defPollWidget(LMPostViewData postViewData) {
    Map<String, bool> isVoteEditing = {"value": false};
    if (postViewData.attachments == null || postViewData.attachments!.isEmpty) {
      return null;
    }
    bool isPoll = false;
    postViewData.attachments?.forEach((element) {
      if (element.attachmentType == LMMediaType.poll) {
        isPoll = true;
      }
    });

    if (!isPoll) {
      return null;
    }

    LMAttachmentMetaViewData pollValue =
        postViewData.attachments!.first.attachmentMeta;
    LMAttachmentMetaViewData previousValue = pollValue.copyWith();
    List<String> selectedOptions = [];
    final ValueNotifier<bool> rebuildPollWidget = ValueNotifier(false);
    return LMFeedPoll(
      rebuildPollWidget: rebuildPollWidget,
      isVoteEditing: isVoteEditing["value"]!,
      selectedOption: selectedOptions,
      attachmentMeta: pollValue,
      style: feedTheme.mediaStyle.pollStyle ??
          LMFeedPollStyle.basic(
              primaryColor: feedTheme.primaryColor,
              containerColor: feedTheme.container),
      onEditVote: (pollData) {
        isVoteEditing["value"] = true;
        selectedOptions.clear();
        selectedOptions.addAll(pollData.options!
            .where((element) => element.isSelected)
            .map((e) => e.id)
            .toList());
        rebuildPollWidget.value = !rebuildPollWidget.value;
      },
      onOptionSelect: (optionData) async {
        // check if the user is a guest user
        if (LMFeedUserUtils.isGuestUser()) {
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
          return;
        }
        if (hasPollEnded(pollValue.expiryTime)) {
          LMFeedCore.showSnackBar(
            context,
            "Poll ended. Vote can not be submitted now.",
            LMFeedWidgetSource.universalFeed,
          );
          return;
        }
        if ((isPollSubmitted(pollValue.options ?? [])) &&
            !isVoteEditing["value"]!) return;
        if (!isMultiChoicePoll(
            pollValue.multiSelectNo, pollValue.multiSelectState)) {
          submitVote(
            context,
            pollValue,
            [optionData.id],
            postViewData.id,
            isVoteEditing,
            previousValue,
            rebuildPollWidget,
            LMFeedWidgetSource.universalFeed,
          );
        } else if (selectedOptions.contains(optionData.id)) {
          selectedOptions.remove(optionData.id);
        } else {
          selectedOptions.add(optionData.id);
        }
        rebuildPollWidget.value = !rebuildPollWidget.value;
      },
      showSubmitButton: isVoteEditing["value"]! || showSubmitButton(pollValue),
      showEditVoteButton: !isVoteEditing["value"]! &&
          !isInstantPoll(pollValue.pollType) &&
          !hasPollEnded(pollValue.expiryTime) &&
          isPollSubmitted(pollValue.options ?? []),
      showAddOptionButton: showAddOptionButton(pollValue),
      showTick: (option) {
        return showTick(
            pollValue, option, selectedOptions, isVoteEditing["value"]!);
      },
      isMultiChoicePoll: isMultiChoicePoll(
          pollValue.multiSelectNo, pollValue.multiSelectState),
      pollSelectionText: getPollSelectionText(
          pollValue.multiSelectState, pollValue.multiSelectNo),
      timeLeft: getTimeLeftInPoll(pollValue.expiryTime),
      onSameOptionAdded: () {
        LMFeedCore.showSnackBar(
          context,
          "Option already exists",
          LMFeedWidgetSource.universalFeed,
        );
      },
      onAddOptionSubmit: (option) async {
        await addOption(
          context,
          pollValue,
          option,
          postViewData.id,
          currentUser,
          rebuildPollWidget,
          LMFeedWidgetSource.universalFeed,
        );
        selectedOptions.clear();
        rebuildPollWidget.value = !rebuildPollWidget.value;
      },
      onSubtextTap: () {
        onVoteTextTap(
          context,
          pollValue,
          LMFeedWidgetSource.universalFeed,
        );
      },
      onVoteClick: (option) {
        onVoteTextTap(
          context,
          pollValue,
          LMFeedWidgetSource.universalFeed,
          option: option,
        );
      },
      onSubmit: (options) {
        submitVote(
          context,
          pollValue,
          options,
          postViewData.id,
          isVoteEditing,
          previousValue,
          rebuildPollWidget,
          LMFeedWidgetSource.universalFeed,
        );
      },
    );
  }

  LMFeedButton defLikeButton(
    BuildContext context,
    LMPostViewData postViewData,
  ) {
    final LMFeedButton socialLikeButton = LMFeedButton(
      isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
      isActive: postViewData.isLiked,
      text: LMFeedText(
          text: LMFeedPostUtils.getLikeCountTextWithCount(
              postViewData.likeCount)),
      style: feedTheme.footerStyle.likeButtonStyle,
      onTextTap: () {
        if (postViewData.likeCount == 0) {
          return;
        }
        // check if the user is a guest user
        if (LMFeedUserUtils.isGuestUser()) {
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
          return;
        }
        LMFeedVideoProvider.instance.pauseCurrentVideo();

        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedLikesScreen(
              postId: postViewData.id,
              widgetSource: source,
            ),
          ),
        )..then((value) => LMFeedVideoProvider.instance.playCurrentVideo());
      },
      onTap: () async {
        // check if the user is a guest user
        if (LMFeedUserUtils.isGuestUser()) {
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
          return;
        }
        LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
          actionType: postViewData.isLiked
              ? LMFeedPostActionType.unlike
              : LMFeedPostActionType.like,
          postId: postViewData.id,
        ));

        final likePostRequest =
            (LikePostRequestBuilder()..postId(postViewData.id)).build();

        final LikePostResponse response =
            await LMFeedCore.client.likePost(likePostRequest);

        if (!response.success) {
          LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
            actionType: postViewData.isLiked
                ? LMFeedPostActionType.unlike
                : LMFeedPostActionType.like,
            postId: postViewData.id,
          ));
        } else {
          LMFeedPostUtils.handlePostLikeTapEvent(
              postViewData, source, postViewData.isLiked);
        }
      },
    );

    String upVoteText = LMFeedPostUtils.getLikeTitle(
        LMFeedPluralizeWordAction.firstLetterCapitalSingular);
    if (postViewData.likeCount > 0) {
      upVoteText = "$upVoteText • " + postViewData.likeCount.toString();
    }
    LMFeedButton? qnaLikeButton = socialLikeButton.copyWith(
      text: socialLikeButton.text?.copyWith(
          text: upVoteText,
          style: LMFeedTextStyle.basic().copyWith(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: LikeMindsTheme.greyColor,
            ),
          )),
      style: socialLikeButton.style?.copyWith(
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
          color: feedTheme.backgroundColor,
        ),
        borderRadius: 100,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        margin: EdgeInsets.only(left: 16),
      ),
    );

    return LMFeedCore.config.feedThemeType == LMFeedThemeType.qna
        ? qnaLikeButton
        : socialLikeButton;
  }

  LMFeedButton defCommentButton(
    BuildContext context,
    LMPostViewData postViewData,
  ) {
    final LMFeedButton commentButton = LMFeedButton(
      text: LMFeedText(
        text: LMFeedPostUtils.getCommentCountTextWithCount(
            postViewData.commentCount),
      ),
      style: feedTheme.footerStyle.commentButtonStyle,
      onTap: () async {
        LMFeedPostUtils.handlePostCommentButtonTap(postViewData, source);
        if (source == LMFeedWidgetSource.postDetailScreen) {
          return;
        }
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedPostDetailScreen(
              postId: postViewData.id,
              openKeyboard: true,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
      onTextTap: () async {
        if (source == LMFeedWidgetSource.postDetailScreen) {
          return;
        }
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedPostDetailScreen(
              postId: postViewData.id,
              openKeyboard: true,
            ),
          ),
        );
        // await postVideoController.player.play();
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );
    final String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
        LMFeedPluralizeWordAction.firstLetterCapitalSingular);
    final String answerText = postViewData.commentCount == 0
        ? "$commentTitleFirstCapSingular "
        : postViewData.commentCount.toString();
    LMFeedButton? qnaCommentButton = commentButton.copyWith(
      text: commentButton.text?.copyWith(
        text: answerText,
      ),
    );

    return LMFeedCore.config.feedThemeType == LMFeedThemeType.qna
        ? qnaCommentButton
        : commentButton;
  }

  LMFeedButton defSaveButton(
          LMFeedThemeData? feedTheme, LMPostViewData postViewData) =>
      LMFeedButton(
        isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
        isActive: postViewData.isSaved,
        onTap: () async {
          // check if the user is a guest user
          if (LMFeedUserUtils.isGuestUser()) {
            LMFeedCore.instance.lmFeedCoreCallback?.loginRequired
                ?.call(context);
            return;
          }
          LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
              postId: postViewData.id,
              actionType: postViewData.isSaved
                  ? LMFeedPostActionType.unsaved
                  : LMFeedPostActionType.saved));
          postViewData.isSaved = !postViewData.isSaved;

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);
          if (!response.success) {
            LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
                postId: postViewData.id,
                actionType: postViewData.isSaved
                    ? LMFeedPostActionType.unsaved
                    : LMFeedPostActionType.saved));
            postViewData.isSaved = !postViewData.isSaved;
          } else {
            LMFeedPostUtils.handlePostSaveTapEvent(
                postViewData, postViewData.isSaved, widgetSource);
            LMFeedCore.showSnackBar(
              context,
              postViewData.isSaved
                  ? "$postTitleFirstCap Saved"
                  : "$postTitleFirstCap Unsaved",
              LMFeedWidgetSource.activityScreen,
            );
          }
        },
        style: feedTheme?.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(
          LMFeedThemeData? feedTheme, LMPostViewData postViewData) =>
      LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          // Fire analytics event for share button tap
          LMFeedPostUtils.handlerPostShareTapEvent(postViewData, widgetSource);

          LMFeedDeepLinkHandler().sharePost(postViewData.id);
        },
        style: feedTheme?.footerStyle.shareButtonStyle,
      );

  LMFeedCommentWidget defCommentTile(
      LMFeedThemeData? feedTheme,
      LMCommentViewData commentViewData,
      LMPostViewData postViewData,
      LMUserViewData userViewData) {
    commentViewData.menuItems = [];
    return LMFeedCommentWidget(
      user: userViewData,
      comment: commentViewData,
      menu: (menu) => menu.copyWith(
        removeItemIds: {},
        onMenuOpen: () {
          LMFeedCommentUtils.handleCommentMenuOpenTap(
              postViewData,
              commentViewData,
              widgetSource,
              commentViewData.level == 0
                  ? LMFeedAnalyticsKeys.commentMenu
                  : LMFeedAnalyticsKeys.replyMenu);
        },
      ),
      subtitleText: LMFeedText(
        text: "@${userViewData.name.toLowerCase().split(' ').join()} ",
      ),
      style: feedTheme?.commentStyle ??
          const LMFeedCommentStyle(
            padding: EdgeInsets.all(16.0),
            actionsPadding: EdgeInsets.only(left: 48),
          ),
      lmFeedMenuAction:
          defLMFeedMenuAction(feedTheme, commentViewData, postViewData),
      profilePicture: LMFeedProfilePicture(
        style: LMFeedProfilePictureStyle(
          size: 36,
          backgroundColor: feedTheme?.primaryColor,
        ),
        fallbackText: users[commentViewData.uuid]!.name,
        onTap: () => LMFeedCommentUtils.handleCommentProfileTap(
            context,
            postViewData,
            commentViewData,
            LMFeedAnalyticsKeys.commentProfilePicture,
            widgetSource),
        imageUrl: users[commentViewData.uuid]!.imageUrl,
      ),
      onProfileNameTap: () => LMFeedCommentUtils.handleCommentProfileTap(
          context,
          postViewData,
          commentViewData,
          LMFeedAnalyticsKeys.commentProfileName,
          widgetSource),
      likeButton:
          defCommentLikeButton(feedTheme, commentViewData, postViewData),
      replyButton:
          defCommentReplyButton(feedTheme, postViewData, commentViewData),
      showRepliesButton:
          defCommentShowRepliesButton(postViewData, commentViewData),
      onTagTap: (String uuid) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(uuid);
      },
    );
  }

  LMFeedButton defCommentShowRepliesButton(
      LMPostViewData postViewData, LMCommentViewData commentViewData) {
    return LMFeedButton(
      onTap: () => navigateToLMFeedPostDetailsScreen(postViewData.id),
      text: LMFeedText(
        text:
            "${commentViewData.repliesCount} ${commentViewData.repliesCount > 1 ? 'Replies' : 'Reply'}",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            color: feedTheme.primaryColor,
          ),
        ),
      ),
      style: feedTheme.commentStyle.showRepliesButtonStyle,
    );
  }

  LMFeedButton defCommentLikeButton(LMFeedThemeData? feedTheme,
      LMCommentViewData commentViewData, LMPostViewData postViewData) {
    LMFeedButton likeButton = LMFeedButton(
      style: feedTheme?.commentStyle.likeButtonStyle?.copyWith(
              showText: commentViewData.likesCount == 0 ? false : true) ??
          LMFeedButtonStyle(
            gap: 10.0,
            showText: commentViewData.likesCount == 0 ? false : true,
            icon: const LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.thumb_up_alt_outlined,
              style: LMFeedIconStyle(
                size: 20,
              ),
            ),
            activeIcon: LMFeedIcon(
              type: LMFeedIconType.icon,
              style: LMFeedIconStyle(
                color: feedTheme?.primaryColor,
                size: 20,
              ),
              icon: Icons.thumb_up_alt_rounded,
            ),
          ),
      text: LMFeedText(
        text: LMFeedPostUtils.getLikeCountTextWithCount(
            commentViewData.likesCount),
        style: const LMFeedTextStyle(
          textStyle: TextStyle(fontSize: 12),
        ),
      ),
      activeText: LMFeedText(
        text: LMFeedPostUtils.getLikeCountTextWithCount(
            commentViewData.likesCount),
        style: LMFeedTextStyle(
          textStyle: TextStyle(color: feedTheme?.primaryColor, fontSize: 12),
        ),
      ),
      onTap: () async {
        commentViewData.likesCount = commentViewData.isLiked
            ? commentViewData.likesCount - 1
            : commentViewData.likesCount + 1;
        commentViewData.isLiked = !commentViewData.isLiked;

        ToggleLikeCommentRequest toggleLikeCommentRequest =
            (ToggleLikeCommentRequestBuilder()
                  ..commentId(commentViewData.id)
                  ..postId(postViewData.id))
                .build();

        final ToggleLikeCommentResponse response = await LMFeedCore
            .instance.lmFeedClient
            .likeComment(toggleLikeCommentRequest);

        if (!response.success) {
          commentViewData.likesCount = commentViewData.isLiked
              ? commentViewData.likesCount - 1
              : commentViewData.likesCount + 1;
          commentViewData.isLiked = !commentViewData.isLiked;
        } else {
          LMFeedCommentUtils.handleCommentLikeTapEvent(postViewData,
              widgetSource, commentViewData, commentViewData.isLiked);
        }
      },
      isActive: commentViewData.isLiked,
    );
    return LMFeedCore.config.feedThemeType == LMFeedThemeType.qna
        ? likeButton.copyWith(
            style: likeButton.style?.copyWith(
              gap: likeButton.style?.showText == true ? 4 : 0,
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
            ),
          )
        : likeButton;
  }

  LMFeedButton defCommentReplyButton(LMFeedThemeData? feedTheme,
      LMPostViewData postViewData, LMCommentViewData commentViewData) {
    return LMFeedButton(
      style: feedTheme?.commentStyle.replyButtonStyle ??
          const LMFeedButtonStyle(
            gap: 10,
            icon: LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.comment_outlined,
              style: LMFeedIconStyle(
                size: 20,
              ),
            ),
          ),
      text: const LMFeedText(
        text: "Reply",
        style: LMFeedTextStyle(
            textStyle: TextStyle(
          fontSize: 12,
        )),
      ),
      onTap: () => navigateToLMFeedPostDetailsScreen(postViewData.id),
    );
  }

  LMFeedMenuAction defLMFeedMenuAction(LMFeedThemeData? feedTheme,
          LMCommentViewData commentViewData, LMPostViewData postViewData) =>
      LMFeedMenuAction(
        onCommentEdit: () {
          LMFeedCommentBloc.instance.add(
            LMFeedEditingCommentEvent(
              postId: postViewData.id,
              oldComment: commentViewData,
            ),
          );
        },
        onCommentDelete: () {
          String commentCreatorUUID = commentViewData.user.sdkClientInfo.uuid;

          showDialog(
            context: context,
            builder: (childContext) => LMFeedDeleteConfirmationDialog(
              title: 'Delete $commentTitleFirstCapSingular',
              uuid: commentCreatorUUID,
              widgetSource: widgetSource,
              content:
                  'Are you sure you want to delete this $commentTitleSmallCapSingular. This action can not be reversed.',
              action: (String reason) async {
                Navigator.of(childContext).pop();

                LMFeedAnalyticsBloc.instance.add(
                  LMFeedFireAnalyticsEvent(
                    eventName: LMFeedAnalyticsKeys.commentDeleted,
                    widgetSource: LMFeedWidgetSource.activityScreen,
                    eventProperties: {
                      "post_id": postViewData,
                      "comment_id": commentViewData.id,
                    },
                  ),
                );
              },
              actionText: 'Delete',
            ),
          );
        },
      );

  LMFeedButton defRepostButton(
          BuildContext context,
          LMPostViewData postViewData,
          LMFeedWidgetSource source,
          ValueNotifier<bool> postUploading) =>
      LMFeedButton(
        text: LMFeedText(
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color:
                  postViewData.isRepostedByUser ? feedTheme.primaryColor : null,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          text: postViewData.repostCount == 0
              ? ''
              : postViewData.repostCount.toString(),
        ),
        onTap: () {
          LMFeedDefaultWidgets.instance
              .handleCreatePost(context, source, postUploading);
        },
        style: feedTheme.footerStyle.repostButtonStyle?.copyWith(
            icon: feedTheme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedTheme.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? feedTheme.primaryColor
                          : null),
            ),
            activeIcon: feedTheme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedTheme.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? feedTheme.primaryColor
                          : null),
            )),
      );

  void navigateToLMFeedPostDetailsScreen(String postId) async {
    LMFeedVideoProvider.instance.pauseCurrentVideo();

    await Navigator.of(context, rootNavigator: true).push(
      MaterialPageRoute(
        builder: (context) => LMFeedPostDetailScreen(
          postId: postId,
          openKeyboard: true,
          commentBuilder: widget.commentBuilder,
          postBuilder: widget.postBuilder,
        ),
      ),
    );

    LMFeedVideoProvider.instance.playCurrentVideo();
  }

  void handlePostReportAction(LMPostViewData postViewData) {
    // check if the user is a guest user
    if (LMFeedUserUtils.isGuestUser()) {
      LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LMFeedReportScreen(
          entityId: postViewData.id,
          entityType: postEntityId,
          entityCreatorId: postViewData.user.uuid,
        ),
      ),
    );
  }
}
