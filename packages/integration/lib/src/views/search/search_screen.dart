import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:async/async.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:overlay_support/overlay_support.dart';

class LMFeedSearchScreen extends StatefulWidget {
  const LMFeedSearchScreen({
    super.key,
    this.postBuilder,
    this.emptyFeedViewBuilder,
    this.firstPageLoaderBuilder,
    this.paginationLoaderBuilder,
    this.feedErrorViewBuilder,
    this.noNewPageWidgetBuilder,
  });

  // Builder for post item
  // {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;
  // {@macro context_widget_builder}
  // Builder for empty feed view
  final LMFeedContextWidgetBuilder? emptyFeedViewBuilder;
  // Builder for first page loader when no post are there
  final LMFeedContextWidgetBuilder? firstPageLoaderBuilder;
  // Builder for pagination loader when more post are there
  final LMFeedContextWidgetBuilder? paginationLoaderBuilder;
  // Builder for error view when error occurs
  final LMFeedContextWidgetBuilder? feedErrorViewBuilder;
  // Builder for widget when no more post are there
  final LMFeedContextWidgetBuilder? noNewPageWidgetBuilder;

  @override
  State<LMFeedSearchScreen> createState() => LMFeedSearchScreenState();
}

class LMFeedSearchScreenState extends State<LMFeedSearchScreen> {
  LMFeedThemeData theme = LMFeedCore.theme;
  LMFeedWidgetUtility widgetUtility = LMFeedWidgetUtility.instance;
  ValueNotifier<bool> showCancelIcon = ValueNotifier<bool>(false);
  TextEditingController searchController = TextEditingController();
  CancelableOperation? _debounceOperation;
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
  LMFeedSearchBloc searchBloc = LMFeedSearchBloc();
  ValueNotifier<bool> postUploading = ValueNotifier<bool>(false);
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier<bool>(false);
  final PagingController<int, LMPostViewData> _pagingController =
      PagingController(firstPageKey: 1);
  bool userPostingRights = true;
  int page = 1;
  int pageSize = 10;

  @override
  void initState() {
    super.initState();
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();
    addPageRequestListener();
    searchController.addListener(() {
      _onTextChanged(searchController.text);
    });
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  void addPageRequestListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        searchBloc.add(
          LMFeedGetSearchEvent(
            query: searchController.text,
            page: page,
            pageSize: pageSize,
            type: 'text',
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(LMFeedSearchLoadedState state) {
    if (state.posts.length < 10) {
      _pagingController.appendLastPage(state.posts);
    } else {
      _pagingController.appendPage(state.posts, page);
      page++;
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
    page = 1;
  }

  @override
  void dispose() {
    _debounceOperation?.cancel();
    super.dispose();
  }

  void _onTextChanged(String value) {
    _debounceOperation?.cancel();
    _debounceOperation = CancelableOperation.fromFuture(
      Future.delayed(const Duration(milliseconds: 500)),
    );
    _debounceOperation?.value.then((_) {
      handleCancelIcon(value);
      _fetchSearchResults(value);
    });
  }

  void handleCancelIcon(String value) {
    if (value.isNotEmpty) {
      if (!showCancelIcon.value) showCancelIcon.value = true;
    } else {
      if (showCancelIcon.value) showCancelIcon.value = false;
    }
  }

  Future<void> _fetchSearchResults(String value) async {
    if (value.isEmpty) return;
    clearPagingController();
    searchBloc.add(
      LMFeedGetSearchEvent(
        query: value,
        page: page,
        pageSize: pageSize,
        type: 'text',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return widgetUtility.scaffold(
      source: LMFeedWidgetSource.searchScreen,
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: theme.container,
        foregroundColor: theme.onContainer,
        title: TextField(
          controller: searchController,
          onChanged: _onTextChanged,
          decoration: InputDecoration(
            hintText: 'Search...',
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
        ),
        actions: [
          ValueListenableBuilder(
              valueListenable: showCancelIcon,
              builder: (context, value, child) {
                return value
                    ? IconButton(
                        icon: Icon(Icons.close),
                        onPressed: () {
                          searchController.clear();
                          clearPagingController();
                          refresh();
                          showCancelIcon.value = false;
                        },
                      )
                    : SizedBox();
              }),
        ],
      ),
      body: BlocListener(
        bloc: newPostBloc,
        listener: (context, state) {
          if (state is LMFeedNewPostErrorState) {
            postUploading.value = false;
            toast(
              state.errorMessage,
              duration: Toast.LENGTH_LONG,
            );
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

              postUploading.value = false;
              rebuildPostWidget.value = !rebuildPostWidget.value;
            } else {
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
          if (state is LMFeedPostUpdateState) {
            List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
            int index = feedRoomItemList
                    ?.indexWhere((element) => element.id == state.post?.id) ??
                -1;
            if (index != -1) {
              feedRoomItemList![index] = state.post!;
            }
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
                    ?.indexWhere((element) => element.id == state.post?.id) ??
                -1;
            if (index != -1) {
              feedRoomItemList?[index] = state.post!;
            }
            rebuildPostWidget.value = !rebuildPostWidget.value;
          }
        },
        child: BlocConsumer<LMFeedSearchBloc, LMFeedSearchState>(
          bloc: searchBloc,
          buildWhen: (previous, current) {
            if (current is LMFeedSearchPaginationLoadingState &&
                (previous is LMFeedSearchLoadingState ||
                    previous is LMFeedSearchLoadedState)) {
              return false;
            }
            return true;
          },
          listener: (context, state) {
            if (state is LMFeedSearchErrorState) {
              toast(state.message);
            }
            if (state is LMFeedSearchLoadedState) {
              // FocusScope.of(context).unfocus();
              updatePagingControllers(state);
            }
          },
          builder: (context, state) {
            if (state is LMFeedSearchLoadingState) {
              return widget.firstPageLoaderBuilder?.call(context) ??
                  const LMFeedLoader();
            }

            if (state is LMFeedSearchLoadedState) {
              return ValueListenableBuilder(
                  valueListenable: rebuildPostWidget,
                  builder: (context, _, __) {
                    return PagedListView(
                      pagingController: _pagingController,
                      builderDelegate:
                          PagedChildBuilderDelegate<LMPostViewData>(
                        noItemsFoundIndicatorBuilder: (context) {
                          return widget.emptyFeedViewBuilder?.call(context) ??
                              noPostInFeedWidget();
                        },
                        itemBuilder: (context, item, index) {
                          return Column(
                            children: [
                              const SizedBox(height: 2),
                              widget.postBuilder?.call(
                                    context,
                                    defPostWidget(item),
                                    item,
                                  ) ??
                                  widgetUtility.postWidgetBuilder(
                                      context, defPostWidget(item), item,
                                      source: LMFeedWidgetSource.searchScreen),
                            ],
                          );
                        },
                        firstPageProgressIndicatorBuilder: (context) =>
                            const SizedBox(),
                        newPageProgressIndicatorBuilder: (context) =>
                            const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        ),
                      ),
                    );
                  });
            }
            return SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget getLoaderThumbnail(LMMediaModel? media) {
    if (media != null) {
      if (media.mediaType == LMMediaType.image) {
        return Container(
          height: 50,
          width: 50,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: LMFeedImage(
            imageFile: media.mediaFile!,
            style: const LMFeedPostImageStyle(
              boxFit: BoxFit.contain,
            ),
          ),
        );
      } else if (media.mediaType == LMMediaType.document) {
        return const LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: kAssetNoPostsIcon,
          style: LMFeedIconStyle(
            color: Colors.red,
            size: 35,
            boxPadding: 0,
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  LMFeedPostWidget defPostWidget(LMPostViewData post) {
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
      style: theme.postStyle,
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
              postBuilder: widget.postBuilder,
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
      style: theme.topicStyle,
    );
  }

  LMFeedPostContent _defContentWidget(LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String? uuid) {},
      style: theme.contentStyle,
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
      postFooterStyle: theme.footerStyle,
      showRepostButton: !post.isRepost,
    );
  }

  LMFeedPostHeader _defPostHeader(LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: postViewData.user,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: theme.headerStyle,
      menuBuilder: (menu) {
        return menu.copyWith(
          removeItemIds: {postReportId, postEditId},
          action: LMFeedMenuAction(
            onPostUnpin: () => handlePostPinAction(postViewData),
            onPostPin: () => handlePostPinAction(postViewData),
            onPostDelete: () {
              showDialog(
                context: context,
                builder: (childContext) => LMFeedDeleteConfirmationDialog(
                  title: 'Delete Comment',
                  uuid: postViewData.uuid,
                  content:
                      'Are you sure you want to delete this post. This action can not be reversed.',
                  action: (String reason) async {
                    Navigator.of(childContext).pop();

                    LMFeedAnalyticsBloc.instance.add(
                      LMFeedFireAnalyticsEvent(
                        eventName: LMFeedAnalyticsKeys.postDeleted,
                        deprecatedEventName: LMFeedAnalyticsKeysDep.postDeleted,
                        eventProperties: {
                          "post_id": postViewData.id,
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
        );
      },
    );
  }

  LMFeedPostMedia _defPostMedia(
    LMPostViewData post,
  ) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      postId: post.id,
      style: theme.mediaStyle,
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
        style: theme.footerStyle.likeButtonStyle,
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
        style: theme.footerStyle.commentButtonStyle,
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
                postBuilder: widget.postBuilder,
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
                postBuilder: widget.postBuilder,
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
            post: postViewData,
            actionType: LMFeedPostActionType.saved,
            postId: postViewData.id,
          ));

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            postViewData.isSaved = !postViewData.isSaved;
            rebuildPostWidget.value = !rebuildPostWidget.value;
            LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
              post: postViewData,
              actionType: LMFeedPostActionType.saved,
              postId: postViewData.id,
            ));
          }
        },
        style: theme.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(LMPostViewData postViewData) => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          LMFeedDeepLinkHandler().sharePost(postViewData.id);
        },
        style: theme.footerStyle.shareButtonStyle,
      );

  LMFeedButton defRepostButton(LMPostViewData postViewData) => LMFeedButton(
        text: LMFeedText(
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: postViewData.isRepostedByUser ? theme.primaryColor : null,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          text: postViewData.repostCount == 0
              ? ''
              : postViewData.repostCount.toString(),
        ),
        onTap: () async {
          if (!postUploading.value) {
            LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
                eventName: LMFeedAnalyticsKeys.postCreationStarted,
                deprecatedEventName: LMFeedAnalyticsKeysDep.postCreationStarted,
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
            toast(
              'A post is already uploading.',
              duration: Toast.LENGTH_LONG,
            );
          }
        },
        style: theme.footerStyle.repostButtonStyle?.copyWith(
            icon: theme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: theme.footerStyle.repostButtonStyle?.icon?.style?.copyWith(
                  color: postViewData.isRepostedByUser
                      ? theme.primaryColor
                      : null),
            ),
            activeIcon: theme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: theme.footerStyle.repostButtonStyle?.icon?.style?.copyWith(
                  color: postViewData.isRepostedByUser
                      ? theme.primaryColor
                      : null),
            )),
      );

  Widget noPostInFeedWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.post_add,
              style: LMFeedIconStyle(
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            const LMFeedText(
              text: 'No posts to show',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const LMFeedText(
              text: "Be the first one to post here",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w300,
                  color: LikeMindsTheme.greyColor,
                ),
              ),
            ),
            const SizedBox(height: 28),
            LMFeedButton(
              style: LMFeedButtonStyle(
                icon: const LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.add,
                  style: LMFeedIconStyle(
                    size: 18,
                  ),
                ),
                borderRadius: 28,
                backgroundColor: theme.primaryColor,
                height: 44,
                width: 153,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                placement: LMFeedIconButtonPlacement.end,
              ),
              text: const LMFeedText(
                text: "Create Post",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
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

                        String? currentVisiblePost =
                            LMFeedVideoProvider.instance.currentVisiblePostId;

                        VideoController? postVideoController =
                            LMFeedVideoProvider.instance
                                .getVideoController(currentVisiblePost ?? '');

                        await postVideoController?.player.pause();
                        // ignore: use_build_context_synchronously
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LMFeedComposeScreen(),
                          ),
                        );
                        await postVideoController?.player.pause();
                      } else {
                        toast(
                          'A post is already uploading.',
                          duration: Toast.LENGTH_LONG,
                        );
                      }
                    }
                  : () => toast("You do not have permission to create a post"),
            ),
          ],
        ),
      );

  void handlePostPinAction(LMPostViewData postViewData) async {
    postViewData.isPinned = !postViewData.isPinned;
    rebuildPostWidget.value = !rebuildPostWidget.value;

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
      post: postViewData,
      actionType: LMFeedPostActionType.pinned,
      postId: postViewData.id,
    ));

    if (!response.success) {
      postViewData.isPinned = !postViewData.isPinned;
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
