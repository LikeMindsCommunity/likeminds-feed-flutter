// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/poll/handler/poll_handler.dart';
import 'package:likeminds_feed_flutter_core/src/views/poll/poll_result_screen.dart';

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
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  LMFeedWidgetUtility _widgetUtility = LMFeedCore.widgetUtility;
  final PagingController<int, UserActivityItem> _pagingController =
      PagingController(firstPageKey: 1);
  Map<String, LMUserViewData> users = {};
  Map<String, LMTopicViewData> topics = {};
  Map<String, LMWidgetViewData> widgets = {};
  Map<String, Post> repostedPosts = {};
  Map<String, Comment> filteredComments = {};

  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();

  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();

  LMFeedThemeData feedTheme = LMFeedCore.theme;

  LMFeedWidgetSource widgetSource = LMFeedWidgetSource.activityScreen;

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
        widgets.addAll(userActivityResponse.widgets?.map((key, value) =>
                MapEntry(
                    key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
            {});

        Map<String, LMTopicViewData> topics = userActivityResponse.topics?.map(
                (key, value) => MapEntry(
                    key,
                    LMTopicViewDataConvertor.fromTopic(value,
                        widgets: widgets))) ??
            {};

        this.topics.addAll(topics);

        Map<String, LMUserViewData> users =
            userActivityResponse.users?.map((key, value) => MapEntry(
                    key,
                    LMUserViewDataConvertor.fromUser(
                      value,
                      topics: this.topics,
                      widgets: widgets,
                    ))) ??
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
    _pagingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _widgetUtility.scaffold(
      source: widgetSource,
      backgroundColor: feedTheme.backgroundColor,
      appBar: LMFeedAppBar(
        style: LMFeedAppBarStyle(
          backgroundColor: feedTheme.container,
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
              return Center(
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
                        text:
                            'No ${LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural)} to show',
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
                users,
                topics,
              );
              final user = users[item.activityEntityData.uuid]!;

              LMFeedPostWidget postWidget =
                  defPostWidget(feedTheme, postViewData, item);

              return Column(
                children: [
                  widget.postBuilder?.call(context, postWidget, postViewData) ??
                      _widgetUtility.postWidgetBuilder(
                          context, postWidget, postViewData,
                          source: widgetSource),
                  if (item.action == 7)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      decoration: BoxDecoration(
                        color: feedTheme.container,
                        border: Border(
                          bottom: BorderSide(
                            width: 0.2,
                            color: feedTheme.container.withOpacity(0.1),
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          Divider(
                            color: feedTheme.onContainer.withOpacity(0.05),
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

                              LMFeedCommentWidget commentWidget =
                                  defCommentTile(feedTheme, commentViewData,
                                      postViewData, user);

                              return widget.commentBuilder?.call(
                                      context, commentWidget, postViewData) ??
                                  _widgetUtility.commentBuilder(
                                      context, commentWidget, postViewData);
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
            context: context,
          ),
        );
      },
      onMediaTap: () async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();

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

        LMFeedVideoProvider.instance.playCurrentVideo();
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
            context: context,
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
                  title: 'Delete $postTitleFirstCap',
                  uuid: postCreatorUUID,
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
                        userId: postCreatorUUID,
                        userState: isCm ? "CM" : "member",
                      ),
                    );
                  },
                  actionText: 'Delete',
                ),
              );
            },
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
      pollBuilder: (pollWidget) {
        return _defPollWidget(pollWidget, post);
      },
      onMediaTap: () async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();

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

        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );
  }

  Widget _defPollWidget(LMFeedPoll pollWidget, LMPostViewData postViewData) {
    Map<String, bool> isVoteEditing = {"value": false};
    LMAttachmentMetaViewData previousValue =
        pollWidget.attachmentMeta.copyWith();
    List<String> selectedOptions = [];
    final ValueNotifier<bool> rebuildPollWidget = ValueNotifier(false);
    return ValueListenableBuilder(
        valueListenable: rebuildPollWidget,
        builder: (context, _, __) {
          return LMFeedPoll(
            isVoteEditing: isVoteEditing["value"]!,
            selectedOption: selectedOptions,
            attachmentMeta: pollWidget.attachmentMeta,
            style: pollWidget.style,
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
              if (hasPollEnded(pollWidget.attachmentMeta.expiryTime!)) return;
              if ((isPollSubmitted(pollWidget.attachmentMeta.options ?? [])) &&
                  !isVoteEditing["value"]!) return;
              if (!isMultiChoicePoll(pollWidget.attachmentMeta.multiSelectNo!,
                  pollWidget.attachmentMeta.multiSelectState!)) {
                submitVote(
                  context,
                  pollWidget.attachmentMeta,
                  [optionData.id],
                  postViewData.id,
                  isVoteEditing,
                  previousValue,
                  rebuildPollWidget,
                  LMFeedWidgetSource.activityScreen,
                );
              } else if (selectedOptions.contains(optionData.id)) {
                selectedOptions.remove(optionData.id);
              } else {
                selectedOptions.add(optionData.id);
              }
              rebuildPollWidget.value = !rebuildPollWidget.value;
            },
            showSubmitButton: isVoteEditing["value"]! ||
                showSubmitButton(pollWidget.attachmentMeta),
            showEditVoteButton: !isVoteEditing["value"]! &&
                !isInstantPoll(pollWidget.attachmentMeta.pollType) &&
                !hasPollEnded(pollWidget.attachmentMeta.expiryTime!) &&
                isPollSubmitted(pollWidget.attachmentMeta.options ?? []),
            showAddOptionButton: showAddOptionButton(pollWidget.attachmentMeta),
            showTick: (option) {
              return showTick(pollWidget.attachmentMeta, option,
                  selectedOptions, isVoteEditing["value"]!);
            },
            timeLeft: getTimeLeftInPoll(pollWidget.attachmentMeta.expiryTime!),
            onAddOptionSubmit: (option) async {
              await addOption(
                context,
                pollWidget,
                pollWidget.attachmentMeta,
                option,
                postViewData.id,
                currentUser,
                rebuildPollWidget,
                LMFeedWidgetSource.activityScreen,
              );
              selectedOptions.clear();
              rebuildPollWidget.value = !rebuildPollWidget.value;
            },
            onSubtextTap: () {
              if (pollWidget.attachmentMeta.isAnonymous ?? false) {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    children: [
                      LMFeedText(
                        text:
                            'This being an anonymous poll, the names of the voters can not be disclosed.',
                        style: LMFeedTextStyle(
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 8,
                    ),
                  ),
                );
              } else if (pollWidget.attachmentMeta.toShowResult! ||
                  hasPollEnded(pollWidget.attachmentMeta.expiryTime!)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LMFeedPollResultScreen(
                      pollId: pollWidget.attachmentMeta.id ?? '',
                      pollOptions: pollWidget.attachmentMeta.options ?? [],
                    ),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    children: [
                      LMFeedText(
                        text:
                            'The results will be visible after the poll has ended.',
                        style: LMFeedTextStyle(
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 8,
                    ),
                  ),
                );
              }
            },
            onVoteClick: (option) {
              if (pollWidget.attachmentMeta.isAnonymous ?? false) {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    children: [
                      LMFeedText(
                        text:
                            'This being an anonymous poll, the names of the voters can not be disclosed.',
                        style: LMFeedTextStyle(
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 8,
                    ),
                  ),
                );
              } else if (pollWidget.attachmentMeta.toShowResult! ||
                  hasPollEnded(pollWidget.attachmentMeta.expiryTime!)) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LMFeedPollResultScreen(
                      pollId: pollWidget.attachmentMeta.id ?? '',
                      pollOptions: pollWidget.attachmentMeta.options ?? [],
                      selectedOptionId: option.id,
                    ),
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    children: [
                      LMFeedText(
                        text:
                            'The results will be visible after the poll has ended.',
                        style: LMFeedTextStyle(
                          maxLines: 3,
                          textAlign: TextAlign.center,
                          textStyle: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    ],
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 30,
                      horizontal: 8,
                    ),
                  ),
                );
              }
            },
            onSubmit: (options) {
              submitVote(
                context,
                pollWidget.attachmentMeta,
                options,
                postViewData.id,
                isVoteEditing,
                previousValue,
                rebuildPollWidget,
                LMFeedWidgetSource.activityScreen,
              );
              selectedOptions.clear();
              rebuildPollWidget.value = !rebuildPollWidget.value;
            },
          );
        });
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
                widgetSource: widgetSource,
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
          } else {
            if (postViewData.isLiked)
              LMFeedAnalyticsBloc.instance.add(
                LMFeedFireAnalyticsEvent(
                  eventName: LMFeedAnalyticsKeys.postLiked,
                  deprecatedEventName: LMFeedAnalyticsKeysDep.postLiked,
                  widgetSource: LMFeedWidgetSource.universalFeed,
                  eventProperties: {
                    'post_id': postViewData.id,
                    'created_by_id': postViewData.user.sdkClientInfo.uuid,
                    'topics': postViewData.topics.map((e) => e.name).toList(),
                  },
                ),
              );
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
          LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
              postId: postViewData.id,
              actionType: postViewData.isSaved
                  ? LMFeedPostActionType.unsaved
                  : LMFeedPostActionType.saved));
          postViewData.isSaved = !postViewData.isSaved;

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
                postId: postViewData.id,
                actionType: postViewData.isSaved
                    ? LMFeedPostActionType.unsaved
                    : LMFeedPostActionType.saved));
            postViewData.isSaved = !postViewData.isSaved;
          } else {
            LMFeedCore.showSnackBar(
              context,
              postViewData.isSaved
                  ? "$postTitleFirstCap Saved"
                  : "$postTitleFirstCap Unsaved",
              LMFeedWidgetSource.activityScreen,
            );
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
            color: feedTheme.primaryColor,
          ),
        ),
      ),
      style: feedTheme.commentStyle.showRepliesButtonStyle,
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
              title: 'Delete $commentTitleFirstCapSingular',
              uuid: commentCreatorUUID,
              widgetSource: widgetSource,
              content:
                  'Are you sure you want to delete this $commentTitleSmallCapSingular. This action can not be reversed.',
              action: (String reason) async {
                Navigator.of(childContext).pop();

                LMFeedAnalyticsBloc.instance.add(
                  LMFeedFireAnalyticsEvent(
                    eventName: LMFeedAnalyticsKeys.commentDeleted,
                    deprecatedEventName: LMFeedAnalyticsKeysDep.commentDeleted,
                    widgetSource: LMFeedWidgetSource.activityScreen,
                    eventProperties: {
                      "post_id": postViewData,
                      "comment_id": commentViewData.id,
                    },
                  ),
                );
              },
              actionText: 'Delete',
            ),
          );
        },
      );

  void navigateToLMFeedPostDetailsScreen(String postId) async {
    LMFeedVideoProvider.instance.pauseCurrentVideo();

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

    LMFeedVideoProvider.instance.playCurrentVideo();
  }

  void handlePostPinAction(LMPostViewData postViewData) async {
    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        postId: postViewData.id,
        actionType: postViewData.isPinned
            ? LMFeedPostActionType.unpinned
            : LMFeedPostActionType.pinned));
    postViewData.isPinned = !postViewData.isPinned;

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    if (!response.success) {
      LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
          postId: postViewData.id,
          actionType: postViewData.isPinned
              ? LMFeedPostActionType.unpinned
              : LMFeedPostActionType.pinned));

      postViewData.isPinned = !postViewData.isPinned;
    } else {
      String postType = LMFeedPostUtils.getPostType(postViewData.attachments);

      LMFeedAnalyticsBloc.instance.add(
        LMFeedFireAnalyticsEvent(
          eventName: postViewData.isPinned
              ? LMFeedAnalyticsKeys.postPinned
              : LMFeedAnalyticsKeys.postUnpinned,
          widgetSource: LMFeedWidgetSource.activityScreen,
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
