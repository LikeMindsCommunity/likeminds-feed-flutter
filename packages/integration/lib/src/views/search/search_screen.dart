import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:async/async.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';
import 'package:likeminds_feed_flutter_core/src/utils/web/feed_web_configuration.dart';

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
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  LMFeedThemeData theme = LMFeedCore.theme;
  LMFeedWidgetUtility widgetUtility = LMFeedCore.widgetUtility;
  LMFeedWidgetSource widgetSource = LMFeedWidgetSource.searchScreen;
  ValueNotifier<bool> showCancelIcon = ValueNotifier<bool>(false);
  TextEditingController searchController = TextEditingController();
  CancelableOperation? _debounceOperation;
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
  LMFeedSearchBloc searchBloc = LMFeedSearchBloc();
  ValueNotifier<bool> postUploading = ValueNotifier<bool>(false);
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier<bool>(false);
  // check whether current logged in user is CM or not
  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  FocusNode focusNode = FocusNode();
  LMUserViewData currentUser = LMFeedLocalPreference.instance.fetchUserData()!;
  final PagingController<int, LMPostViewData> _pagingController =
      PagingController(firstPageKey: 1);
  bool userPostingRights = true;
  int page = 1;
  int pageSize = 10;
  late Size screenSize;
  double? screenWidth;
  bool isWeb = LMFeedPlatform.instance.isWeb();

  LMFeedWebConfiguration webConfig = LMFeedCore.webConfiguration;
  bool isDesktopWeb = false;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenSize = MediaQuery.sizeOf(context);
    if (screenSize.width > webConfig.maxWidth && kIsWeb) {
      isDesktopWeb = true;
    } else {
      isDesktopWeb = false;
    }
  }

  @override
  void initState() {
    super.initState();
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();
    addPageRequestListener();
    searchController.addListener(() {
      _onTextChanged(searchController.text);
    });

    if (focusNode.canRequestFocus) {
      focusNode.requestFocus();
    }

    // Fire analytics for search screen opened event
    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.searchScreenOpened,
        eventProperties: {
          LMFeedAnalyticsKeys.userIdKey: currentUser.sdkClientInfo.uuid
        }));
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
    focusNode.dispose();
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
    screenWidth = min(LMFeedCore.webConfiguration.maxWidth, screenSize.width);
    return widgetUtility.scaffold(
      source: widgetSource,
      resizeToAvoidBottomInset: false,
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: theme.container,
        foregroundColor: theme.onContainer,
        title: TextField(
          controller: searchController,
          focusNode: focusNode,
          onChanged: _onTextChanged,
          cursorColor: theme.primaryColor,
          decoration: InputDecoration(
            hintText: 'Search...',
            hintStyle: TextStyle(color: theme.onContainer.withOpacity(0.5)),
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
          ),
          style: TextStyle(color: theme.onContainer),
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
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: screenWidth,
          child: BlocListener(
            bloc: newPostBloc,
            listener: (context, state) {
              if (state is LMFeedNewPostErrorState) {
                postUploading.value = false;
                LMFeedCore.showSnackBar(
                  context,
                  state.errorMessage,
                  widgetSource,
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
                if (feedRoomItemList.isNotEmpty &&
                    feedRoomItemList.length > 10) {
                  feedRoomItemList.removeLast();

                  postUploading.value = false;
                  rebuildPostWidget.value = !rebuildPostWidget.value;
                } else {
                  postUploading.value = false;
                  rebuildPostWidget.value = !rebuildPostWidget.value;
                }
              }
              if (state is LMFeedPostDeletedState) {
                List<LMPostViewData>? feedRoomItemList =
                    _pagingController.itemList;
                feedRoomItemList
                    ?.removeWhere((item) => item.id == state.postId);
                _pagingController.itemList = feedRoomItemList;
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }

              if (state is LMFeedEditPostUploadedState) {
                LMPostViewData? item = state.postData.copyWith();
                List<LMPostViewData>? feedRoomItemList =
                    _pagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == item.id) ??
                    -1;
                if (index != -1) {
                  feedRoomItemList?[index] = item;
                }

                rebuildPostWidget.value = !rebuildPostWidget.value;
              }

              if (state is LMFeedPostUpdateState) {
                List<LMPostViewData>? feedRoomItemList =
                    _pagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == state.postId) ??
                    -1;

                if (index != -1) {
                  feedRoomItemList![index] = LMFeedPostUtils.updatePostData(
                    postViewData: state.post ?? feedRoomItemList[index],
                    actionType: state.actionType,
                    commentId: state.commentId,
                    pollOptions: state.pollOptions,
                  );
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
                  LMFeedCore.showSnackBar(
                    context,
                    state.message,
                    widgetSource,
                  );
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
                          padding:
                              isDesktopWeb ? EdgeInsets.only(top: 20) : null,
                          builderDelegate:
                              PagedChildBuilderDelegate<LMPostViewData>(
                            noItemsFoundIndicatorBuilder: (context) {
                              return widget.emptyFeedViewBuilder
                                      ?.call(context) ??
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
                                          source: widgetSource),
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
        ),
      ),
    );
  }

  Widget getLoaderThumbnail(LMAttachmentViewData? media) {
    if (media != null) {
      if (media.attachmentType == LMMediaType.image) {
        return Container(
          height: 50,
          width: 50,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: LMFeedImage(
            image: media,
            style: const LMFeedPostImageStyle(
              boxFit: BoxFit.contain,
            ),
          ),
        );
      } else if (media.attachmentType == LMMediaType.document) {
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
      onMediaTap: (int index) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: post.user,
              position: index,
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

  LMFeedPostTopic _defTopicWidget(LMPostViewData postViewData) {
    return LMFeedPostTopic(
      topics: postViewData.topics,
      post: postViewData,
      style: theme.topicStyle,
      onTopicTap: (context, topicViewData) =>
          LMFeedPostUtils.handlePostTopicTap(
              context, postViewData, topicViewData, widgetSource),
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
      onProfileNameTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, widgetSource),
      onProfilePictureTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, widgetSource),
      menuBuilder: (menu) {
        return menu.copyWith(
          removeItemIds: {postReportId, postEditId},
          onMenuOpen: () {
            LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
              eventName: LMFeedAnalyticsKeys.postMenu,
              eventProperties: {
                'uuid': postViewData.user.sdkClientInfo.uuid,
                'post_id': postViewData.id,
                'topics': postViewData.topics.map((e) => e.name).toList(),
                'post_type':
                    LMFeedPostUtils.getPostType(postViewData.attachments),
              },
            ));
          },
          action: LMFeedMenuAction(
            onPostReport: () => handlePostReportAction(postViewData),
            onPostUnpin: () =>
                LMFeedPostUtils.handlePostPinAction(postViewData),
            onPostPin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
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

                    LMFeedPostBloc.instance.add(
                      LMFeedDeletePostEvent(
                        postId: postViewData.id,
                        reason: reason,
                        isRepost: postViewData.isRepost,
                        postType: postType,
                        userState: isCm ? "CM" : "member",
                        userId: postViewData.user.sdkClientInfo.uuid,
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
      pollBuilder: widgetUtility.pollWidgetBuilder,
      poll: _defPollWidget(post),
      onMediaTap: (int index) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: post.user,
              position: index,
            ),
          ),
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );
  }

  LMFeedPoll? _defPollWidget(LMPostViewData postViewData) {
    Map<String, bool> isVoteEditing = {"value": false};
    if (postViewData.attachments == null || postViewData.attachments!.isEmpty) {
      return null;
    }
    bool isPoll = false;
    postViewData.attachments?.forEach((element) {
      if (element.attachmentType == LMMediaType.poll) {
        isPoll = true;
      }
    });

    if (!isPoll) {
      return null;
    }

    LMAttachmentMetaViewData pollValue =
        postViewData.attachments!.first.attachmentMeta;
    LMAttachmentMetaViewData previousValue = pollValue.copyWith();
    List<String> selectedOptions = [];
    final ValueNotifier<bool> rebuildPollWidget = ValueNotifier(false);
    return LMFeedPoll(
      rebuildPollWidget: rebuildPollWidget,
      isVoteEditing: isVoteEditing["value"]!,
      selectedOption: selectedOptions,
      attachmentMeta: pollValue,
      style: theme.mediaStyle.pollStyle ??
          LMFeedPollStyle.basic(
              primaryColor: theme.primaryColor,
              containerColor: theme.container),
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
        if (hasPollEnded(pollValue.expiryTime)) {
          LMFeedCore.showSnackBar(
            context,
            "Poll ended. Vote can not be submitted now.",
            LMFeedWidgetSource.universalFeed,
          );
          return;
        }
        if ((isPollSubmitted(pollValue.options ?? [])) &&
            !isVoteEditing["value"]!) return;
        if (!isMultiChoicePoll(
            pollValue.multiSelectNo, pollValue.multiSelectState)) {
          submitVote(
            context,
            pollValue,
            [optionData.id],
            postViewData.id,
            isVoteEditing,
            previousValue,
            rebuildPostWidget,
            LMFeedWidgetSource.universalFeed,
          );
        } else if (selectedOptions.contains(optionData.id)) {
          selectedOptions.remove(optionData.id);
        } else {
          selectedOptions.add(optionData.id);
        }
        rebuildPollWidget.value = !rebuildPollWidget.value;
      },
      showSubmitButton: isVoteEditing["value"]! || showSubmitButton(pollValue),
      showEditVoteButton: !isVoteEditing["value"]! &&
          !isInstantPoll(pollValue.pollType) &&
          !hasPollEnded(pollValue.expiryTime) &&
          isPollSubmitted(pollValue.options ?? []),
      showAddOptionButton: showAddOptionButton(pollValue),
      showTick: (option) {
        return showTick(
            pollValue, option, selectedOptions, isVoteEditing["value"]!);
      },
      isMultiChoicePoll: isMultiChoicePoll(
          pollValue.multiSelectNo, pollValue.multiSelectState),
      pollSelectionText: getPollSelectionText(
          pollValue.multiSelectState, pollValue.multiSelectNo),
      timeLeft: getTimeLeftInPoll(pollValue.expiryTime),
      onSameOptionAdded: () {
        LMFeedCore.showSnackBar(
          context,
          "Option already exists",
          LMFeedWidgetSource.universalFeed,
        );
      },
      onAddOptionSubmit: (option) async {
        await addOption(
          context,
          pollValue,
          option,
          postViewData.id,
          currentUser,
          rebuildPollWidget,
          LMFeedWidgetSource.universalFeed,
        );
        selectedOptions.clear();
        rebuildPollWidget.value = !rebuildPollWidget.value;
      },
      onSubtextTap: () {
        onVoteTextTap(
          context,
          pollValue,
          LMFeedWidgetSource.universalFeed,
        );
      },
      onVoteClick: (option) {
        onVoteTextTap(
          context,
          pollValue,
          LMFeedWidgetSource.universalFeed,
          option: option,
        );
      },
      onSubmit: (options) {
        submitVote(
          context,
          pollValue,
          options,
          postViewData.id,
          isVoteEditing,
          previousValue,
          rebuildPostWidget,
          LMFeedWidgetSource.universalFeed,
        );
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
          if (postViewData.likeCount == 0) {
            return;
          }

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
          rebuildPostWidget.value = !rebuildPostWidget.value;

          final likePostRequest =
              (LikePostRequestBuilder()..postId(postViewData.id)).build();

          final LikePostResponse response =
              await LMFeedCore.client.likePost(likePostRequest);

          if (!response.success) {
            postViewData.isLiked = !postViewData.isLiked;
            postViewData.likeCount = postViewData.isLiked
                ? postViewData.likeCount + 1
                : postViewData.likeCount - 1;
            rebuildPostWidget.value = !rebuildPostWidget.value;
          } else {
            LMFeedPostUtils.handlePostLikeTapEvent(
                postViewData, widgetSource, postViewData.isLiked);
          }
        },
      );

  LMFeedButton defCommentButton(LMPostViewData post) => LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(post.commentCount),
        ),
        style: theme.footerStyle.commentButtonStyle,
        onTap: () async {
          // Handle analytics event for comment button tap
          LMFeedPostUtils.handlePostCommentButtonTap(post, widgetSource);

          // Pause any video controller if playing
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
          } else {
            LMFeedPostUtils.handlePostSaveTapEvent(
                postViewData, postViewData.isSaved, widgetSource);
            LMFeedCore.showSnackBar(
              context,
              postViewData.isSaved
                  ? "$postTitleFirstCap Saved"
                  : "$postTitleFirstCap Unsaved",
              widgetSource,
            );
          }
        },
        style: theme.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(LMPostViewData postViewData) => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          // Fire analytics event for share button tap
          LMFeedPostUtils.handlerPostShareTapEvent(postViewData, widgetSource);

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
            LMFeedVideoProvider.instance.forcePauseAllControllers();
            // ignore: use_build_context_synchronously
            LMAttachmentViewData attachmentViewData =
                (LMAttachmentViewDataBuilder()
                      ..attachmentType(LMMediaType.repost)
                      ..attachmentMeta((LMAttachmentMetaViewDataBuilder()
                            ..repost(postViewData))
                          .build()))
                    .build();
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LMFeedComposeScreen(
                  attachments: [attachmentViewData],
                  widgetSource: LMFeedWidgetSource.searchScreen,
                ),
              ),
            );
          } else {
            LMFeedCore.showSnackBar(
              context,
              'A $postTitleSmallCap is already uploading.',
              widgetSource,
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
            LMFeedText(
              text:
                  'No ${LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural)} to show',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            LMFeedText(
              text: "Be the first one to create a $postTitleSmallCap here",
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
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                placement: LMFeedIconButtonPlacement.end,
              ),
              text: LMFeedText(
                text: "Create $postTitleFirstCap",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: userPostingRights
                  ? () async {
                      if (!postUploading.value) {
                        LMFeedVideoProvider.instance.pauseCurrentVideo();
                        // ignore: use_build_context_synchronously
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LMFeedComposeScreen(
                              widgetSource: LMFeedWidgetSource.searchScreen,
                            ),
                          ),
                        );
                        LMFeedVideoProvider.instance.playCurrentVideo();
                      } else {
                        LMFeedCore.showSnackBar(
                          context,
                          'A $postTitleSmallCap is already uploading.',
                          widgetSource,
                        );
                      }
                    }
                  : () => LMFeedCore.showSnackBar(
                        context,
                        "You do not have permission to create a $postTitleSmallCap",
                        widgetSource,
                      ),
            ),
          ],
        ),
      );

  void handlePostReportAction(LMPostViewData postViewData) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LMFeedReportScreen(
          entityId: postViewData.id,
          entityType: postEntityId,
          entityCreatorId: postViewData.user.uuid,
        ),
      ),
    );
  }
}
