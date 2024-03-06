import 'dart:io';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
import 'package:likeminds_feed_flutter_core/src/views/media/media_preview_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/widgets/delete_dialog.dart';
import 'package:media_kit_video/media_kit_video.dart';

class LMFeedActivityScreen extends StatefulWidget {
  final String uuid;

  final LMFeedPostWidgetBuilder? postBuilder;
  final LMFeedPostCommentBuilder? commentBuilder;

  const LMFeedActivityScreen({
    super.key,
    required this.uuid,
    this.postBuilder,
    this.commentBuilder,
  });

  @override
  State<LMFeedActivityScreen> createState() => _LMFeedActivityScreenState();
}

class _LMFeedActivityScreenState extends State<LMFeedActivityScreen> {
  final PagingController<int, UserActivityItem> _pagingController =
      PagingController(firstPageKey: 1);
  Map<String, LMUserViewData> users = {};
  Map<String, LMTopicViewData> topics = {};
  Map<String, WidgetModel> widgets = {};
  Map<String, Post> repostedPosts = {};
  Map<String, Comment> filteredComments = {};

  bool isCm = LMFeedUserLocalPreference.instance.fetchMemberState();

  LMUserViewData currentUser =
      LMFeedUserLocalPreference.instance.fetchUserData();

  LMFeedThemeData? feedTheme;

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
        Map<String, LMTopicViewData> topics = userActivityResponse.topics?.map(
                (key, value) =>
                    MapEntry(key, LMTopicViewDataConvertor.fromTopic(value))) ??
            {};

        this.topics.addAll(topics);

        Map<String, LMUserViewData> users = userActivityResponse.users?.map(
                (key, value) =>
                    MapEntry(key, LMUserViewDataConvertor.fromUser(value))) ??
            {};

        this.users.addAll(users);
        widgets.addAll(userActivityResponse.widgets ?? {});

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
    feedTheme = LMFeedCore.theme;
    return Scaffold(
      backgroundColor: feedTheme?.backgroundColor,
      appBar: LMFeedAppBar(
        style: LMFeedAppBarStyle(
          backgroundColor: feedTheme?.container,
          centerTitle: Platform.isAndroid ? false : true,
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
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: PagedListView<int, UserActivityItem>(
          pagingController: _pagingController,
          builderDelegate: PagedChildBuilderDelegate<UserActivityItem>(
            noItemsFoundIndicatorBuilder: (context) {
              return const Center(
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
                        text: 'No Posts to show',
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
            },
            itemBuilder: (context, item, index) {
              final LMPostViewData postViewData =
                  LMFeedPostUtils.postViewDataFromActivity(
                item,
                widgets,
                users.map((key, value) =>
                    MapEntry(key, LMUserViewDataConvertor.toUser(value))),
                topics.map((key, value) =>
                    MapEntry(key, LMTopicViewDataConvertor.toTopic(value))),
              );
              final user = users[item.activityEntityData.uuid]!;

              return Column(
                children: [
                  widget.postBuilder?.call(
                          context,
                          defPostWidget(feedTheme, postViewData, item),
                          postViewData) ??
                      defPostWidget(feedTheme, postViewData, item),
                  if (item.action == 7)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: feedTheme?.container,
                        border: Border(
                          bottom: BorderSide(
                            width: 0.2,
                            color: feedTheme?.container.withOpacity(0.1) ??
                                Colors.grey,
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Divider(
                            color: feedTheme?.onContainer.withOpacity(0.05),
                            thickness: 1,
                          ),
                          StatefulBuilder(
                            builder: (context, setCommentState) {
                              final commentData = item.activityEntityData;
                              final LMCommentViewData commentViewData =
                                  LMFeedPostUtils.commentViewDataFromActivity(
                                      commentData,
                                      users.map((key, value) => MapEntry(
                                          key,
                                          LMUserViewDataConvertor.toUser(
                                              value))));

                              commentData.menuItems?.removeWhere((element) =>
                                  element.id ==
                                      LMFeedMenuAction.commentReportId ||
                                  element.id == LMFeedMenuAction.commentEditId);

                              return widget.commentBuilder?.call(
                                      context,
                                      defCommentTile(feedTheme, commentViewData,
                                          postViewData, user),
                                      postViewData) ??
                                  defCommentTile(feedTheme, commentViewData,
                                      postViewData, user);
                            },
                          ),
                        ],
                      ),
                    ),
                  LikeMindsTheme.kVerticalPaddingLarge,
                ],
              );
            },
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
          ),
        );
      },
      onMediaTap: () async {
        VideoController? videoController = LMFeedVideoProvider.instance
            .getVideoController(
                LMFeedVideoProvider.instance.currentVisiblePostId ?? post.id);

        await videoController?.player.pause();

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

        await videoController?.player.play();
      },
      onPostTap: (context, post) {
        navigateToLMFeedPostDetailsScreen(post.id);
      },
      footer: _defFooterWidget(feedTheme, post),
      header: _defPostHeader(feedTheme, post),
      content: _defContentWidget(feedTheme, post),
      media: _defPostMedia(feedTheme, post),
      topicWidget: _defTopicWidget(feedTheme, post),
      style: feedTheme?.postStyle.copyWith(
        margin: EdgeInsets.zero,
      ),
    );
  }

  LMFeedPostTopic _defTopicWidget(
      LMFeedThemeData? feedTheme, LMPostViewData post) {
    return LMFeedPostTopic(
      topics: post.topics,
      post: post,
      style: feedTheme?.topicStyle,
    );
  }

  LMFeedPostContent _defContentWidget(
      LMFeedThemeData? feedTheme, LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String? uuid) {},
      style: feedTheme?.contentStyle,
      text: post.text,
      heading: post.heading,
    );
  }

  LMFeedPostFooter _defFooterWidget(
      LMFeedThemeData? feedTheme, LMPostViewData post) {
    return LMFeedPostFooter(
      likeButton: defLikeButton(feedTheme, post),
      commentButton: defCommentButton(feedTheme, post),
      saveButton: defSaveButton(feedTheme, post),
      shareButton: defShareButton(feedTheme, post),
      postFooterStyle: feedTheme?.footerStyle.copyWith(
        margin: EdgeInsets.zero,
      ),
      showRepostButton: false,
    );
  }

  LMFeedPostHeader _defPostHeader(
      LMFeedThemeData? feedTheme, LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: users[postViewData.uuid]!,
      isFeed: true,
      postViewData: postViewData,
      onProfileTap: () {
        LMFeedCore.instance.lmFeedClient
            .routeToProfile(users[postViewData.uuid]!.sdkClientInfo.uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: users[postViewData.uuid]!.sdkClientInfo.uuid,
          ),
        );
      },
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
          action: LMFeedMenuAction(
            onPostPin: () => handlePostPinAction(postViewData),
            onPostUnpin: () => handlePostPinAction(postViewData),
            onPostDelete: () {
              String postCreatorUUID = postViewData.user.sdkClientInfo.uuid;

              showDialog(
                context: context,
                builder: (childContext) => LMFeedDeleteConfirmationDialog(
                  title: 'Delete Comment',
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
      onMediaTap: () async {
        VideoController? videoController = LMFeedVideoProvider.instance
            .getVideoController(
                LMFeedVideoProvider.instance.currentVisiblePostId ?? post.id);

        await videoController?.player.pause();

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

        await videoController?.player.play();
      },
    );
  }

  LMFeedButton defLikeButton(
          LMFeedThemeData? feedTheme, LMPostViewData postViewData) =>
      LMFeedButton(
        isActive: postViewData.isLiked,
        text: LMFeedText(
            text: LMFeedPostUtils.getLikeCountTextWithCount(
                postViewData.likeCount)),
        style: feedTheme?.footerStyle.likeButtonStyle,
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
          // rebuildPostWidget.value = !rebuildPostWidget.value;

          final likePostRequest =
              (LikePostRequestBuilder()..postId(postViewData.id)).build();

          final LikePostResponse response =
              await LMFeedCore.client.likePost(likePostRequest);

          if (!response.success) {
            postViewData.isLiked = !postViewData.isLiked;
            postViewData.likeCount = postViewData.isLiked
                ? postViewData.likeCount + 1
                : postViewData.likeCount - 1;
            // rebuildPostWidget.value = !rebuildPostWidget.value;
          }
        },
      );

  LMFeedButton defCommentButton(
          LMFeedThemeData? feedTheme, LMPostViewData postViewData) =>
      LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(
              postViewData.commentCount),
        ),
        style: feedTheme?.footerStyle.commentButtonStyle,
        onTap: () => navigateToLMFeedPostDetailsScreen(postViewData.id),
      );

  LMFeedButton defSaveButton(
          LMFeedThemeData? feedTheme, LMPostViewData postViewData) =>
      LMFeedButton(
        isActive: postViewData.isSaved,
        onTap: () async {
          postViewData.isSaved = !postViewData.isSaved;
          LMFeedPostBloc.instance
              .add(LMFeedUpdatePostEvent(post: postViewData));

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            postViewData.isSaved = !postViewData.isSaved;
            LMFeedPostBloc.instance
                .add(LMFeedUpdatePostEvent(post: postViewData));
          }
        },
        style: feedTheme?.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(
          LMFeedThemeData? feedTheme, LMPostViewData postViewData) =>
      LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
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
        onTap: () {
          LMFeedCore.instance.lmFeedClient
              .routeToProfile(users[commentViewData.uuid]!.sdkClientInfo.uuid);
        },
        imageUrl: users[commentViewData.uuid]!.imageUrl,
      ),
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
            color: feedTheme?.primaryColor,
          ),
        ),
      ),
      style: feedTheme?.commentStyle.showRepliesButtonStyle,
    );
  }

  LMFeedButton defCommentLikeButton(LMFeedThemeData? feedTheme,
      LMCommentViewData commentViewData, LMPostViewData postViewData) {
    return LMFeedButton(
      style: feedTheme?.commentStyle.likeButtonStyle?.copyWith(
              showText: commentViewData.likesCount == 0 ? false : true) ??
          LMFeedButtonStyle(
            margin: 10.0,
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
        }
      },
      isActive: commentViewData.isLiked,
    );
  }

  LMFeedButton defCommentReplyButton(LMFeedThemeData? feedTheme,
      LMPostViewData postViewData, LMCommentViewData commentViewData) {
    return LMFeedButton(
      style: feedTheme?.commentStyle.replyButtonStyle ??
          const LMFeedButtonStyle(
            margin: 10,
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
          debugPrint('Editing functionality');

          LMCommentMetaDataBuilder commentMetaDataBuilder =
              LMCommentMetaDataBuilder()
                ..postId(postViewData.id)
                ..commentActionType(LMFeedCommentActionType.edit)
                ..commentText(LMFeedTaggingHelper.convertRouteToTag(
                    commentViewData.text));

          if (commentViewData.level == 0) {
            commentMetaDataBuilder
              ..commentActionEntity(LMFeedCommentType.parent)
              ..level(0)
              ..commentId(commentViewData.id);
          } else {
            commentMetaDataBuilder
              ..level(1)
              ..commentActionEntity(LMFeedCommentType.reply)
              ..commentId(commentViewData.parentComment!.id)
              ..replyId(commentViewData.id);
          }
        },
        onCommentDelete: () {
          String commentCreatorUUID = commentViewData.user.sdkClientInfo.uuid;

          showDialog(
            context: context,
            builder: (childContext) => LMFeedDeleteConfirmationDialog(
              title: 'Delete Comment',
              uuid: commentCreatorUUID,
              content:
                  'Are you sure you want to delete this post. This action can not be reversed.',
              action: (String reason) async {
                Navigator.of(childContext).pop();

                LMFeedAnalyticsBloc.instance.add(
                  LMFeedFireAnalyticsEvent(
                    eventName: LMFeedAnalyticsKeys.commentDeleted,
                    deprecatedEventName: LMFeedAnalyticsKeysDep.commentDeleted,
                    eventProperties: {
                      "post_id": postViewData,
                      "comment_id": commentViewData.id,
                    },
                  ),
                );

                DeleteCommentRequest deleteCommentRequest =
                    (DeleteCommentRequestBuilder()
                          ..postId(postViewData.id)
                          ..commentId(commentViewData.id)
                          ..reason(
                              reason.isEmpty ? "Reason for deletion" : reason))
                        .build();

                LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
                      ..commentActionEntity(LMFeedCommentType.parent)
                      ..postId(postViewData.id)
                      ..commentActionType(LMFeedCommentActionType.delete)
                      ..level(0)
                      ..commentId(commentViewData.id))
                    .build();
              },
              actionText: 'Delete',
            ),
          );
        },
      );

  void navigateToLMFeedPostDetailsScreen(String postId) async {
    VideoController? videoController = LMFeedVideoProvider.instance
        .getVideoController(
            LMFeedVideoProvider.instance.currentVisiblePostId ?? postId);

    await videoController?.player.pause();

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

    await videoController?.player.play();
  }

  void handlePostPinAction(LMPostViewData postViewData) async {
    postViewData.isPinned = !postViewData.isPinned;

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(post: postViewData));

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    if (!response.success) {
      postViewData.isPinned = !postViewData.isPinned;

      LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(post: postViewData));
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
