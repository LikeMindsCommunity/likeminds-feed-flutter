import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_default_widgets}
/// Default Widgets for the Feed
/// used to create the default widgets for the feed
/// {@endtemplate}
class LMFeedDefaultWidgets {
  // create a singleton class
  LMFeedDefaultWidgets._();

  /// The instance of the [LMFeedDefaultWidgets]
  static final instance = LMFeedDefaultWidgets._();

  final _feedThemeData = LMFeedCore.theme;
  final _feedBloc = LMFeedUniversalBloc.instance;
  bool _isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  final _widgetsBuilder = LMFeedCore.config.widgetBuilderDelegate;
  final _newPostBloc = LMFeedPostBloc.instance;
  LMUserViewData? _currentUser = LMFeedLocalPreference.instance.fetchUserData();
  final _userPostingRights = LMFeedUserUtils.checkPostCreationRights();

// Get the post title in first letter capital singular form
  String _postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
// Get the post title in all small singular form
  String _postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  /// Function to create the default post widget
  LMFeedPostWidget defPostWidget(
    BuildContext context,
    LMFeedThemeData? feedThemeData,
    LMPostViewData post,
    LMFeedWidgetSource source,
    ValueNotifier<bool> postUploading, {
    VoidCallback? onCommentTap,
  }) {
    return LMFeedPostWidget(
      post: post,
      topics: post.topics,
      user: post.user,
      isFeed: source != LMFeedWidgetSource.postDetailScreen,
      onTagTap: (String uuid) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid,
            context: context,
          ),
        );
      },
      disposeVideoPlayerOnInActive: () {
        LMFeedVideoProvider.instance.clearPostController(post.id);
      },
      style: feedThemeData?.postStyle,
      onMediaTap: (int index) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: post.user,
              position: index,
            ),
          ),
        )..then((value) => LMFeedVideoProvider.instance.playCurrentVideo());
        // await postVideoController.player.play();
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
      onPostTap: (context, post) async {
        // check if the source is post detail screen
        if (source == LMFeedWidgetSource.postDetailScreen) {
          return;
        }
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
      footer: _defFooterWidget(
        context,
        post,
        source,
        postUploading,
        onCommentTap: onCommentTap,
      ),
      header: _defPostHeader(context, post, source),
      content: _defContentWidget(post, context, source),
      media: _defPostMedia(context, post, source),
      topicWidget: _defTopicWidget(post, source),
    );
  }

  LMFeedPostTopic _defTopicWidget(
      LMPostViewData postViewData, LMFeedWidgetSource source) {
    return LMFeedPostTopic(
      topics: postViewData.topics,
      post: postViewData,
      style: _feedThemeData.topicStyle,
      onTopicTap: (context, topicViewData) =>
          LMFeedPostUtils.handlePostTopicTap(
              context, postViewData, topicViewData, source),
    );
  }

  LMFeedPostContent _defContentWidget(
      LMPostViewData post, BuildContext context, LMFeedWidgetSource source) {
    return LMFeedPostContent(
      onHeadingTap: () async {
        // check if the source is post detail screen
        if (source == LMFeedWidgetSource.postDetailScreen) {
          return;
        }
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
      onTagTap: (String? uuid) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid ?? post.uuid,
            context: context,
          ),
        );
      },
      style: _feedThemeData.contentStyle,
      text: post.text,
      heading: post.heading,
      // check if the source is post detail screen
      // to show the full content
      expanded: source == LMFeedWidgetSource.postDetailScreen,
    );
  }

  LMFeedPostFooter _defFooterWidget(BuildContext context, LMPostViewData post,
      LMFeedWidgetSource source, ValueNotifier<bool> postUploading,
      {VoidCallback? onCommentTap}) {
    final LMFeedPostFooter socialFeedFooter = LMFeedPostFooter(
      likeButton: defLikeButton(context, post, source),
      commentButton:
          defCommentButton(context, post, source, onTap: onCommentTap),
      saveButton: defSaveButton(post, context, source),
      shareButton: defShareButton(post, source),
      repostButton: defRepostButton(
        context,
        post,
        source,
        postUploading,
      ),
      postFooterStyle: _feedThemeData.footerStyle,
      showRepostButton: !post.isRepost,
    );
    final qnaFeedFooter = LMFeedQnAPostFooter(
      postViewData: post,
      source: source,
      likeButton: defLikeButton(context, post, source),
      commentButton:
          defCommentButton(context, post, source, onTap: onCommentTap),
      saveButton: defSaveButton(post, context, source),
      shareButton: defShareButton(post, source),
      repostButton: defRepostButton(
        context,
        post,
        source,
        postUploading,
      ),
    );

    return LMFeedCore.config.feedThemeType == LMFeedThemeType.qnaFeed
        ? qnaFeedFooter
        : socialFeedFooter;
  }

  LMFeedPostHeader _defPostHeader(BuildContext context,
      LMPostViewData postViewData, LMFeedWidgetSource source) {
    return LMFeedPostHeader(
      user: postViewData.user,
      // check if the source is not the post detail screen
      isFeed: source != LMFeedWidgetSource.postDetailScreen,
      postViewData: postViewData,
      postHeaderStyle: _feedThemeData.headerStyle,
      createdAt: LMFeedText(
        text: LMFeedTimeAgo.instance.format(postViewData.createdAt),
      ),
      onProfileNameTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, source),
      onProfilePictureTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, source),
      menu: LMFeedMenu(
        menuItems: postViewData.menuItems,
        removeItemIds: {},
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
          onPostReport: () => handlePostReportAction(postViewData, context),
          onPostUnpin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
          onPostPin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
          onPostDelete: () {
            String postCreatorUUID = postViewData.user.sdkClientInfo.uuid;

            showDialog(
              context: context,
              builder: (childContext) => LMFeedDeleteConfirmationDialog(
                title: 'Delete $_postTitleFirstCap',
                uuid: postCreatorUUID,
                widgetSource: source,
                content:
                    'Are you sure you want to delete this $_postTitleSmallCap. This action can not be reversed.',
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
                      userState: _isCm ? "CM" : "member",
                    ),
                  );
                  // navigate back to the previous screen
                  // if the source is post detail screen
                  if (source == LMFeedWidgetSource.postDetailScreen) {
                    Navigator.of(context).pop();
                  }
                },
                actionText: 'Delete',
              ),
            );
          },
        ),
      ),
    );
  }

  LMFeedPostMedia _defPostMedia(
    BuildContext context,
    LMPostViewData post,
    LMFeedWidgetSource source,
  ) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      postId: post.id,
      style: _feedThemeData.mediaStyle,
      carouselIndicatorBuilder: LMFeedCore
          .config.widgetBuilderDelegate.postMediaCarouselIndicatorBuilder,
      imageBuilder: _widgetsBuilder.imageBuilder,
      videoBuilder: _widgetsBuilder.videoBuilder,
      pollBuilder: _widgetsBuilder.pollWidgetBuilder,
      poll: _defPollWidget(post, context, source),
      onMediaTap: (int index) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: post.user,
              position: index,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );
  }

  LMFeedPoll? _defPollWidget(LMPostViewData postViewData, BuildContext context,
      LMFeedWidgetSource source) {
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
      style: _feedThemeData.mediaStyle.pollStyle ??
          LMFeedPollStyle.basic(
              primaryColor: _feedThemeData.primaryColor,
              containerColor: _feedThemeData.container),
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
            source,
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
          _currentUser,
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

  /// Function to create the default like button
  LMFeedButton defLikeButton(BuildContext context, LMPostViewData postViewData,
      LMFeedWidgetSource source) {
    final LMFeedButton socialLikeButton = LMFeedButton(
      isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
      isActive: postViewData.isLiked,
      text: LMFeedText(
          text: LMFeedPostUtils.getLikeCountTextWithCount(
              postViewData.likeCount)),
      style: _feedThemeData.footerStyle.likeButtonStyle,
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
        _newPostBloc.add(LMFeedUpdatePostEvent(
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
          _newPostBloc.add(LMFeedUpdatePostEvent(
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
          color: _feedThemeData.backgroundColor,
        ),
        borderRadius: 100,
        padding: EdgeInsets.symmetric(
          horizontal: 10,
        ),
        margin: EdgeInsets.only(left: 16),
      ),
    );

    return LMFeedCore.config.feedThemeType == LMFeedThemeType.qnaFeed
        ? qnaLikeButton
        : socialLikeButton;
  }

  /// Function to create the default comment button
  LMFeedButton defCommentButton(BuildContext context,
      LMPostViewData postViewData, LMFeedWidgetSource source,
      {VoidCallback? onTap}) {
    final LMFeedButton commentButton = LMFeedButton(
      text: LMFeedText(
        text: LMFeedPostUtils.getCommentCountTextWithCount(
            postViewData.commentCount),
      ),
      style: _feedThemeData.footerStyle.commentButtonStyle,
      onTap: () async {
        onTap?.call();
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
        onTap?.call();
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

    return LMFeedCore.config.feedThemeType == LMFeedThemeType.qnaFeed
        ? qnaCommentButton
        : commentButton;
  }

  /// Function to create the default save button
  LMFeedButton defSaveButton(LMPostViewData postViewData, BuildContext context,
          LMFeedWidgetSource source) =>
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
                  ? LMFeedPostActionType.saved
                  : LMFeedPostActionType.unsaved));

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
                postId: postViewData.id,
                actionType: postViewData.isSaved
                    ? LMFeedPostActionType.saved
                    : LMFeedPostActionType.unsaved));
          } else {
            LMFeedPostUtils.handlePostSaveTapEvent(
                postViewData, postViewData.isSaved, source);
            LMFeedCore.showSnackBar(
              context,
              postViewData.isSaved
                  ? "$_postTitleFirstCap Saved"
                  : "$_postTitleFirstCap Unsaved",
              source,
            );
          }
        },
        style: _feedThemeData.footerStyle.saveButtonStyle,
      );

  /// Function to create the default share button
  LMFeedButton defShareButton(
          LMPostViewData postViewData, LMFeedWidgetSource source) =>
      LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          // Fire analytics event for share button tap
          LMFeedPostUtils.handlerPostShareTapEvent(postViewData, source);

          LMFeedDeepLinkHandler().sharePost(postViewData.id);
        },
        style: _feedThemeData.footerStyle.shareButtonStyle,
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
              color: postViewData.isRepostedByUser
                  ? _feedThemeData.primaryColor
                  : null,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          text: postViewData.repostCount == 0
              ? ''
              : postViewData.repostCount.toString(),
        ),
        onTap: () {
          handleCreatePost(context, source, postUploading);
        },
        style: _feedThemeData.footerStyle.repostButtonStyle?.copyWith(
            icon: _feedThemeData.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: _feedThemeData.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? _feedThemeData.primaryColor
                          : null),
            ),
            activeIcon:
                _feedThemeData.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: _feedThemeData.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? _feedThemeData.primaryColor
                          : null),
            )),
      );

  /// function to handle the create post button
  Future<void> handleCreatePost(
    BuildContext context,
    LMFeedWidgetSource source,
    ValueNotifier<bool> postUploading, {
    int? feedRoomId,
  }) async {
    // check if the user have posting rights
    if (_userPostingRights) {
      // check if the user is a guest user
      if (LMFeedUserUtils.isGuestUser()) {
        LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
        return;
      }
      // check if a post failed to upload
      // and stored in the cache as temporary post
      final value = LMFeedCore.client.getTemporaryPost();
      if (value.success) {
        LMFeedCore.showSnackBar(
          context,
          'A $_postTitleSmallCap is already uploading.',
          source,
        );
        return;
      }
      // if no post is uploading then navigate to the compose screen
      if (!postUploading.value) {
        LMFeedVideoProvider.instance.forcePauseAllControllers();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedComposeScreen(
              widgetSource: LMFeedWidgetSource.personalisedFeed,
              feedroomId: feedRoomId,
            ),
          ),
        );
      } else {
        LMFeedCore.showSnackBar(
          context,
          'A $_postTitleSmallCap is already uploading.',
          source,
        );
      }
    } else {
      LMFeedCore.showSnackBar(
        context,
        "You do not have permission to create a $_postTitleSmallCap",
        source,
      );
    }
  }

  /// Function to handle the post report action
  void handlePostReportAction(
      LMPostViewData postViewData, BuildContext context) {
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
