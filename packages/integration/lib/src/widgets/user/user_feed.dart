import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/post_action_id.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:likeminds_feed_flutter_core/src/utils/typedefs.dart';
import 'package:likeminds_feed_flutter_core/src/views/media/media_preview_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/widgets/delete_dialog.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:overlay_support/overlay_support.dart';

class LMFeedUserFeedWidget extends StatefulWidget {
  const LMFeedUserFeedWidget({
    Key? key,
    required this.userId,
    this.postBuilder,
    this.emptyFeedViewBuilder,
    this.firstPageLoaderBuilder,
    this.paginationLoaderBuilder,
    this.feedErrorViewBuilder,
    this.noNewPageWidgetBuilder,
  }) : super(key: key);

  // The user id for which the user feed is to be shown
  final String userId;
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
  State<LMFeedUserFeedWidget> createState() => _LMFeedUserFeedWidgetState();
}

class _LMFeedUserFeedWidgetState extends State<LMFeedUserFeedWidget> {
  static const int pageSize = 10;
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  Map<String, LMUserViewData> users = {};
  Map<String, LMTopicViewData> topics = {};
  Map<String, LMWidgetViewData> widgets = {};
  Map<String, Post> repostedPosts = {};

  int _pageFeed = 1;
  final PagingController<int, LMPostViewData> _pagingController =
      PagingController(firstPageKey: 1);
  bool userPostingRights = true;
  LMFeedThemeData? feedThemeData;
  final ValueNotifier postUploading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    userPostingRights = checkPostCreationRights();
    addPaginationListener();
  }

  bool checkPostCreationRights() {
    final MemberStateResponse memberStateResponse =
        LMFeedUserLocalPreference.instance.fetchMemberRights();
    if (!memberStateResponse.success || memberStateResponse.state == 1) {
      return true;
    }
    final memberRights = LMFeedUserLocalPreference.instance.fetchMemberRight(9);
    return memberRights;
  }

  void addPaginationListener() {
    _pagingController.addPageRequestListener((pageKey) async {
      final userFeedRequest = (GetUserFeedRequestBuilder()
            ..page(pageKey)
            ..pageSize(pageSize)
            ..userId(widget.userId))
          .build();
      GetUserFeedResponse response =
          await LMFeedCore.instance.lmFeedClient.getUserFeed(userFeedRequest);
      updatePagingControllers(response);
    });
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(GetUserFeedResponse response) {
    if (response.success) {
      _pageFeed++;
      List<LMPostViewData> listOfPosts = response.posts!
          .map((e) => LMPostViewDataConvertor.fromPost(post: e))
          .toList();
      if (listOfPosts.length < 10) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, _pageFeed);
      }
      if (response.topics != null) {
        topics.addAll(response.topics!.map((key, value) =>
            MapEntry(key, LMTopicViewDataConvertor.fromTopic(value))));
      }
      if (response.users != null) {
        users.addAll(response.users!.map((key, value) =>
            MapEntry(key, LMUserViewDataConvertor.fromUser(value))));
      }
      if (response.widgets != null) {
        widgets.addAll(response.widgets!.map((key, value) =>
            MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value))));
      }
      if (response.repostedPosts != null) {
        repostedPosts.addAll(response.repostedPosts!);
      }
    } else {
      _pagingController.appendLastPage([]);
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
    _pageFeed = 1;
  }

  @override
  Widget build(BuildContext context) {
    feedThemeData = LMFeedTheme.of(context);
    LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
    return BlocListener(
      bloc: newPostBloc,
      listener: (context, state) {
        if (state is LMFeedPostDeletedState) {
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          feedRoomItemList?.removeWhere((item) => item.id == state.postId);
          _pagingController.itemList = feedRoomItemList;
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }
        if (state is LMFeedPostUpdateState) {
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          int index = feedRoomItemList
                  ?.indexWhere((element) => element.id == state.post.id) ??
              -1;
          if (index != -1) {
            feedRoomItemList![index] = state.post;
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
          //todo: add repostedPost data in state
          users.addAll(state.userData);
          topics.addAll(state.topics);
          widgets.addAll(state.widgets);
          // repostedPosts.addAll(state.repostedPosts);
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }

        if (state is LMFeedPostUpdateState) {
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          int index = feedRoomItemList
                  ?.indexWhere((element) => element.id == state.post.id) ??
              -1;
          if (index != -1) {
            feedRoomItemList?[index] = state.post;
          }
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }
      },
      child: ValueListenableBuilder(
          valueListenable: rebuildPostWidget,
          builder: (context, _, __) {
            return PagedSliverList(
              pagingController: _pagingController,
              builderDelegate: PagedChildBuilderDelegate<LMPostViewData>(
                noItemsFoundIndicatorBuilder: (context) {
                  return widget.emptyFeedViewBuilder?.call(context) ??
                      noPostInFeedWidget();
                },
                itemBuilder: (context, item, index) {
                  if (!users.containsKey(item.userId)) {
                    return const SizedBox();
                  }
                  return Column(
                    children: [
                      const SizedBox(height: 2),
                      widget.postBuilder?.call(
                            context,
                            defPostWidget(feedThemeData, item),
                            item,
                          ) ??
                          defPostWidget(feedThemeData, item),
                    ],
                  );
                },
                firstPageProgressIndicatorBuilder: (context) =>
                    const LMFeedShimmer(),
                newPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            );
          }),
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
          child: LMFeedPostImage(
            imageFile: media.mediaFile!,
            style: const LMFeedPostImageStyle(
              boxFit: BoxFit.contain,
            ),
          ),
        );
      } else if (media.mediaType == LMMediaType.document) {
        return const LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: kAssetDocPDFIcon,
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
      topics: topics,
      user: users[post.userId]!,
      isFeed: false,
      onTagTap: (String userId) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            userUniqueId: userId,
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
              user: users[post.userId]!,
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
      topics: topics,
      post: post,
      style: feedThemeData?.topicStyle,
    );
  }

  LMFeedPostContent _defContentWidget(LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String? userId) {},
      style: feedThemeData?.contentStyle,
    );
  }

  LMFeedPostFooter _defFooterWidget(LMPostViewData post) {
    return LMFeedPostFooter(
      likeButton: defLikeButton(post),
      commentButton: defCommentButton(post),
      saveButton: defSaveButton(post),
      shareButton: defShareButton(post),
      postFooterStyle: feedThemeData?.footerStyle,
    );
  }

  LMFeedPostHeader _defPostHeader(LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: users[postViewData.userId]!,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: feedThemeData?.headerStyle,
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
                  userId: postViewData.userId,
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
      style: feedThemeData?.mediaStyle,
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
              user: users[post.userId]!,
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
        onTap: () async {
          postViewData.isSaved = !postViewData.isSaved;
          rebuildPostWidget.value = !rebuildPostWidget.value;
          LMFeedPostBloc.instance
              .add(LMFeedUpdatePostEvent(post: postViewData));

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            postViewData.isSaved = !postViewData.isSaved;
            rebuildPostWidget.value = !rebuildPostWidget.value;
            LMFeedPostBloc.instance
                .add(LMFeedUpdatePostEvent(post: postViewData));
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
                backgroundColor: feedThemeData?.primaryColor,
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

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(post: postViewData));

    if (!response.success) {
      postViewData.isPinned = !postViewData.isPinned;
      rebuildPostWidget.value = !rebuildPostWidget.value;
      LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(post: postViewData));
    }
  }
}
