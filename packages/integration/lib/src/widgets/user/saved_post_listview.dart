import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/saved_post/saved_post_bloc.dart';

class LMFeedSavedPostListView extends StatefulWidget {
  const LMFeedSavedPostListView({
    super.key,
    this.config,
    this.postBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
  });

  final LMFeedScreenConfig? config;
  // Builder for post item
  // {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;
  // {@macro context_widget_builder}
  // Builder for empty feed view
  final LMFeedContextWidgetBuilder? noItemsFoundIndicatorBuilder;
  // Builder for first page loader when no post are there
  final LMFeedContextWidgetBuilder? firstPageProgressIndicatorBuilder;
  // Builder for pagination loader when more post are there
  final LMFeedContextWidgetBuilder? newPageProgressIndicatorBuilder;
  // Builder for widget when no more post are there
  final LMFeedContextWidgetBuilder? noMoreItemsIndicatorBuilder;
  // Builder for error view while loading a new page
  final LMFeedContextWidgetBuilder? newPageErrorIndicatorBuilder;
  // Builder for error view while loading the first page
  final LMFeedContextWidgetBuilder? firstPageErrorIndicatorBuilder;

  @override
  State<LMFeedSavedPostListView> createState() =>
      _LMFeedSavedPostListViewState();
}

class _LMFeedSavedPostListViewState extends State<LMFeedSavedPostListView> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  LMFeedWidgetSource widgetSource = LMFeedWidgetSource.savedPostScreen;
  LMFeedThemeData _theme = LMFeedCore.theme;
  Size? screenSize;
  PagingController<int, LMPostViewData> _pagingController =
      PagingController<int, LMPostViewData>(
    firstPageKey: 1,
  );
  LMFeedSavedPostBloc _savePostBloc = LMFeedSavedPostBloc.instance;

  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier postUploading = ValueNotifier(false);
  bool userPostingRights = LMFeedUserUtils.checkPostCreationRights();
  LMFeedScreenConfig? config;
  LMFeedPostBloc postBloc = LMFeedPostBloc.instance;
  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();
  final LMFeedWidgetUtility _widgetUtility = LMFeedCore.widgetUtility;

  @override
  void initState() {
    super.initState();
    config = widget.config ?? LMFeedCore.config.feedScreenConfig;
    addPageRequestListener();
  }

  void addPageRequestListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _savePostBloc.add(
          LMFeedGetSavedPostEvent(
            page: pageKey,
            pageSize: 10,
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
  }

  void updatePagingControllers(LMFeedSavedPostLoadedState state) {
    if (state.posts.length < 10) {
      _pagingController.appendLastPage(state.posts);
    } else {
      _pagingController.appendPage(state.posts, state.page + 1);
    }
  }

  @override
  dispose() {
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    screenSize = MediaQuery.of(context).size;
    return BlocConsumer<LMFeedPostBloc, LMFeedPostState>(
      bloc: postBloc,
      listener: (context, state) {
        if (state is LMFeedNewPostErrorState) {
          postUploading.value = false;
          LMFeedCore.showSnackBar(context, state.errorMessage, widgetSource);
        }
        if (state is LMFeedNewPostUploadedState) {
          LMPostViewData? item = state.postData;
          int length = _pagingController.itemList?.length ?? 0;
          List<LMPostViewData> feedRoomItemList =
              _pagingController.itemList ?? [];
          for (int i = 0; i < feedRoomItemList.length; i++) {
            if (!feedRoomItemList[i].isPinned) {
              feedRoomItemList.insert(i, item);
              break;
            }
          }
          if (length == feedRoomItemList.length) {
            feedRoomItemList.add(item);
          }
          if (feedRoomItemList.isNotEmpty && feedRoomItemList.length > 10) {
            feedRoomItemList.removeLast();
            _pagingController.itemList = feedRoomItemList;
            postUploading.value = false;
            rebuildPostWidget.value = !rebuildPostWidget.value;
          } else {
            _pagingController.itemList = feedRoomItemList;
            postUploading.value = false;
            rebuildPostWidget.value = !rebuildPostWidget.value;
          }
        }
        if (state is LMFeedPostDeletedState) {
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          feedRoomItemList?.removeWhere((item) => item.id == state.postId);
          _pagingController.itemList = feedRoomItemList;
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }
        if (state is LMFeedEditPostUploadedState) {
          LMPostViewData? item = state.postData.copyWith();
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          int index = feedRoomItemList
                  ?.indexWhere((element) => element.id == item.id) ??
              -1;
          if (index != -1) {
            feedRoomItemList?[index] = item;
          }
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }

        if (state is LMFeedPostUpdateState) {
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          int index = feedRoomItemList
                  ?.indexWhere((element) => element.id == state.postId) ??
              -1;
          if (index != -1) {
            LMPostViewData updatePostViewData = feedRoomItemList![index];
            updatePostViewData = LMFeedPostUtils.updatePostData(
                postViewData: updatePostViewData, actionType: state.actionType);
          }
          _pagingController.itemList = feedRoomItemList;
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }
      },
      builder: (context, state) {
        return BlocListener<LMFeedSavedPostBloc, LMFeedSavedPostState>(
          bloc: _savePostBloc,
          listener: (context, state) {
            if (state is LMFeedSavedPostLoadedState) {
              updatePagingControllers(state);
            }
            if (state is LMFeedSavedPostErrorState) {
              debugPrint(state.stackTrace.toString());
              _pagingController.error = state.errorMessage;
            }
          },
          child: ValueListenableBuilder(
              valueListenable: rebuildPostWidget,
              builder: (context, _, __) {
                return RefreshIndicator.adaptive(
                  onRefresh: () async {
                    refresh();
                    clearPagingController();
                  },
                  child: PagedListView<int, LMPostViewData>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<LMPostViewData>(
                      firstPageProgressIndicatorBuilder: (context) {
                        return widget.firstPageProgressIndicatorBuilder
                                ?.call(context) ??
                            const Center(
                              child: LMFeedLoader(),
                            );
                      },
                      newPageProgressIndicatorBuilder: (context) {
                        return widget.newPageProgressIndicatorBuilder
                                ?.call(context) ??
                            const Center(
                              child: LMFeedLoader(),
                            );
                      },
                      newPageErrorIndicatorBuilder: (context) {
                        return widget.newPageErrorIndicatorBuilder
                                ?.call(context) ??
                            Center(
                              child: LMFeedText(
                                text: _pagingController.error.toString(),
                              ),
                            );
                      },
                      itemBuilder: (context, item, index) {
                        LMFeedPostWidget postWidget =
                            defPostWidget(_theme, item);
                        return widget.postBuilder
                                ?.call(context, postWidget, item) ??
                            _widgetUtility.postWidgetBuilder.call(
                                context, postWidget, item,
                                source: widgetSource);
                      },
                    ),
                  ),
                );
              }),
        );
      },
    );
  }

  LMFeedPostWidget defPostWidget(
      LMFeedThemeData? feedThemeData, LMPostViewData post) {
    return LMFeedPostWidget(
      post: post,
      topics: post.topics,
      user: post.user,
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
      onMediaTap: () async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: post.user,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
      onPostTap: (context, post) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedPostDetailScreen(
              postId: post.id,
              postBuilder:
                  widget.postBuilder ?? _widgetUtility.postWidgetBuilder,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
      footer: _defFooterWidget(post),
      header: _defPostHeader(post),
      content: _defContentWidget(post),
      media: _defPostMedia(post),
      topicWidget: _defTopicWidget(post),
    );
  }

  LMFeedPostTopic _defTopicWidget(LMPostViewData postViewData) {
    return LMFeedPostTopic(
      topics: postViewData.topics,
      post: postViewData,
      style: _theme.topicStyle,
      onTopicTap: (context, topicViewData) =>
          LMFeedPostUtils.handlePostTopicTap(
              context, postViewData, topicViewData, widgetSource),
    );
  }

  LMFeedPostContent _defContentWidget(LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String? uuid) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid ?? post.uuid,
            context: context,
          ),
        );
      },
      style: _theme.contentStyle,
      text: post.text,
      heading: post.heading,
    );
  }

  LMFeedPostFooter _defFooterWidget(LMPostViewData post) {
    return LMFeedPostFooter(
      likeButton: defLikeButton(post),
      commentButton: defCommentButton(post),
      saveButton: defSaveButton(post),
      shareButton: defShareButton(post),
      repostButton: defRepostButton(post),
      postFooterStyle: _theme.footerStyle,
      showRepostButton: !post.isRepost,
    );
  }

  LMFeedPostHeader _defPostHeader(LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: postViewData.user,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: _theme.headerStyle,
      onProfileNameTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, widgetSource),
      onProfilePictureTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, widgetSource),
      menu: LMFeedMenu(
        menuItems: postViewData.menuItems,
        removeItemIds: {postReportId, postEditId},
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
          onPostUnpin: () => handlePostPinAction(postViewData),
          onPostPin: () => handlePostPinAction(postViewData),
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
          onPostDelete: () {
            showDialog(
              context: context,
              builder: (childContext) => LMFeedDeleteConfirmationDialog(
                title: 'Delete $postTitleFirstCap',
                uuid: postViewData.uuid,
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
                      userId: postViewData.user.sdkClientInfo.uuid,
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
    LMPostViewData post,
  ) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      postId: post.id,
      style: _theme.mediaStyle,
      pollBuilder: _widgetUtility.pollWidgetBuilder,
      poll: _defPollWidget(post),
      carouselIndicatorBuilder:
          _widgetUtility.postMediaCarouselIndicatorBuilder,
      onMediaTap: () async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: post.user,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );
  }

  LMFeedPoll _defPollWidget(LMPostViewData postViewData) {
    Map<String, bool> isVoteEditing = {"value": false};
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
      style: _theme.mediaStyle.pollStyle ?? LMFeedPollStyle.basic(),
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
        debugPrint("this is selected");
        if (hasPollEnded(pollValue.expiryTime!)) {
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
            pollValue.multiSelectNo!, pollValue.multiSelectState!)) {
          submitVote(
            context,
            pollValue,
            [optionData.id],
            postViewData.id,
            isVoteEditing,
            previousValue,
            rebuildPostWidget,
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
          !hasPollEnded(pollValue.expiryTime!) &&
          isPollSubmitted(pollValue.options ?? []),
      showAddOptionButton: showAddOptionButton(pollValue),
      showTick: (option) {
        return showTick(
            pollValue, option, selectedOptions, isVoteEditing["value"]!);
      },
      isMultiChoicePoll: isMultiChoicePoll(
          pollValue.multiSelectNo!, pollValue.multiSelectState!),
      pollSelectionText: getPollSelectionText(
          pollValue.multiSelectState, pollValue.multiSelectNo),
      timeLeft: getTimeLeftInPoll(pollValue.expiryTime!),
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
          rebuildPostWidget,
          LMFeedWidgetSource.universalFeed,
        );
        selectedOptions.clear();
        rebuildPollWidget.value = !rebuildPollWidget.value;
      },
    );
  }

  LMFeedButton defLikeButton(LMPostViewData postViewData) => LMFeedButton(
        isActive: postViewData.isLiked,
        text: LMFeedText(
            text: LMFeedPostUtils.getLikeCountTextWithCount(
                postViewData.likeCount)),
        style: _theme.footerStyle.likeButtonStyle,
        onTextTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedLikesScreen(
                postId: postViewData.id,
                widgetSource: widgetSource,
              ),
            ),
          );
        },
        onTap: () async {
          postBloc.add(LMFeedUpdatePostEvent(
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
            postBloc.add(LMFeedUpdatePostEvent(
              actionType: postViewData.isLiked
                  ? LMFeedPostActionType.unlike
                  : LMFeedPostActionType.like,
              postId: postViewData.id,
            ));
          } else {
            LMFeedPostUtils.handlePostLikeTapEvent(
                postViewData, widgetSource, postViewData.isLiked);
          }
        },
      );

  LMFeedButton defCommentButton(LMPostViewData post) => LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(post.commentCount),
        ),
        style: _theme.footerStyle.commentButtonStyle,
        onTap: () async {
          // Handle analytics event for comment button tap
          LMFeedPostUtils.handlePostCommentButtonTap(post, widgetSource);

          LMFeedVideoProvider.instance.pauseCurrentVideo();
          // ignore: use_build_context_synchronously
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: post.id,
                openKeyboard: true,
                postBuilder:
                    widget.postBuilder ?? _widgetUtility.postWidgetBuilder,
              ),
            ),
          );
          LMFeedVideoProvider.instance.playCurrentVideo();
        },
        onTextTap: () async {
          LMFeedVideoProvider.instance.pauseCurrentVideo();
          // ignore: use_build_context_synchronously
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: post.id,
                openKeyboard: true,
                postBuilder:
                    widget.postBuilder ?? _widgetUtility.postWidgetBuilder,
              ),
            ),
          );
          LMFeedVideoProvider.instance.playCurrentVideo();
        },
      );

  LMFeedButton defSaveButton(LMPostViewData postViewData) => LMFeedButton(
        isActive: postViewData.isSaved,
        onTap: () async {
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
                postViewData, postViewData.isSaved, widgetSource);
            LMFeedCore.showSnackBar(
              context,
              postViewData.isSaved
                  ? "$postTitleFirstCap Saved"
                  : "$postTitleFirstCap Unsaved",
              widgetSource,
            );
          }
        },
        style: _theme.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(LMPostViewData postViewData) => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          // Fire analytics event for share button tap
          LMFeedPostUtils.handlerPostShareTapEvent(postViewData, widgetSource);

          LMFeedDeepLinkHandler().sharePost(postViewData.id);
        },
        style: _theme.footerStyle.shareButtonStyle,
      );

  LMFeedButton defRepostButton(LMPostViewData postViewData) => LMFeedButton(
        text: LMFeedText(
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: postViewData.isRepostedByUser ? _theme.primaryColor : null,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          text: postViewData.repostCount == 0
              ? ''
              : postViewData.repostCount.toString(),
        ),
        onTap: userPostingRights
            ? () async {
                if (!postUploading.value) {
                  LMFeedVideoProvider.instance.forcePauseAllControllers();
                  // ignore: use_build_context_synchronously
                  LMAttachmentViewData attachmentViewData =
                      (LMAttachmentViewDataBuilder()
                            ..attachmentType(8)
                            ..attachmentMeta((LMAttachmentMetaViewDataBuilder()
                                  ..repost(postViewData))
                                .build()))
                          .build();
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LMFeedComposeScreen(
                        attachments: [attachmentViewData],
                        widgetSource: LMFeedWidgetSource.savedPostScreen,
                      ),
                    ),
                  );
                } else {
                  LMFeedCore.showSnackBar(
                    context,
                    "A $postTitleSmallCap is already uploading.",
                    widgetSource,
                  );
                }
              }
            : () => LMFeedCore.showSnackBar(
                  context,
                  "You do not have permission to create a $postTitleSmallCap.",
                  widgetSource,
                ),
        style: _theme.footerStyle.repostButtonStyle?.copyWith(
            icon: _theme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: _theme.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? _theme.primaryColor
                          : null),
            ),
            activeIcon: _theme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: _theme.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? _theme.primaryColor
                          : null),
            )),
      );

  Widget noPostInFeedWidget(LMFeedThemeData? feedThemeData) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.post_add,
              style: LMFeedIconStyle(
                size: 48,
                color: feedThemeData?.onContainer,
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
                  color: feedThemeData?.onContainer,
                ),
              ),
            ),
            const SizedBox(height: 12),
            LMFeedText(
              text: "Be the first one to create a $postTitleSmallCap here",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: feedThemeData?.onContainer,
                ),
              ),
            ),
            const SizedBox(height: 28),
            LMFeedButton(
              style: LMFeedButtonStyle(
                icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.add,
                  style: LMFeedIconStyle(
                    size: 18,
                    color: feedThemeData?.onPrimary,
                  ),
                ),
                borderRadius: 28,
                backgroundColor: feedThemeData?.primaryColor,
                height: 44,
                width: 160,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                placement: LMFeedIconButtonPlacement.end,
              ),
              text: LMFeedText(
                text: "Create $postTitleFirstCap",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: feedThemeData?.onPrimary,
                  ),
                ),
              ),
              onTap: userPostingRights
                  ? () async {
                      if (!postUploading.value) {
                        LMFeedVideoProvider.instance.forcePauseAllControllers();
                        // ignore: use_build_context_synchronously
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LMFeedComposeScreen(
                              widgetSource: LMFeedWidgetSource.savedPostScreen,
                            ),
                          ),
                        );
                      } else {
                        LMFeedCore.showSnackBar(
                            context,
                            "A $postTitleSmallCap is already uploading.",
                            widgetSource);
                      }
                    }
                  : () => LMFeedCore.showSnackBar(
                        context,
                        "You do not have permission to create a $postTitleSmallCap.",
                        widgetSource,
                      ),
            ),
          ],
        ),
      );

  Future<dynamic> handlePostReportAction(LMPostViewData postViewData) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      elevation: 10,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      backgroundColor: _theme.container,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) => LMFeedReportBottomSheet(
        entityId: postViewData.id,
        entityType: 5,
        entityCreatorId: postViewData.uuid,
      ),
    );
  }

  void handlePostPinAction(LMPostViewData postViewData) async {
    if (postViewData.isPinned) {
      int index = postViewData.menuItems
          .indexWhere((element) => element.id == postPinId);
      if (index != -1) {
        postViewData.menuItems[index].title = "Unpin This $postTitleFirstCap";
        postViewData.menuItems[index].id = postUnpinId;
      }
    } else {
      int index = postViewData.menuItems
          .indexWhere((element) => element.id == postUnpinId);

      if (index != -1) {
        postViewData.menuItems[index]
          ..title = "Pin This $postTitleFirstCap"
          ..id = postPinId;
      }
    }

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        post: postViewData,
        actionType: LMFeedPostActionType.pinned,
        postId: postViewData.id));

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    if (!response.success) {
      LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        post: postViewData,
        actionType: LMFeedPostActionType.pinned,
        postId: postViewData.id,
      ));

      if (postViewData.isPinned) {
        int index = postViewData.menuItems
            .indexWhere((element) => element.id == postPinId);
        if (index != -1) {
          postViewData.menuItems[index]
            ..title = "Unpin This $postTitleFirstCap"
            ..id = postUnpinId;
        }
      } else {
        int index = postViewData.menuItems
            .indexWhere((element) => element.id == postUnpinId);

        if (index != -1) {
          postViewData.menuItems[index]
            ..title = "Pin This $postTitleFirstCap"
            ..id = postPinId;
        }
      }
    } else {
      String postType = LMFeedPostUtils.getPostType(postViewData.attachments);

      LMFeedAnalyticsBloc.instance.add(
        LMFeedFireAnalyticsEvent(
          eventName: postViewData.isPinned
              ? LMFeedAnalyticsKeys.postPinned
              : LMFeedAnalyticsKeys.postUnpinned,
          widgetSource: widgetSource,
          eventProperties: {
            'created_by_id': postViewData.uuid,
            'post_id': postViewData.id,
            'post_type': postType,
          },
        ),
      );
    }
  }
}
