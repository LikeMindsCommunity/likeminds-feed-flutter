import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/edit_short_video/edit_short_video_screen.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/feed/comment_bottom_sheet.dart';

class LMFeedVideoFeedListView extends StatefulWidget {
  const LMFeedVideoFeedListView({
    super.key,
    this.pageSize = 10,
    this.feedType = LMFeedType.universal,
  });
  final int pageSize;
  final LMFeedType feedType;

  @override
  State<LMFeedVideoFeedListView> createState() =>
      _LMFeedVideoFeedListViewState();
}

class _LMFeedVideoFeedListViewState extends State<LMFeedVideoFeedListView> {
  final _theme = LMFeedCore.theme;
  final bool _isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();
  final _pagingController = PagingController<int, LMPostViewData>(
    firstPageKey: 1,
  );
  final _widgetSource = LMFeedWidgetSource.universalFeed;
  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();
  bool _isPostUploading = false;
  bool _isPostEditing = false;
  // bloc to handle universal feed
  final LMFeedUniversalBloc _universalFeedBloc = LMFeedUniversalBloc.instance;
  // bloc to handle personalised feed
  final LMFeedPersonalisedBloc _personalisedFeedBloc =
      LMFeedPersonalisedBloc.instance;
  // bloc to handle post creation, updation, deletion, etc.
  LMFeedPostBloc _postBloc = LMFeedPostBloc.instance;
  // Get the post title in first letter capital singular form
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  // Get the post title in all small singular form
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  // Get the post title in all small singular form
  String postTitleSmallCapPlural =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural);

  // Get the comment title in first letter capital plural form
  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  // Get the comment title in all small plural form
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  // Get the comment title in first letter capital singular form
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  // Get the comment title in all small singular form
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  Timer? _debounceTimer;
// function to handle scroll event with debounce
  void _handleSwipe() {
    if (_debounceTimer != null && _debounceTimer!.isActive) {
      _debounceTimer!.cancel();
    }
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      _callSeenPostEvent();
    });
  }

  // function to call the seen post event
  // with the seen post ids saved in the memory
  void _callSeenPostEvent() {
    List<String> seenPost = _personalisedFeedBloc.seenPost.toList();
    _personalisedFeedBloc
        .add(LMFeedPersonalisedSeenPostEvent(seenPost: seenPost));
  }

  @override
  void initState() {
    super.initState();
    LMFeedVideoProvider.instance.isMuted.value = false;
    _addPaginationListener();
    // Adds a feed opened event to the LMFeedAnalyticsBloc
    _addAnalyticsEvent();
  }

  // function to trigger the post seen event
  // when the feed is opened for the first time
  // with the seen post ids saved in the cache
  void _triggerPostSeenEvent() {
    LMResponse<List<String>> response =
        LMFeedPersistence.instance.getSeenPostIDs();
    if (response.success) {
      List<String> seenPostIds = response.data ?? [];
      HashSet<String> seenPost = HashSet<String>.from(seenPostIds);
      _personalisedFeedBloc
          .add(LMFeedPersonalisedSeenPostEvent(seenPost: seenPost.toList()));
    }
  }

  void _addAnalyticsEvent() {
    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.feedOpened,
        widgetSource: LMFeedWidgetSource.universalFeed,
        eventProperties: {
          'feed_type': 'universal_feed',
        },
      ),
    );
  }

  void _addPaginationListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        if (widget.feedType == LMFeedType.personalised) {
          debugPrint('Personalised feed page key: $pageKey');
          _personalisedFeedBloc.add(
            LMFeedPersonalisedGetEvent(
              pageKey: pageKey,
              pageSize: widget.pageSize,
            ),
          );
        } else {
          _universalFeedBloc.add(
            LMFeedGetUniversalFeedEvent(
              pageKey: pageKey,
              pageSize: widget.pageSize,
              topicsIds:
                  _universalFeedBloc.selectedTopics.map((e) => e.id).toList(),
            ),
          );
        }
      },
    );
  }

  // This function updates the paging controller based on the state changes
  void _universalBlocListener(
      BuildContext context, LMFeedUniversalState? state) {
    if (state is LMFeedUniversalFeedLoadedState) {
      List<LMPostViewData> listOfPosts = state.posts.copy();

      // remove post that do not have attachment type = reel
      // or they do not have any attachments.url
      listOfPosts.removeWhere((post) => !_isPostOfReelType(post));

      _universalFeedBloc.users.addAll(state.users);
      _universalFeedBloc.topics.addAll(state.topics);
      _universalFeedBloc.widgets.addAll(state.widgets);

      if (state.posts.length < widget.pageSize) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, state.pageKey + 1);
      }

      if (state.pageKey == 1) {
        _prepareInitializationForNextIndex(0);
      }
    } else if (state is LMFeedUniversalRefreshState) {
      clearPagingController();
      refresh();
    }
  }

  void _personalisedBlocListener(
      BuildContext context, LMFeedPersonalisedState? state) {
    if (state is LMFeedPersonalisedFeedLoadedState) {
      List<LMPostViewData> listOfPosts = state.posts.copy();

      // remove post that do not have attachment type = reel
      // or they do not have any attachments.url
      listOfPosts.removeWhere((post) => !_isPostOfReelType(post));
      if (state.posts.length < widget.pageSize) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, state.pageKey + 1);
      }

      if (state.pageKey == 1) {
        _prepareInitializationForNextIndex(0);
      }
    } else if (state is LMFeedPersonalisedRefreshState) {
      clearPagingController();
      refresh();
    }
  }

  void refresh() => _pagingController.refresh();

  // This function clears the paging controller
  // whenever user uses pull to refresh on feed screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
  }

  void _onPageChanged(int index) {
    if (widget.feedType == LMFeedType.personalised) {
      _handleSwipe();
    }
    _prepareInitializationForNextIndex(index);
  }

  void _prepareInitializationForNextIndex(int index) {
    if (index + 1 < _pagingController.itemList!.length) {
      final post = _pagingController.itemList![index + 1];
      // Build the request for the video controller
      LMFeedGetPostVideoControllerRequestBuilder requestBuilder =
          LMFeedGetPostVideoControllerRequestBuilder();

      requestBuilder.postId(post.id);
      final attachmentUrl = post.attachments?.first.attachmentMeta.url;
      // Set the video source based on the attachment metadata
      if (attachmentUrl != null) {
        requestBuilder
          ..autoPlay(false)
          ..videoSource(attachmentUrl)
          ..videoType(LMFeedVideoSourceType.network)
          ..position(0);
      }
      LMFeedVideoProvider.instance
          .videoControllerProvider(requestBuilder.build());
    }
    ;
  }

  bool _isPostOfReelType(LMPostViewData post) {
    return post.attachments?.any(
          (attachment) =>
              attachment.attachmentType == LMMediaType.reel &&
              attachment.attachmentMeta.url != null,
        ) ??
        false;
  }

  // This function returns the url of the first attachment
  // that is of type reel by checking the attachment type
  LMAttachmentViewData? _getFirstAttachmentOfTypeReel(LMPostViewData post) {
    // check where first attachment is of type reel
    // and has a url
    final attachment = post.attachments?.firstWhereOrNull(
      (element) =>
          element.attachmentType == LMMediaType.reel &&
          element.attachmentMeta.url != null,
    );
    return attachment;
  }

  @override
  Widget build(BuildContext context) {
    return widget.feedType == LMFeedType.universal
        ? _buildBlocListener<LMFeedUniversalBloc, LMFeedUniversalState>(
            _universalFeedBloc,
            _universalBlocListener,
          )
        : _buildBlocListener<LMFeedPersonalisedBloc, LMFeedPersonalisedState>(
            _personalisedFeedBloc,
            _personalisedBlocListener,
          );
  }

  Widget _buildBlocListener<B extends StateStreamable<S>, S>(
    B bloc,
    BlocWidgetListener<S> listener,
  ) {
    return BlocListener<B, S>(
      bloc: bloc,
      listener: listener,
      child: SafeArea(
        child: BlocConsumer<LMFeedPostBloc, LMFeedPostState>(
          bloc: _postBloc,
          listener: _postBlocListener,
          buildWhen: (previous, current) {
            if (current is LMFeedPostUpdateState) {
              if (current.actionType == LMFeedPostActionType.like ||
                  current.actionType == LMFeedPostActionType.unlike) {
                return false;
              }
            }
            return true;
          },
          builder: (context, state) {
            return _defBuilderView();
          },
        ),
      ),
    );
  }

  Stack _defBuilderView() {
    return Stack(
      alignment: AlignmentDirectional.bottomCenter,
      children: [
        RefreshIndicator.adaptive(
          onRefresh: () async {
            if (widget.feedType == LMFeedType.universal) {
              _universalFeedBloc.add(LMFeedUniversalRefreshEvent());
            } else {
              _personalisedFeedBloc.add(LMFeedPersonalisedRefreshEvent());
            }
          },
          child: _defPageView(),
        ),
        if (_isPostUploading || _isPostEditing) _defUploadingLoader()
      ],
    );
  }

  PagedPageView<int, LMPostViewData> _defPageView() {
    return PagedPageView<int, LMPostViewData>(
      onPageChanged: _onPageChanged,
      pagingController: _pagingController,
      scrollDirection: Axis.vertical,
      builderDelegate: PagedChildBuilderDelegate(
        noMoreItemsIndicatorBuilder: (context) {
          return _defAllCaughtUpView();
        },
        noItemsFoundIndicatorBuilder: (context) {
          return _defAllCaughtUpView();
        },
        itemBuilder: (context, item, index) {
          // add the post to the seen post ids
          // if it is a personalised feed
          if (widget.feedType == LMFeedType.personalised) {
            _personalisedFeedBloc.seenPost.add(item.id);
          }
          return _defVerticalVideoPostView(
            item,
            MediaQuery.of(context).size,
            context,
          );
        },
      ),
    );
  }

  Container _defUploadingLoader() {
    return Container(
      height: 56,
      margin: EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 26,
      ),
      padding: EdgeInsets.symmetric(
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: _theme.container,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            offset: Offset(0, -2),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          LMFeedLoader(
            style: LMFeedLoaderStyle(
              strokeWidth: 3,
              height: 24,
              width: 24,
            ),
          ),
          SizedBox(
            width: 16,
          ),
          LMFeedText(
            text: "${_isPostEditing ? "Saving" : "Posting"} reel",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: _theme.onContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Column _defAllCaughtUpView() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.check_circle_outline,
          style: LMFeedIconStyle(
            size: 56,
            color: _theme.onContainer,
          ),
        ),
        SizedBox(
          height: 24,
        ),
        LMFeedText(
          text: "You're All Caught Up",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: _theme.onContainer,
            ),
          ),
        ),
        SizedBox(
          height: 6,
        ),
        LMFeedText(
          text: "View older posts",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: _theme.primaryColor,
            ),
          ),
          onTap: () {
            if (widget.feedType == LMFeedType.universal) {
              _universalFeedBloc.add(LMFeedUniversalRefreshEvent());
            } else {
              _personalisedFeedBloc.add(LMFeedPersonalisedRefreshEvent());
            }
          },
        ),
      ],
    );
  }

  void _postBlocListener(BuildContext context, LMFeedPostState state) {
    if (state is LMFeedNewPostUploadingState) {
      _isPostUploading = true;
    }
    if (state is LMFeedEditPostUploadedState) {
      _isPostEditing = true;
    }
    if (state is LMFeedPostDeletedState) {
      // show a snackbar when post is deleted
      // will only be shown if a messenger key is provided
      LMFeedCore.showSnackBar(
        context,
        '$postTitleFirstCap Deleted',
        _widgetSource,
      );

      List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
      feedRoomItemList?.removeWhere((item) => item.id == state.postId);
      _pagingController.itemList = feedRoomItemList;
    }
    if (state is LMFeedNewPostUploadedState) {
      _isPostUploading = false;
      _pagingController.refresh();
      LMFeedCore.showSnackBar(
        context,
        '$postTitleFirstCap Created',
        _widgetSource,
      );
      // _scrollToTop();
    }
    if (state is LMFeedEditPostUploadedState) {
      _isPostEditing = false;
      LMPostViewData? item = state.postData.copyWith();
      List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
      int index =
          feedRoomItemList?.indexWhere((element) => element.id == item.id) ??
              -1;
      if (index != -1) {
        feedRoomItemList![index] = item;
      }
      if (widget.feedType == LMFeedType.universal) {
        _universalFeedBloc.users.addAll(state.userData);
        _universalFeedBloc.topics.addAll(state.topics);
      }

      LMFeedCore.showSnackBar(
          context, '$postTitleFirstCap Edited', _widgetSource);
    }
    if (state is LMFeedNewPostErrorState) {
      _isPostUploading = false;
      LMFeedCore.showSnackBar(
        context,
        state.errorMessage,
        _widgetSource,
      );
    }
    if (state is LMFeedPostUpdateState) {
      List<LMPostViewData>? feedRoomItemList = _pagingController.itemList;
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
    }
    if (state is LMFeedPostDeletionErrorState) {
      LMFeedCore.showSnackBar(
        context,
        state.message,
        _widgetSource,
      );
    }
  }

  Widget _defVerticalVideoPostView(
      LMPostViewData item, Size size, BuildContext context) {
    final attachment = _getFirstAttachmentOfTypeReel(item);
    return attachment != null
        ? Stack(
            alignment: Alignment.bottomLeft,
            children: [
              Container(
                height: double.infinity,
                color: Colors.black,
                child: Center(
                  child: LMFeedVideo(
                    postId: item.id,
                    video: attachment,
                    autoPlay: true,
                    style: LMFeedPostVideoStyle.basic().copyWith(
                      allowMuting: false,
                    ),
                  ),
                ),
              ),
              // user view
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: size.width - 68,
                        maxHeight: size.height * 0.5,
                      ),
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _defPostHeader(item),
                            LMFeedPostTopic(
                              topics: item.topics,
                              post: item,
                              style: LMFeedPostTopicStyle.basic().copyWith(
                                maxTopicsToShow: 3,
                              ),
                              onMoreTopicsTap: (context, topics) {
                                showModalBottomSheet(
                                  showDragHandle: true,
                                  context: context,
                                  builder: (context) {
                                    return BottomSheet(
                                      onClosing: () {},
                                      builder: (context) {
                                        return Column(
                                          children: [
                                            LMFeedText(
                                              text: "Topics",
                                              style: LMFeedTextStyle(
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 16),
                                            Expanded(
                                              child: ListView.builder(
                                                itemCount: topics.length,
                                                itemBuilder: (context, index) {
                                                  return ListTile(
                                                    title: Text(
                                                        topics[index].name),
                                                  );
                                                },
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                            _defPostContent(item),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          BlocBuilder<LMFeedPostBloc, LMFeedPostState>(
                            bloc: _postBloc,
                            builder: (context, state) {
                              return _defLikeButton(item);
                            },
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          _defCommentButton(
                            item,
                          ),
                          SizedBox(
                            height: 16,
                          ),
                          _defMenu(context, item),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ],
          )
        : SizedBox();
  }

  LMFeedPostContent _defPostContent(LMPostViewData item) {
    return LMFeedPostContent(
      text: item.text,
      style: LMFeedPostContentStyle(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        headingSeparator: const SizedBox(height: 0.0),
        visibleLines: 2,
        headingStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: _theme.container,
          shadows: [
            Shadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        textStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: _theme.container,
          shadows: [
            Shadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
        expandTextStyle: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: _theme.container,
          shadows: [
            Shadow(
              color: Colors.grey.withOpacity(0.1),
              offset: Offset(0, 2),
              blurRadius: 4,
            ),
          ],
        ),
      ),
    );
  }

  LMFeedPostHeader _defPostHeader(LMPostViewData postViewData) {
    return LMFeedPostHeader(
      createdAtBuilder: (context, text) {
        return text.copyWith(
            style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ));
      },
      user: postViewData.user,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: LMFeedPostHeaderStyle.basic().copyWith(
        showMenu: false,
        titleTextStyle: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
        subTextStyle: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
    );
  }

  LMFeedMenu _defMenu(BuildContext context, LMPostViewData postViewData) {
    return LMFeedMenu(
      menuItems: postViewData.menuItems,
      style: LMFeedMenuStyle(
          menuType: LMFeedPostMenuType.bottomSheet,
          showBottomSheetTitle: false,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(16),
          ),
          menuIcon: LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: Icons.more_horiz,
            style: LMFeedIconStyle(
              size: 32,
              color: _theme.container,
            ),
          ),
          menuTitleStyle: (menuId, titleStyle) {
            return titleStyle?.copyWith(
              textStyle: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: menuId == LMFeedMenuAction.postDeleteId ||
                        menuId == LMFeedMenuAction.postReportId
                    ? _theme.errorColor
                    : _theme.onContainer,
              ),
            );
          }),
      removeItemIds: {},
      onMenuOpen: () {
        LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
          eventName: LMFeedAnalyticsKeys.postMenu,
          eventProperties: {
            'uuid': postViewData.user.sdkClientInfo.uuid,
            'post_id': postViewData.id,
            'topics': postViewData.topics.map((e) => e.name).toList(),
            'post_type': LMFeedPostUtils.getPostType(postViewData.attachments),
          },
        ));
      },
      action: LMFeedMenuAction(
        onPostEdit: () => _onPostEdit(postViewData),
        onPostReport: () => LMFeedDefaultWidgets.instance
            .handlePostReportAction(postViewData, context),
        onPostUnpin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
        onPostPin: () => LMFeedPostUtils.handlePostPinAction(postViewData),
        onPostDelete: () => _onPostDelete(postViewData),
      ),
      menuItemBuilderForBottomSheet: (context, menuItem, menuData) {
        return menuItem.copyWith(
          leading: _getMenuIcon(menuData),
        );
      },
    );
  }

  LMFeedIcon? _getMenuIcon(LMPopUpMenuItemViewData menuData) {
    IconData? iconData;
    Color iconColor = _theme.onContainer;
    switch (menuData.id) {
      case LMFeedMenuAction.postEditId:
        iconData = Icons.edit_outlined;
        break;
      case LMFeedMenuAction.postDeleteId:
        iconData = Icons.delete_outline;
        iconColor = _theme.errorColor;
        break;
      case LMFeedMenuAction.postReportId:
        iconData = Icons.report_outlined;
        iconColor = _theme.errorColor;
        break;
    }
    return iconData != null
        ? LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: iconData,
            style: LMFeedIconStyle(
              size: 24,
              color: iconColor,
            ),
          )
        : null;
  }

  void _onPostDelete(LMPostViewData postViewData) {
    String postCreatorUUID = postViewData.user.sdkClientInfo.uuid;
    showDialog(
      context: context,
      builder: (childContext) => LMFeedDeleteConfirmationDialog(
        title: 'Delete $postTitleFirstCap?',
        uuid: postCreatorUUID,
        widgetSource: _widgetSource,
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
              userState: _isCm ? "CM" : "member",
            ),
          );
        },
        actionText: 'Delete',
      ),
    );
  }

  void _onPostEdit(LMPostViewData postViewData) {
    // Mute all video controllers
    // to prevent video from playing in background
    // while editing the post
    LMFeedVideoProvider.instance.forcePauseAllControllers();

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => LMFeedEditShortVideoScreen(
          postId: postViewData.id,
        ),
      ),
    );
  }

  LMFeedButton _defLikeButton(LMPostViewData postViewData) {
    return LMFeedButton(
      text: LMFeedText(
        text: postViewData.likeCount.toString(),
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
      isActive: postViewData.isLiked,
      onTap: () async {
        // check if the user is a guest user
        if (LMFeedUserUtils.isGuestUser()) {
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
          return;
        }
        _postBloc.add(LMFeedUpdatePostEvent(
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
          _postBloc.add(LMFeedUpdatePostEvent(
            actionType: postViewData.isLiked
                ? LMFeedPostActionType.unlike
                : LMFeedPostActionType.like,
            postId: postViewData.id,
          ));
        } else {
          LMFeedPostUtils.handlePostLikeTapEvent(
              postViewData, _widgetSource, postViewData.isLiked);
        }
      },
      onTextTap: () {
        // check if the user is a guest user
        if (LMFeedUserUtils.isGuestUser()) {
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
          return;
        }
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          builder: (context) {
            return BottomSheet(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.4,
                ),
                onClosing: () {},
                builder: (context) {
                  return Column(
                    children: [
                      LMFeedText(
                        text: "Liked",
                        style: LMFeedTextStyle(
                          textStyle: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: LMFeedLikeListView(
                          postId: postViewData.id,
                          widgetSource: _widgetSource,
                        ),
                      ),
                    ],
                  );
                });
          },
        );
      },
      style: LMFeedButtonStyle(
        direction: Axis.vertical,
        gap: 0,
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmLikeInActiveSvg,
          style: LMFeedIconStyle(
            size: 32,
            fit: BoxFit.contain,
            color: _theme.container,
          ),
        ),
        activeIcon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmLikeActiveSvg,
          style: LMFeedIconStyle(
            size: 32,
            fit: BoxFit.contain,
          ),
        ),
        borderRadius: 100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(
              0.1,
            ),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
    );
  }

  LMFeedButton _defCommentButton(LMPostViewData postViewData) {
    final LMFeedButton commentButton = LMFeedButton(
      isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
      text: LMFeedText(
        text: postViewData.commentCount.toString(),
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: _theme.container,
            shadows: [
              Shadow(
                color: Colors.grey.withOpacity(0.1),
                offset: Offset(0, 2),
                blurRadius: 4,
              ),
            ],
          ),
        ),
      ),
      style: LMFeedButtonStyle(
        direction: Axis.vertical,
        icon: LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: lmCommentSvg,
          style: LMFeedIconStyle(
            size: 32,
            color: _theme.container,
          ),
        ),
        borderRadius: 100,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(
              0.1,
            ),
            offset: Offset(0, 2),
            blurRadius: 4,
          ),
        ],
      ),
      onTap: () async {
        LMFeedPostUtils.handlePostCommentButtonTap(postViewData, _widgetSource);

        LMFeedVideoProvider.instance.pauseCurrentVideo();

        showModalBottomSheet(
          context: context,
          showDragHandle: true,
          isScrollControlled: true,
          builder: (context) {
            return LMFeedCommentBottomSheet(
              postId: postViewData.id,
            );
          },
        );
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
    );

    return commentButton;
  }
}
