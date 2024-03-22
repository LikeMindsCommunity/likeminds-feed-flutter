import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/user_created_comment/user_created_comment_bloc.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:overlay_support/overlay_support.dart';

class LMFeedUserCreatedCommentListView extends StatefulWidget {
  const LMFeedUserCreatedCommentListView({
    Key? key,
    required this.uuid,
    this.postBuilder,
    this.emptyFeedViewBuilder,
    this.firstPageLoaderBuilder,
    this.paginationLoaderBuilder,
    this.feedErrorViewBuilder,
    this.noNewPageWidgetBuilder,
  }) : super(key: key);

  // The user id for which the user feed is to be shown
  final String uuid;
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
  State<LMFeedUserCreatedCommentListView> createState() =>
      _LMFeedUserCreatedCommentListViewState();
}

class _LMFeedUserCreatedCommentListViewState
    extends State<LMFeedUserCreatedCommentListView> {
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  static const int pageSize = 10;
  final PagingController<int, LMCommentViewData> _pagingController =
      PagingController(firstPageKey: 1);
  bool userPostingRights = LMFeedUserUtils.checkPostCreationRights();
  LMFeedThemeData? feedThemeData;
  final ValueNotifier postUploading = ValueNotifier(false);
  final LMFeedUserCreatedCommentBloc _userCreatedCommentBloc =
      LMFeedUserCreatedCommentBloc();
  final Map<String, LMPostViewData> _posts = {};
  LMFeedPostBloc lmFeedPostBloc = LMFeedPostBloc.instance;

  @override
  void initState() {
    super.initState();
    addPageRequestListener();
  }

  void addPageRequestListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _userCreatedCommentBloc.add(
          LMFeedUserCreatedCommentGetEvent(
            uuid: widget.uuid,
            page: pageKey,
            pageSize: pageSize,
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(UserCreatedCommentLoadedState state) {
    if (state.comments.length < 10) {
      _pagingController.appendLastPage(state.comments);
      _posts.addAll(state.posts);
    } else {
      _pagingController.appendPage(state.comments, state.page + 1);
      _posts.addAll(state.posts);
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
  }

  @override
  Widget build(BuildContext context) {
    feedThemeData = LMFeedCore.theme;
    return BlocListener<LMFeedPostBloc, LMFeedPostState>(
        bloc: lmFeedPostBloc,
        listener: (context, state) {
          if (state is LMFeedEditPostUploadedState) {
            _posts[state.postData.id] = state.postData;

            rebuildPostWidget.value = !rebuildPostWidget.value;
          }
          if (state is LMFeedPostUpdateState) {
            LMPostViewData? post = _posts[state.postId];

            if (post != null) {
              post = LMFeedPostUtils.updatePostData(post, state.actionType);
              _posts[state.postId] = post;
              rebuildPostWidget.value = !rebuildPostWidget.value;
            }
          }
        },
        child: ValueListenableBuilder(
            valueListenable: rebuildPostWidget,
            builder: (context, _, __) {
              return BlocListener<LMFeedUserCreatedCommentBloc,
                  LMFeedUserCreatedCommentState>(
                bloc: _userCreatedCommentBloc,
                listener: (context, state) {
                  if (state is UserCreatedCommentLoadedState) {
                    updatePagingControllers(state);
                  }
                },
                child: PagedSliverList(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<LMCommentViewData>(
                    noItemsFoundIndicatorBuilder: (context) {
                      return widget.emptyFeedViewBuilder?.call(context) ??
                          noPostInFeedWidget();
                    },
                    itemBuilder: (context, item, index) {
                      _posts[item.postId]?.topComments = [item];
                      LMFeedPostWidget postWidget = defPostWidget(
                        feedThemeData,
                        _posts[item.postId]!,
                      );
                      return Column(
                        children: [
                          const SizedBox(height: 2),
                          widget.postBuilder?.call(
                                  context, postWidget, _posts[item.postId]!) ??
                              LMFeedCore.widgetUtility.postWidgetBuilder.call(
                                  context, postWidget, _posts[item.postId]!),
                          const Divider(),
                        ],
                      );
                    },
                    firstPageProgressIndicatorBuilder: (context) {
                      return widget.firstPageLoaderBuilder?.call(context) ??
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: LMFeedLoader()),
                          );
                    },
                    newPageProgressIndicatorBuilder: (context) {
                      return widget.paginationLoaderBuilder?.call(context) ??
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: LMFeedLoader()),
                          );
                    },
                  ),
                ),
              );
            }));
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
        return LMFeedIcon(
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

  LMFeedPostContent _defContentWidget(LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String? uuid) {},
      style: feedThemeData?.contentStyle,
      text: post.text,
      heading: post.heading,
    );
  }

  LMFeedPostMedia _defPostMedia(
    LMPostViewData post,
  ) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      postId: post.id,
      style: feedThemeData?.mediaStyle,
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

  LMFeedPostTopic _defTopicWidget(LMPostViewData post) {
    return LMFeedPostTopic(
      topics: post.topics,
      post: post,
      style: feedThemeData?.topicStyle,
    );
  }

  LMFeedPostFooter _defFooterWidget(LMPostViewData post) {
    return LMFeedPostFooter(
      likeButton: defLikeButton(post),
      commentButton: defCommentButton(post),
      saveButton: defSaveButton(post),
      shareButton: defShareButton(post),
      repostButton: defRepostButton(post),
      postFooterStyle: feedThemeData?.footerStyle,
      showRepostButton: !post.isRepost,
    );
  }

  LMFeedPostHeader _defPostHeader(LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: postViewData.user,
      isFeed: true,
      postViewData: postViewData,
      onProfileTap: () {
        LMFeedCore.instance.lmFeedClient.routeToProfile(
          postViewData.user.sdkClientInfo.uuid,
        );
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: postViewData.user.sdkClientInfo.uuid,
            context: context,
          ),
        );
      },
      postHeaderStyle: feedThemeData?.headerStyle,
      menuBuilder: (menu) {
        return menu.copyWith(
          removeItemIds: {postReportId, postEditId},
          action: LMFeedMenuAction(
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

                    lmFeedPostBloc.add(
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

  LMFeedButton defLikeButton(LMPostViewData postViewData) => LMFeedButton(
        isActive: postViewData.isLiked,
        text: LMFeedText(
            text: LMFeedPostUtils.getLikeCountTextWithCount(
                postViewData.likeCount)),
        style: feedThemeData?.footerStyle.likeButtonStyle,
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
          lmFeedPostBloc.add(LMFeedUpdatePostEvent(
            actionType: postViewData.isLiked
                ? LMFeedPostActionType.unlike
                : LMFeedPostActionType.like,
            postId: postViewData.id,
          ));

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
            lmFeedPostBloc.add(LMFeedUpdatePostEvent(
              actionType: postViewData.isLiked
                  ? LMFeedPostActionType.unlike
                  : LMFeedPostActionType.like,
              postId: postViewData.id,
            ));
          }
        },
      );

  LMFeedButton defCommentButton(LMPostViewData post) => LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(post.commentCount),
        ),
        style: feedThemeData?.footerStyle.commentButtonStyle,
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
          lmFeedPostBloc.add(LMFeedUpdatePostEvent(
            post: postViewData,
            actionType: postViewData.isSaved
                ? LMFeedPostActionType.unsaved
                : LMFeedPostActionType.saved,
            postId: postViewData.id,
          ));

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            lmFeedPostBloc.add(LMFeedUpdatePostEvent(
              post: postViewData,
              actionType: postViewData.isSaved
                  ? LMFeedPostActionType.unsaved
                  : LMFeedPostActionType.saved,
              postId: postViewData.id,
            ));
          } else {
            LMFeedCore.showSnackBar(
              LMFeedSnackBar(
                content: LMFeedText(
                    text: postViewData.isSaved ? "Post Saved" : "Post Unsaved"),
              ),
            );
          }
        },
        style: feedThemeData?.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(LMPostViewData postViewData) => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          LMFeedDeepLinkHandler().sharePost(postViewData.id);
        },
        style: feedThemeData?.footerStyle.shareButtonStyle,
      );

  LMFeedButton defRepostButton(LMPostViewData postViewData) => LMFeedButton(
        text: LMFeedText(
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: postViewData.isRepostedByUser
                  ? feedThemeData?.primaryColor
                  : null,
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
        style: feedThemeData?.footerStyle.repostButtonStyle?.copyWith(
            icon: feedThemeData?.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedThemeData?.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? feedThemeData?.primaryColor
                          : null),
            ),
            activeIcon:
                feedThemeData?.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedThemeData?.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? feedThemeData?.primaryColor
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
              text: 'No Replies to show',
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
                icon: LMFeedIcon(
                  type: LMFeedIconType.icon,
                  icon: Icons.add,
                  style: LMFeedIconStyle(
                    color: feedThemeData?.onPrimary,
                    size: 18,
                  ),
                ),
                borderRadius: 28,
                backgroundColor: feedThemeData?.primaryColor,
                height: 44,
                width: 153,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                placement: LMFeedIconButtonPlacement.end,
              ),
              text: LMFeedText(
                text: "Create Post",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    color: feedThemeData?.onPrimary,
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
    lmFeedPostBloc.add(LMFeedUpdatePostEvent(
      post: postViewData,
      actionType: postViewData.isPinned
          ? LMFeedPostActionType.unpinned
          : LMFeedPostActionType.pinned,
      postId: postViewData.id,
    ));

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    if (!response.success) {
      lmFeedPostBloc.add(LMFeedUpdatePostEvent(
        post: postViewData,
        actionType: postViewData.isPinned
            ? LMFeedPostActionType.unpinned
            : LMFeedPostActionType.pinned,
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

class LMFeedPostCustomContent extends LMFeedPostContent {
  LMFeedPostCustomContent({
    required this.comment,
    required this.post,
    this.feedThemeData,
  });
  final LMCommentViewData comment;
  final LMPostViewData post;
  final LMFeedThemeData? feedThemeData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LMFeedPostContent(
          onTagTap: (String? uuid) {},
          style: feedThemeData?.contentStyle,
          text: post.text,
          heading: post.heading,
        ),
        _defCommentBuilder(context),
      ],
    );
  }

  Widget _defCommentBuilder(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 50,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: feedThemeData?.backgroundColor,
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
                LMFeedText(
                  text: comment.user.name,
                  style: const LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      // color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                LMFeedExpandableText(
                  LMFeedTaggingHelper.convertRouteToTag(comment.text),
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
    );
  }
}
