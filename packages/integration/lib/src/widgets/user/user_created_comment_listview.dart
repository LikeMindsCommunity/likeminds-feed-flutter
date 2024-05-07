import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/user_created_comment/user_created_comment_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/views/poll/handler/poll_handler.dart';
import 'package:likeminds_feed_flutter_core/src/views/poll/poll_result_screen.dart';

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
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  String commentTitleSmallPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();

  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  static const int pageSize = 10;
  final PagingController<int, LMCommentViewData> _pagingController =
      PagingController(firstPageKey: 1);
  LMUserViewData? userViewData = LMFeedLocalPreference.instance.fetchUserData();
  bool userPostingRights = LMFeedUserUtils.checkPostCreationRights();
  LMFeedThemeData? feedThemeData;
  final ValueNotifier postUploading = ValueNotifier(false);
  final LMFeedUserCreatedCommentBloc _userCreatedCommentBloc =
      LMFeedUserCreatedCommentBloc();
  final Map<String, LMPostViewData> _posts = {};
  LMFeedPostBloc lmFeedPostBloc = LMFeedPostBloc.instance;
  LMFeedWidgetSource widgetSource = LMFeedWidgetSource.userCreatedCommentScreen;
  LMUserViewData currentUser = LMFeedLocalPreference.instance.fetchUserData()!;

  @override
  void initState() {
    super.initState();
    addPageRequestListener();
  }

  void addPageRequestListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _userCreatedCommentBloc.add(
          LMFeedGetUserCreatedCommentEvent(
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
  void updatePagingControllers(LMFeedUserCreatedCommentLoadedState state) {
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
            _posts[state.postData.id] = state.postData.copyWith();

            rebuildPostWidget.value = !rebuildPostWidget.value;
          }
          if (state is LMFeedPostUpdateState) {
            LMPostViewData? post = _posts[state.postId];

            if (post != null) {
              post = LMFeedPostUtils.updatePostData(
                  postViewData: post, actionType: state.actionType);
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
                  if (state is LMFeedUserCreatedCommentLoadedState) {
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
                                  context, postWidget, _posts[item.postId]!,
                                  source: widgetSource),
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
              postBuilder: widget.postBuilder,
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
      pollBuilder: (pollWidget) => _defPollWidget(pollWidget, post),
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
                debugPrint("ye wala");
                submitVote(
                  context,
                  pollWidget.attachmentMeta,
                  [optionData.id],
                  postViewData.id,
                  isVoteEditing,
                  previousValue,
                  rebuildPollWidget,
                  LMFeedWidgetSource.userCreatedCommentScreen,
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
                LMFeedWidgetSource.userCreatedCommentScreen,
              );
              selectedOptions.clear();
              rebuildPollWidget.value = !rebuildPollWidget.value;
            },
            onSubtextTap: () {
              if (pollWidget.attachmentMeta.isAnonymous ?? false) {
                showDialog(
                  context: context,
                  builder: (context) => SimpleDialog(
                    surfaceTintColor: Colors.transparent,
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
                    surfaceTintColor: Colors.transparent,
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
                    surfaceTintColor: Colors.transparent,
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
                    surfaceTintColor: Colors.transparent,
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
                LMFeedWidgetSource.userCreatedCommentScreen,
              );
              selectedOptions.clear();
              rebuildPollWidget.value = !rebuildPollWidget.value;
            },
          );
        });
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
                  title: 'Delete $postTitleFirstCap',
                  uuid: postViewData.uuid,
                  widgetSource: widgetSource,
                  content:
                      'Are you sure you want to delete this $postTitleSmallCap. This action can not be reversed.',
                  action: (String reason) async {
                    Navigator.of(childContext).pop();

                    String postType =
                        LMFeedPostUtils.getPostType(postViewData.attachments);

                    lmFeedPostBloc.add(
                      LMFeedDeletePostEvent(
                        postId: postViewData.id,
                        reason: reason,
                        isRepost: postViewData.isRepost,
                        userId: postViewData.user.sdkClientInfo.uuid,
                        postType: postType,
                        userState: isCm ? "CM" : "member",
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
                widgetSource: widgetSource,
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

          final LikePostResponse response =
              await LMFeedCore.client.likePost(likePostRequest);

          if (!response.success) {
            lmFeedPostBloc.add(LMFeedUpdatePostEvent(
              actionType: postViewData.isLiked
                  ? LMFeedPostActionType.unlike
                  : LMFeedPostActionType.like,
              postId: postViewData.id,
            ));
          } else {
            if (postViewData.isLiked)
              LMFeedAnalyticsBloc.instance.add(
                LMFeedFireAnalyticsEvent(
                  eventName: LMFeedAnalyticsKeys.postLiked,
                  deprecatedEventName: LMFeedAnalyticsKeysDep.postLiked,
                  widgetSource: widgetSource,
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

  LMFeedButton defCommentButton(LMPostViewData post) => LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(post.commentCount),
        ),
        style: feedThemeData?.footerStyle.commentButtonStyle,
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
              context,
              postViewData.isSaved
                  ? "$postTitleFirstCap Saved"
                  : "$postTitleFirstCap Unsaved",
              widgetSource,
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
                  widgetSource: LMFeedWidgetSource.userCreatedCommentScreen,
                ),
              ),
            );
          } else {
            LMFeedCore.showSnackBar(context,
                'A $postTitleSmallCap is already uploading.', widgetSource);
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
            LMFeedText(
              text: 'No $commentTitleSmallPlural to show',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
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
          widgetSource: widgetSource,
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
