import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/saved_post/saved_post_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';

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
  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
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
      bloc: LMFeedPostBloc.instance,
      listener: (context, state) {
        if (state is LMFeedNewPostErrorState) {
          postUploading.value = false;
          LMFeedCore.showSnackBar(
              LMFeedSnackBar(content: LMFeedText(text: state.errorMessage)));
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
          LMPostViewData? item = state.postData;
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
                updatePostViewData, state.actionType);
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
                            LMFeedCore.widgetUtility.postWidgetBuilder
                                .call(context, postWidget, item);
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
        VideoController? postVideoController = LMFeedVideoProvider.instance
            .getVideoController(
                LMFeedVideoProvider.instance.currentVisiblePostId ?? post.id);

        await postVideoController?.player.pause();
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
        await postVideoController?.player.play();
      },
      onPostTap: (context, post) async {
        VideoController? postVideoController = LMFeedVideoProvider.instance
            .getVideoController(
                LMFeedVideoProvider.instance.currentVisiblePostId ?? post.id);

        await postVideoController?.player.pause();
        // ignore: use_build_context_synchronously
        await Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedPostDetailScreen(
              postId: post.id,
              postBuilder: widget.postBuilder ??
                  LMFeedCore.widgetUtility.postWidgetBuilder,
            ),
          ),
        );
        await postVideoController?.player.play();
      },
      footer: _defFooterWidget(post),
      header: _defPostHeader(post),
      content: _defContentWidget(post),
      media: _defPostMedia(post),
      topicWidget: _defTopicWidget(post),
    );
  }

  LMFeedPostTopic _defTopicWidget(LMPostViewData post) {
    return LMFeedPostTopic(
      topics: post.topics,
      post: post,
      style: _theme.topicStyle,
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
      onProfileTap: () {
        LMFeedCore.instance.lmFeedClient
            .routeToProfile(postViewData.user.sdkClientInfo.uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: postViewData.user.sdkClientInfo.uuid,
            context: context,
          ),
        );
      },
      menu: LMFeedMenu(
        menuItems: postViewData.menuItems,
        removeItemIds: {postReportId, postEditId},
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
                title: 'Delete Post',
                uuid: postViewData.uuid,
                content:
                    'Are you sure you want to delete this post. This action can not be reversed.',
                action: (String reason) async {
                  Navigator.of(childContext).pop();

                  String postType =
                      LMFeedPostUtils.getPostType(postViewData.attachments);

                  LMFeedAnalyticsBloc.instance.add(
                    LMFeedFireAnalyticsEvent(
                      eventName: LMFeedAnalyticsKeys.postDeleted,
                      deprecatedEventName: LMFeedAnalyticsKeysDep.postDeleted,
                      eventProperties: {
                        "post_id": postViewData.id,
                        "post_type": postType,
                        "user_id": postViewData.uuid,
                        "user_state": isCm ? "CM" : "member",
                      },
                    ),
                  );

                  LMFeedPostBloc.instance.add(
                    LMFeedDeletePostEvent(
                      postId: postViewData.id,
                      reason: reason,
                      isRepost: postViewData.isRepost,
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
      carouselIndicatorBuilder:
          LMFeedCore.widgetUtility.postMediaCarouselIndicatorBuilder,
      onMediaTap: () async {
        VideoController? postVideoController = LMFeedVideoProvider.instance
            .getVideoController(
                LMFeedVideoProvider.instance.currentVisiblePostId ?? post.id);

        await postVideoController?.player.pause();
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
        await postVideoController?.player.play();
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
              ),
            ),
          );
        },
        onTap: () async {
          if (postViewData.isLiked) {
            postViewData.isLiked = false;
            postViewData.likeCount -= 1;
          } else {
            postViewData.isLiked = true;
            postViewData.likeCount += 1;
          }
          rebuildPostWidget.value = !rebuildPostWidget.value;

          final likePostRequest =
              (LikePostRequestBuilder()..postId(postViewData.id)).build();

          LMFeedAnalyticsBloc.instance.add(
            LMFeedFireAnalyticsEvent(
              eventName: LMFeedAnalyticsKeys.postLiked,
              deprecatedEventName: LMFeedAnalyticsKeysDep.postLiked,
              eventProperties: {'post_id': postViewData.id},
            ),
          );

          final LikePostResponse response =
              await LMFeedCore.client.likePost(likePostRequest);

          if (!response.success) {
            postViewData.isLiked = !postViewData.isLiked;
            postViewData.likeCount = postViewData.isLiked
                ? postViewData.likeCount + 1
                : postViewData.likeCount - 1;
            rebuildPostWidget.value = !rebuildPostWidget.value;
          }
        },
      );

  LMFeedButton defCommentButton(LMPostViewData post) => LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(post.commentCount),
        ),
        style: _theme.footerStyle.commentButtonStyle,
        onTap: () async {
          VideoController? postVideoController = LMFeedVideoProvider.instance
              .getVideoController(
                  LMFeedVideoProvider.instance.currentVisiblePostId ?? post.id);

          await postVideoController?.player.pause();
          // ignore: use_build_context_synchronously
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: post.id,
                openKeyboard: true,
                postBuilder: widget.postBuilder ??
                    LMFeedCore.widgetUtility.postWidgetBuilder,
              ),
            ),
          );
          await postVideoController?.player.play();
        },
        onTextTap: () async {
          VideoController? postVideoController = LMFeedVideoProvider.instance
              .getVideoController(
                  LMFeedVideoProvider.instance.currentVisiblePostId ?? post.id);

          await postVideoController?.player.pause();
          // ignore: use_build_context_synchronously
          await Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: post.id,
                openKeyboard: true,
                postBuilder: widget.postBuilder ??
                    LMFeedCore.widgetUtility.postWidgetBuilder,
              ),
            ),
          );
          await postVideoController?.player.play();
        },
      );

  LMFeedButton defSaveButton(LMPostViewData postViewData) => LMFeedButton(
        isActive: postViewData.isSaved,
        onTap: () async {
          postViewData.isSaved = !postViewData.isSaved;
          rebuildPostWidget.value = !rebuildPostWidget.value;
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
            postViewData.isSaved = !postViewData.isSaved;
            rebuildPostWidget.value = !rebuildPostWidget.value;
            LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
                postId: postViewData.id,
                actionType: postViewData.isSaved
                    ? LMFeedPostActionType.saved
                    : LMFeedPostActionType.unsaved));
          } else {
            LMFeedCore.showSnackBar(
              LMFeedSnackBar(
                content: LMFeedText(
                    text: postViewData.isSaved ? "Post Saved" : "Post Unsaved"),
              ),
            );
          }
        },
        style: _theme.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(LMPostViewData postViewData) => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
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
                  LMFeedAnalyticsBloc.instance.add(
                      const LMFeedFireAnalyticsEvent(
                          eventName: LMFeedAnalyticsKeys.postCreationStarted,
                          deprecatedEventName:
                              LMFeedAnalyticsKeysDep.postCreationStarted,
                          eventProperties: {}));

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
                      ),
                    ),
                  );
                } else {
                  LMFeedCore.showSnackBar(LMFeedSnackBar(
                      content:
                          LMFeedText(text: "A post is already uploading.")));
                }
              }
            : () => LMFeedCore.showSnackBar(LMFeedSnackBar(
                content: LMFeedText(
                    text: "You do not have permission to create a post."))),
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
              text: 'No posts to show',
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
              text: "Be the first one to post here",
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
                text: "Create Post",
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
                        LMFeedAnalyticsBloc.instance.add(
                            const LMFeedFireAnalyticsEvent(
                                eventName:
                                    LMFeedAnalyticsKeys.postCreationStarted,
                                deprecatedEventName:
                                    LMFeedAnalyticsKeysDep.postCreationStarted,
                                eventProperties: {}));

                        LMFeedVideoProvider.instance.forcePauseAllControllers();
                        // ignore: use_build_context_synchronously
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LMFeedComposeScreen(),
                          ),
                        );
                      } else {
                        LMFeedCore.showSnackBar(LMFeedSnackBar(
                            content: LMFeedText(
                                text: "A post is already uploading.")));
                      }
                    }
                  : () => LMFeedCore.showSnackBar(LMFeedSnackBar(
                      content: LMFeedText(
                          text:
                              "You do not have permission to create a post."))),
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
    postViewData.isPinned = !postViewData.isPinned;

    if (postViewData.isPinned) {
      int index = postViewData.menuItems
          .indexWhere((element) => element.id == postUnpinId);
      if (index != -1) {
        postViewData.menuItems[index].title = "Unpin This Post";
        postViewData.menuItems[index].id = postUnpinId;
      }
    } else {
      int index = postViewData.menuItems
          .indexWhere((element) => element.id == postPinId);

      if (index != -1) {
        postViewData.menuItems[index]
          ..title = "Pin This Post"
          ..id = postPinId;
      }
    }

    rebuildPostWidget.value = !rebuildPostWidget.value;

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        post: postViewData,
        actionType: LMFeedPostActionType.pinned,
        postId: postViewData.id));

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    if (!response.success) {
      postViewData.isPinned = !postViewData.isPinned;

      if (postViewData.isPinned) {
        int index = postViewData.menuItems
            .indexWhere((element) => element.id == postUnpinId);
        if (index != -1) {
          postViewData.menuItems[index]
            ..title = "Unpin This Post"
            ..id = postUnpinId;
        }
      } else {
        int index = postViewData.menuItems
            .indexWhere((element) => element.id == postPinId);

        if (index != -1) {
          postViewData.menuItems[index]
            ..title = "Pin This Post"
            ..id = postPinId;
        }
      }

      rebuildPostWidget.value = !rebuildPostWidget.value;

      LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        post: postViewData,
        actionType: LMFeedPostActionType.pinned,
        postId: postViewData.id,
      ));
    } else {
      String postType = LMFeedPostUtils.getPostType(postViewData.attachments);

      LMFeedAnalyticsBloc.instance.add(
        LMFeedFireAnalyticsEvent(
          eventName: postViewData.isPinned
              ? LMFeedAnalyticsKeys.postPinned
              : LMFeedAnalyticsKeys.postUnpinned,
          deprecatedEventName: postViewData.isPinned
              ? LMFeedAnalyticsKeysDep.postPinned
              : LMFeedAnalyticsKeysDep.postUnpinned,
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
