import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedDefaultWidgets {
  // create a singleton class
  LMFeedDefaultWidgets._();
  static final instance = LMFeedDefaultWidgets._();

  final feedThemeData = LMFeedCore.theme;
  final _feedBloc = LMFeedUniversalBloc.instance;
  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  final _widgetsBuilder = LMFeedCore.widgetUtility;
  final newPostBloc = LMFeedPostBloc.instance;
  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();
  final userPostingRights = LMFeedUserUtils.checkPostCreationRights();
  bool postUploading = false;

  void listenPostUploading() {
    newPostBloc.stream.listen((state) {
      if (state is LMFeedNewPostUploadingState ||
          state is LMFeedEditPostUploadingState) {
        postUploading = true;
      } else if (state is LMFeedNewPostUploadedState ||
          state is LMFeedEditPostUploadedState ||
          state is LMFeedNewPostErrorState ||
          state is LMFeedEditPostErrorState ||
          state is LMFeedMediaUploadErrorState) {
        postUploading = false;
      }
    });
  }
//TODO: find a workaround to listen for state
// final listen = listenPostUploading();

// Get the post title in first letter capital singular form
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
// Get the post title in all small singular form
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

// Get the post title in all small singular form
  String postTitleSmallCapPlural =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural);

// Get the comment title in first letter capital plural form
  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
// Get the comment title in all small plural form
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
// Get the comment title in first letter capital singular form
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
// Get the comment title in all small singular form
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  LMFeedPostWidget defPostWidget(
    BuildContext context,
    LMFeedThemeData? feedThemeData,
    LMPostViewData post,
    LMFeedWidgetSource source,
    ValueNotifier<bool> postUploading,
  ) {
    final LMFeedPostWidget postWidget = LMFeedPostWidget(
      post: post,
      topics: post.topics,
      user: _feedBloc.users[post.uuid]!,
      isFeed: false,
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
              user: _feedBloc.users[post.uuid]!,
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
      footer: _defFooterWidget(context, post, source, postUploading),
      header: _defPostHeader(context, post, source),
      content: _defContentWidget(post, context),
      media: _defPostMedia(context, post),
      topicWidget: _defTopicWidget(post, source),
    );

    return LMFeedCore.config.feedThemeType == LMFeedThemeType.qna
        ? postWidget.copyWith(
            footerBuilder: (context, footer, postViewData) {
              return LMFeedQnAPostFooter(
                footer: footer,
                postViewData: postViewData,
                source: source,
              );
            },
          )
        : postWidget;
  }

  LMFeedPostTopic _defTopicWidget(
      LMPostViewData postViewData, LMFeedWidgetSource source) {
    return LMFeedPostTopic(
      topics: postViewData.topics,
      post: postViewData,
      style: feedThemeData.topicStyle,
      onTopicTap: (context, topicViewData) =>
          LMFeedPostUtils.handlePostTopicTap(
              context, postViewData, topicViewData, source),
    );
  }

  LMFeedPostContent _defContentWidget(
      LMPostViewData post, BuildContext context) {
    return LMFeedPostContent(
      onTagTap: (String? uuid) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid ?? post.uuid,
            context: context,
          ),
        );
      },
      style: feedThemeData.contentStyle,
      text: post.text,
      heading: post.heading,
    );
  }

  LMFeedPostFooter _defFooterWidget(BuildContext context, LMPostViewData post,
      LMFeedWidgetSource source, ValueNotifier<bool> postUploading) {
    return LMFeedPostFooter(
      likeButton: defLikeButton(context, post, source),
      commentButton: defCommentButton(context, post, source),
      saveButton: defSaveButton(post, context, source),
      shareButton: defShareButton(post, source),
      repostButton: defRepostButton(
        context,
        post,
        source,
        postUploading,
      ),
      postFooterStyle: feedThemeData.footerStyle,
      showRepostButton: !post.isRepost,
    );
  }

  LMFeedPostHeader _defPostHeader(BuildContext context,
      LMPostViewData postViewData, LMFeedWidgetSource source) {
    return LMFeedPostHeader(
      user: _feedBloc.users[postViewData.uuid]!,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: feedThemeData.headerStyle,
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
                title: 'Delete $postTitleFirstCap',
                uuid: postCreatorUUID,
                widgetSource: source,
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
        ),
      ),
    );
  }

  LMFeedPostMedia _defPostMedia(
    BuildContext context,
    LMPostViewData post,
  ) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      postId: post.id,
      style: feedThemeData.mediaStyle,
      carouselIndicatorBuilder:
          LMFeedCore.widgetUtility.postMediaCarouselIndicatorBuilder,
      imageBuilder: _widgetsBuilder.imageBuilder,
      videoBuilder: _widgetsBuilder.videoBuilder,
      pollBuilder: _widgetsBuilder.pollWidgetBuilder,
      poll: _defPollWidget(post, context),
      onMediaTap: (int index) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: _feedBloc.users[post.uuid]!,
              position: index,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );
  }

  LMFeedPoll? _defPollWidget(
      LMPostViewData postViewData, BuildContext context) {
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
      style: feedThemeData.mediaStyle.pollStyle ??
          LMFeedPollStyle.basic(
              primaryColor: feedThemeData.primaryColor,
              containerColor: feedThemeData.container),
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
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call();
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

  LMFeedButton defLikeButton(BuildContext context, LMPostViewData postViewData,
          LMFeedWidgetSource source) =>
      LMFeedButton(
        isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
        isActive: postViewData.isLiked,
        text: LMFeedText(
            text: LMFeedPostUtils.getLikeCountTextWithCount(
                postViewData.likeCount)),
        style: feedThemeData.footerStyle.likeButtonStyle,
        onTextTap: () {
          if (postViewData.likeCount == 0) {
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
            LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call();
            return;
          }
          newPostBloc.add(LMFeedUpdatePostEvent(
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
            newPostBloc.add(LMFeedUpdatePostEvent(
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

  LMFeedButton defCommentButton(BuildContext context,
          LMPostViewData postViewData, LMFeedWidgetSource source) =>
      LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(
              postViewData.commentCount),
        ),
        style: feedThemeData.footerStyle.commentButtonStyle,
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

  LMFeedButton defSaveButton(LMPostViewData postViewData, BuildContext context,
          LMFeedWidgetSource source) =>
      LMFeedButton(
        isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
        isActive: postViewData.isSaved,
        onTap: () async {
          // check if the user is a guest user
          if (LMFeedUserUtils.isGuestUser()) {
            LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call();
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
                  ? "$postTitleFirstCap Saved"
                  : "$postTitleFirstCap Unsaved",
              source,
            );
          }
        },
        style: feedThemeData.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(
          LMPostViewData postViewData, LMFeedWidgetSource source) =>
      LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          // Fire analytics event for share button tap
          LMFeedPostUtils.handlerPostShareTapEvent(postViewData, source);

          LMFeedDeepLinkHandler().sharePost(postViewData.id);
        },
        style: feedThemeData.footerStyle.shareButtonStyle,
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
                  ? feedThemeData.primaryColor
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
        style: feedThemeData.footerStyle.repostButtonStyle?.copyWith(
            icon: feedThemeData.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedThemeData.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? feedThemeData.primaryColor
                          : null),
            ),
            activeIcon:
                feedThemeData.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedThemeData.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? feedThemeData.primaryColor
                          : null),
            )),
      );

  // function to handle the create post button
  Future<void> handleCreatePost(
    BuildContext context,
    LMFeedWidgetSource source,
    ValueNotifier<bool> postUploading, {
    int? feedRoomId,
  }) async {
    // check if the user have posting rights
    if (userPostingRights) {
      // check if the user is a guest user
      if (LMFeedUserUtils.isGuestUser()) {
        LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call();
        return;
      }
      // check if a post failed to upload
      // and stored in the cache as temporary post
      final value = LMFeedCore.client.getTemporaryPost();
      if (value.success) {
        LMFeedCore.showSnackBar(
          context,
          'A $postTitleSmallCap is already uploading.',
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
          'A $postTitleSmallCap is already uploading.',
          source,
        );
      }
    } else {
      LMFeedCore.showSnackBar(
        context,
        "You do not have permission to create a $postTitleSmallCap",
        source,
      );
    }
  }

  void handlePostReportAction(
      LMPostViewData postViewData, BuildContext context) {
    // check if the user is a guest user
    if (LMFeedUserUtils.isGuestUser()) {
      LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call();
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
