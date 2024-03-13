import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/post_action_id.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:likeminds_feed_flutter_core/src/utils/typedefs.dart';
import 'package:likeminds_feed_flutter_core/src/utils/builder/widget_utility.dart';
import 'package:likeminds_feed_flutter_core/src/views/media/media_preview_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/widgets/delete_dialog.dart';
import 'package:media_kit_video/media_kit_video.dart';

class LMFeedUserFeedWidget extends StatefulWidget {
  const LMFeedUserFeedWidget({
    Key? key,
    required this.uuid,
    this.postBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
  }) : super(key: key);

  // The user id for which the user feed is to be shown
  final String uuid;
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
  State<LMFeedUserFeedWidget> createState() => _LMFeedUserFeedWidgetState();
}

class _LMFeedUserFeedWidgetState extends State<LMFeedUserFeedWidget> {
  LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;
  static const int pageSize = 10;
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  Map<String, LMUserViewData> users = {};
  Map<String, LMTopicViewData> topics = {};
  Map<String, WidgetModel> widgets = {};
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
            ..uuid(widget.uuid))
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
      if (response.topics != null) {
        topics.addAll(response.topics!.map((key, value) =>
            MapEntry(key, LMTopicViewDataConvertor.fromTopic(value))));
      }
      if (response.users != null) {
        users.addAll(response.users!.map((key, value) =>
            MapEntry(key, LMUserViewDataConvertor.fromUser(value))));
      }
      if (response.widgets != null) {
        widgets.addAll(response.widgets!);
      }
      if (response.repostedPosts != null) {
        repostedPosts.addAll(response.repostedPosts!);
      }
      List<LMPostViewData> listOfPosts = response.posts!
          .map((e) => LMPostViewDataConvertor.fromPost(
              post: e,
              widgets: widgets,
              repostedPosts: repostedPosts,
              topics: topics.map((key, value) =>
                  MapEntry(key, LMTopicViewDataConvertor.toTopic(value))),
              users: users.map((key, value) =>
                  MapEntry(key, LMUserViewDataConvertor.toUser(value)))))
          .toList();
      if (listOfPosts.length < 10) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, _pageFeed);
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
    feedThemeData = LMFeedCore.theme;
    LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
    return BlocListener(
      bloc: newPostBloc,
      listener: (context, state) {
        if (state is LMFeedNewPostErrorState) {
          postUploading.value = false;
          LMFeedCore.showSnackBar(
            LMFeedSnackBar(
              content: LMFeedText(
                text: state.errorMessage,
              ),
            ),
          );
          // TODO: remove old toast
          // toast(
          //   state.message,
          //   duration: Toast.LENGTH_LONG,
          // );
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
            users.addAll(state.userData);
            topics.addAll(state.topics);
            _pagingController.itemList = feedRoomItemList;
            postUploading.value = false;
            rebuildPostWidget.value = !rebuildPostWidget.value;
          } else {
            users.addAll(state.userData);
            topics.addAll(state.topics);
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
        if (state is LMFeedEditPostUploadedState) {
          LMPostViewData? item = state.postData;
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          int index = feedRoomItemList
                  ?.indexWhere((element) => element.id == item.id) ??
              -1;
          if (index != -1) {
            feedRoomItemList?[index] = item;
          }
          users.addAll(state.userData);
          topics.addAll(state.topics);
          widgets.addAll(state.widgets.map((key, value) =>
              MapEntry(key, LMWidgetViewDataConvertor.toWidgetModel(value))));
          rebuildPostWidget.value = !rebuildPostWidget.value;
        }

        if (state is LMFeedPostUpdateState) {
          List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
          int index = feedRoomItemList
                  ?.indexWhere((element) => element.id == state.postId) ??
              -1;
          if (index != -1) {
            LMPostViewData? postViewData = feedRoomItemList?[index];
            if (postViewData != null) {
              LMFeedPostUtils.updatePostData(postViewData, state.actionType);
            }
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
                itemBuilder: (context, item, index) {
                  if (!users.containsKey(item.uuid)) {
                    return const SizedBox();
                  }
                  LMFeedPostWidget postWidget =
                      defPostWidget(feedThemeData, item);

                  return Column(
                    children: [
                      const SizedBox(height: 2),
                      widget.postBuilder?.call(context, postWidget, item) ??
                          _widgetsBuilder.postWidgetBuilder(
                              context, postWidget, item),
                    ],
                  );
                },
                noItemsFoundIndicatorBuilder: (context) {
                  return widget.noItemsFoundIndicatorBuilder?.call(context) ??
                      _widgetsBuilder.noItemsFoundIndicatorBuilderFeed(context,
                          createPostButton: createPostButton());
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

  LMFeedPostWidget defPostWidget(
      LMFeedThemeData? feedThemeData, LMPostViewData post) {
    return LMFeedPostWidget(
      post: post,
      topics: post.topics,
      user: users[post.uuid]!,
      isFeed: false,
      onTagTap: (String uuid) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid,
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
              user: users[post.uuid]!,
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
      style: feedThemeData?.topicStyle,
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
      user: users[postViewData.uuid]!,
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
              user: users[post.uuid]!,
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
        isActive: postViewData.isSaved,
        onTap: () async {
          postViewData.isSaved = !postViewData.isSaved;
          rebuildPostWidget.value = !rebuildPostWidget.value;
          LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
            postId: postViewData.id,
            actionType: postViewData.isSaved
                ? LMFeedPostActionType.saved
                : LMFeedPostActionType.unsaved,
          ));

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            postViewData.isSaved = !postViewData.isSaved;
            rebuildPostWidget.value = !rebuildPostWidget.value;
            LMFeedPostBloc.instance.add(
              LMFeedUpdatePostEvent(
                postId: postViewData.id,
                actionType: postViewData.isSaved
                    ? LMFeedPostActionType.saved
                    : LMFeedPostActionType.unsaved,
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
            LMFeedCore.showSnackBar(
              LMFeedSnackBar(
                content: LMFeedText(
                  text: 'A post is already uploading.',
                ),
              ),
            );
            // TODO: remove old toast
            // toast(
            //   'A post is already uploading.',
            //   duration: Toast.LENGTH_LONG,
            // );
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

  LMFeedButton createPostButton() {
    return LMFeedButton(
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
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
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
                LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
                    eventName: LMFeedAnalyticsKeys.postCreationStarted,
                    deprecatedEventName:
                        LMFeedAnalyticsKeysDep.postCreationStarted,
                    eventProperties: {}));

                String? currentVisiblePost =
                    LMFeedVideoProvider.instance.currentVisiblePostId;

                VideoController? postVideoController = LMFeedVideoProvider
                    .instance
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
                LMFeedCore.showSnackBar(
                  LMFeedSnackBar(
                    content: LMFeedText(
                      text: 'A post is already uploading.',
                    ),
                  ),
                );
                // TODO: remove old toast
                // toast(
                //   'A post is already uploading.',
                //   duration: Toast.LENGTH_LONG,
                // );
              }
            }
          : () {
              LMFeedCore.showSnackBar(
                LMFeedSnackBar(
                  content: LMFeedText(
                    text: 'You do not have permission to create a post',
                  ),
                ),
              );
              // TODO: remove old toast
              // toast("You do not have permission to create a post");
            },
    );
  }

  void handlePostPinAction(LMPostViewData postViewData) async {
    postViewData.isPinned = !postViewData.isPinned;
    rebuildPostWidget.value = !rebuildPostWidget.value;

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        postId: postViewData.id,
        actionType: postViewData.isPinned
            ? LMFeedPostActionType.pinned
            : LMFeedPostActionType.unpinned));

    if (!response.success) {
      postViewData.isPinned = !postViewData.isPinned;
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
