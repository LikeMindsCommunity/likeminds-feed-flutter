import 'dart:io';

import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/media/media_preview_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/widgets/delete_dialog.dart';

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

  LMFeedThemeData? feedTheme;

  late final LMFeedCommentHandlerBloc _commentHandlerBloc;

  @override
  void initState() {
    _commentHandlerBloc = LMFeedCommentHandlerBloc.instance;
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
    _commentHandlerBloc.close();
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    feedTheme = LMFeedTheme.of(context);
    return Scaffold(
      backgroundColor: feedTheme?.backgroundColor,
      appBar: LMFeedAppBar(
        leading: const SizedBox.shrink(),
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
                  LMFeedPostUtils.postViewDataFromActivity(item);
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
                            color: feedTheme?.onContainer.withOpacity(0.1),
                            thickness: 1,
                          ),
                          StatefulBuilder(
                            builder: (context, setCommentState) {
                              final commentData = item.activityEntityData;
                              final LMCommentViewData commentViewData =
                                  LMFeedPostUtils.commentViewDataFromActivity(
                                      commentData);

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
            color: feedTheme?.onContainer.withOpacity(0.1),
            thickness: 1,
          ),
          LikeMindsTheme.kVerticalPaddingMedium,
        ],
      ),
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
      onMediaTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: users[post.userId]!,
            ),
          ),
        );
      },
      onPostTap: (context, post) {
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedPostDetailScreen(
              postId: post.id,
              // postBuilder: widget.postBuilder,
            ),
          ),
        );
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
      topics: topics,
      post: post,
      style: feedTheme?.topicStyle,
    );
  }

  LMFeedPostContent _defContentWidget(
      LMFeedThemeData? feedTheme, LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String? userId) {},
      style: feedTheme?.contentStyle,
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
    );
  }

  LMFeedPostHeader _defPostHeader(
      LMFeedThemeData? feedTheme, LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: users[postViewData.userId]!,
      isFeed: true,
      postViewData: postViewData,
      menuBuilder: (menu) {
        return menu.copyWith(
          removeItemIds: {
            LMFeedMenuAction.postReportId,
            LMFeedMenuAction.postEditId
          },
          action: LMFeedMenuAction(
            onPostPin: () async {
              postViewData.isPinned = !postViewData.isPinned;
              // rebuildPostWidget.value = !rebuildPostWidget.value;

              final pinPostRequest =
                  (PinPostRequestBuilder()..postId(postViewData.id)).build();

              final PinPostResponse response =
                  await LMFeedCore.client.pinPost(pinPostRequest);

              LMFeedPostBloc.instance
                  .add(LMFeedUpdatePostEvent(post: postViewData));

              if (!response.success) {
                postViewData.isPinned = !postViewData.isPinned;
                // rebuildPostWidget.value = !rebuildPostWidget.value;
                LMFeedPostBloc.instance
                    .add(LMFeedUpdatePostEvent(post: postViewData));
              }
            },
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
      postHeaderStyle: feedTheme?.headerStyle,
    );
  }

  LMFeedPostMedia _defPostMedia(
      LMFeedThemeData? feedTheme, LMPostViewData post) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      style: feedTheme?.mediaStyle,
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
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: postViewData.id,
                openKeyboard: true,
                // postBuilder: widget.postBuilder,
              ),
            ),
          );
        },
      );

  LMFeedButton defSaveButton(
          LMFeedThemeData? feedTheme, LMPostViewData postViewData) =>
      LMFeedButton(
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
    return LMFeedCommentWidget(
      user: userViewData,
      comment: commentViewData,
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
        fallbackText: users[commentViewData.userId]!.name,
        onTap: () {
          if (users[commentViewData.userId]!.sdkClientInfo != null) {
            LMFeedCore.instance.lmFeedClient.routeToProfile(
                users[commentViewData.userId]!.sdkClientInfo!.userUniqueId);
          }
        },
        imageUrl: users[commentViewData.userId]!.imageUrl,
      ),
      likeButton:
          defCommentLikeButton(feedTheme, commentViewData, postViewData),
      replyButton: defCommentReplyButton(feedTheme, commentViewData),
      onTagTap: (String userId) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(userId);
      },
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

  LMFeedButton defCommentReplyButton(
      LMFeedThemeData? feedTheme, LMCommentViewData commentViewData) {
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
      onTap: () {},
    );
  }

  LMFeedMenuAction defLMFeedMenuAction(LMFeedThemeData? feedTheme,
          LMCommentViewData commentViewData, LMPostViewData postViewData) =>
      LMFeedMenuAction(
        onCommentEdit: () {
          debugPrint('Editing functionality');

          LMCommentMetaDataBuilder commentMetaDataBuilder =
              LMCommentMetaDataBuilder()
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

          // _postDetailScreenHandler!.commentHandlerBloc.add(
          //   LMFeedCommentOngoingEvent(
          //     commentMetaData: commentMetaDataBuilder.build(),
          //   ),
          // );
        },
        onCommentDelete: () {
          showDialog(
            context: context,
            builder: (childContext) => LMFeedDeleteConfirmationDialog(
              title: 'Delete Comment',
              userId: commentViewData.userId,
              content:
                  'Are you sure you want to delete this post. This action can not be reversed.',
              action: (String reason) async {
                Navigator.of(childContext).pop();

                LMFeedAnalyticsBloc.instance.add(
                  LMFeedFireAnalyticsEvent(
                    eventName: LMFeedAnalyticsKeys.commentDeleted,
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
                      ..commentActionType(LMFeedCommentActionType.delete)
                      ..level(0)
                      ..commentId(commentViewData.id))
                    .build();

                // _postDetailScreenHandler!.commentHandlerBloc.add(
                //     LMFeedCommentActionEvent(
                //         commentActionRequest: deleteCommentRequest,
                //         commentMetaData: commentMetaData));
              },
              actionText: 'Delete',
            ),
          );
        },
      );
}
