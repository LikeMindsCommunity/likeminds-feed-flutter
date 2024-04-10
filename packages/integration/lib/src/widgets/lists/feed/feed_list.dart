// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedList extends StatefulWidget {
  final List<String> selectedTopicIds;
  final PagingController<int, LMPostViewData> pagingController;
  final int pageSize;

  final LMFeedPostWidgetBuilder? postBuilder;

  const LMFeedList({
    super.key,
    required this.selectedTopicIds,
    required this.pagingController,
    this.pageSize = 20,
    this.postBuilder,
  });

  @override
  State<LMFeedList> createState() => _LMFeedListState();
}

class _LMFeedListState extends State<LMFeedList> {
  LMFeedThemeData feedThemeData = LMFeedTheme.instance.theme;
  LMFeedBloc _feedBloc = LMFeedBloc.instance;
  final ValueNotifier postUploading = ValueNotifier(false);

  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  bool right = true;
  bool isCm = LMFeedUserUtils
      .checkIfCurrentUserIsCM(); // whether the logged in user is a community manager or not

  LMUserViewData currentUser = LMFeedLocalPreference.instance.fetchUserData()!;

  bool userPostingRights = true;

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
        return LMFeedTheme
                .instance.theme.mediaStyle.documentStyle.documentIcon ??
            LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.picture_as_pdf,
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

  @override
  void initState() {
    super.initState();
    Bloc.observer = LMFeedBlocObserver();
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();
    _addPaginationListener();
  }

  @override
  void didUpdateWidget(covariant LMFeedList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!listEquals(widget.selectedTopicIds, oldWidget.selectedTopicIds)) {
      widget.pagingController.refresh();
    }
  }

  void _addPaginationListener() {
    widget.pagingController.addPageRequestListener(
      (pageKey) {
        _feedBloc.add(
          LMFeedGetUniversalFeedEvent(
            pageKey: pageKey,
            topicsIds: widget.selectedTopicIds,
          ),
        );
      },
    );
  }

  void refresh() => widget.pagingController.refresh();

  void updatePagingControllers(LMFeedState? state) {
    if (state is LMFeedUniversalFeedLoadedState) {
      List<LMPostViewData> listOfPosts = state.posts;

      _feedBloc.users.addAll(state.users);
      _feedBloc.topics.addAll(state.topics);
      _feedBloc.widgets.addAll(state.widgets);

      if (state.posts.length < 10) {
        widget.pagingController.appendLastPage(listOfPosts);
      } else {
        widget.pagingController.appendPage(listOfPosts, state.pageKey + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LMFeedBloc, LMFeedState>(
      bloc: _feedBloc,
      listener: (context, LMFeedState state) => updatePagingControllers(state),
      child: ValueListenableBuilder(
        valueListenable: rebuildPostWidget,
        builder: (context, _, __) {
          return PagedSliverList<int, LMPostViewData>(
            pagingController: widget.pagingController,
            builderDelegate: PagedChildBuilderDelegate<LMPostViewData>(
              itemBuilder: (context, item, index) {
                return LMFeedCore.widgetUtility.postWidgetBuilder(
                    context, defPostWidget(context, feedThemeData, item), item);
              },
            ),
          );
        },
      ),
    );
  }

  LMFeedPostWidget defPostWidget(BuildContext context,
      LMFeedThemeData? feedThemeData, LMPostViewData post) {
    return LMFeedPostWidget(
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
      onMediaTap: () async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: _feedBloc.users[post.uuid]!,
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
              postBuilder: widget.postBuilder,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
      footer: _defFooterWidget(context, post),
      header: _defPostHeader(context, post),
      content: _defContentWidget(post),
      media: _defPostMedia(context, post),
      topicWidget: _defTopicWidget(post),
    );
  }

  LMFeedPostTopic _defTopicWidget(LMPostViewData post) {
    return LMFeedPostTopic(
      topics: post.topics,
      post: post,
      style: feedThemeData.topicStyle,
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
      style: feedThemeData.contentStyle,
      text: post.text,
      heading: post.heading,
    );
  }

  LMFeedPostFooter _defFooterWidget(BuildContext context, LMPostViewData post) {
    return LMFeedPostFooter(
      likeButton: defLikeButton(context, post),
      commentButton: defCommentButton(context, post),
      saveButton: defSaveButton(post),
      shareButton: defShareButton(post),
      repostButton: defRepostButton(context, post),
      postFooterStyle: feedThemeData.footerStyle,
      showRepostButton: !post.isRepost,
    );
  }

  LMFeedPostHeader _defPostHeader(
      BuildContext context, LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: _feedBloc.users[postViewData.uuid]!,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: feedThemeData.headerStyle,
      onProfileTap: () {
        LMFeedCore.instance.lmFeedClient.routeToProfile(
            _feedBloc.users[postViewData.uuid]!.sdkClientInfo.uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: _feedBloc.users[postViewData.uuid]!.sdkClientInfo.uuid,
            context: context,
          ),
        );
      },
      menu: LMFeedMenu(
        menuItems: postViewData.menuItems,
        removeItemIds: {postReportId, postEditId},
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
          onPostUnpin: () => handlePostPinAction(postViewData),
          onPostPin: () => handlePostPinAction(postViewData),
          onPostDelete: () {
            String postCreatorUUID = postViewData.user.sdkClientInfo.uuid;

            showDialog(
              context: context,
              builder: (childContext) => LMFeedDeleteConfirmationDialog(
                title: 'Delete Post',
                uuid: postCreatorUUID,
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
                      widgetSource: LMFeedWidgetSource.universalFeed,
                      eventProperties: {
                        "post_id": postViewData.id,
                        "post_type": postType,
                        "user_id": currentUser.sdkClientInfo.uuid,
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
    BuildContext context,
    LMPostViewData post,
  ) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      postId: post.id,
      style: feedThemeData.mediaStyle,
      carouselIndicatorBuilder:
          LMFeedCore.widgetUtility.postMediaCarouselIndicatorBuilder,
      imageBuilder: LMFeedCore.widgetUtility.imageBuilder,
      videoBuilder: LMFeedCore.widgetUtility.videoBuilder,
      onMediaTap: () async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: _feedBloc.users[post.uuid]!,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );
  }

  LMFeedButton defLikeButton(
          BuildContext context, LMPostViewData postViewData) =>
      LMFeedButton(
        isActive: postViewData.isLiked,
        text: LMFeedText(
            text: LMFeedPostUtils.getLikeCountTextWithCount(
                postViewData.likeCount)),
        style: feedThemeData.footerStyle.likeButtonStyle,
        onTextTap: () {
          LMFeedVideoProvider.instance.pauseCurrentVideo();
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedLikesScreen(
                postId: postViewData.id,
              ),
            ),
          )..then((value) => LMFeedVideoProvider.instance.playCurrentVideo());
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
              widgetSource: LMFeedWidgetSource.universalFeed,
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

  LMFeedButton defCommentButton(BuildContext context, LMPostViewData post) =>
      LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(post.commentCount),
        ),
        style: feedThemeData.footerStyle.commentButtonStyle,
        onTap: () async {
          LMFeedVideoProvider.instance.pauseCurrentVideo();
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
                postBuilder: widget.postBuilder,
              ),
            ),
          );
          LMFeedVideoProvider.instance.playCurrentVideo();
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
          }
        },
        style: feedThemeData.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(LMPostViewData postViewData) => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          LMFeedDeepLinkHandler().sharePost(postViewData.id);
        },
        style: feedThemeData.footerStyle.shareButtonStyle,
      );

  LMFeedButton defRepostButton(
          BuildContext context, LMPostViewData postViewData) =>
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
        onTap: right
            ? () async {
                if (!postUploading.value) {
                  LMFeedAnalyticsBloc.instance.add(
                      const LMFeedFireAnalyticsEvent(
                          eventName: LMFeedAnalyticsKeys.postCreationStarted,
                          widgetSource: LMFeedWidgetSource.universalFeed,
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
                  LMFeedCore.showSnackBar(
                    LMFeedSnackBar(
                      content: LMFeedText(
                        text: 'A post is already uploading.',
                      ),
                    ),
                  );
                }
              }
            : () {
                LMFeedCore.showSnackBar(
                  LMFeedSnackBar(
                    content: LMFeedText(
                      text: "You do not have permission to create a post",
                    ),
                  ),
                );
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

  void handlePostPinAction(LMPostViewData postViewData) async {
    postViewData.isPinned = !postViewData.isPinned;

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        postId: postViewData.id,
        actionType: postViewData.isPinned
            ? LMFeedPostActionType.pinned
            : LMFeedPostActionType.unpinned));

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
          postId: postViewData.id,
          actionType: postViewData.isPinned
              ? LMFeedPostActionType.pinned
              : LMFeedPostActionType.unpinned));
    } else {
      String postType = LMFeedPostUtils.getPostType(postViewData.attachments);

      LMFeedAnalyticsBloc.instance.add(
        LMFeedFireAnalyticsEvent(
          eventName: postViewData.isPinned
              ? LMFeedAnalyticsKeys.postPinned
              : LMFeedAnalyticsKeys.postUnpinned,
          widgetSource: LMFeedWidgetSource.universalFeed,
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
