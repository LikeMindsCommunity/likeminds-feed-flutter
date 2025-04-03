import 'dart:async';
import 'dart:collection';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedVideoFeedListView extends StatefulWidget {
  const LMFeedVideoFeedListView({
    super.key,
    this.pageSize = 10,
    this.feedType = LMFeedType.universal,
    this.startFeedWithPostIds,
  });
  final int pageSize;
  final LMFeedType feedType;
  final List<String>? startFeedWithPostIds;

  @override
  State<LMFeedVideoFeedListView> createState() =>
      _LMFeedVideoFeedListViewState();
}

class _LMFeedVideoFeedListViewState extends State<LMFeedVideoFeedListView>
    with WidgetsBindingObserver {
  final _theme = LMFeedCore.theme;
  final _screenBuilder = LMFeedCore.config.videoFeedScreenConfig.builder;
  final _pagingController = PagingController<int, LMPostViewData>(
    firstPageKey: 1,
  );
  final _widgetSource = LMFeedWidgetSource.universalFeed;
  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();
  bool _isPostUploading = false;
  bool _isPostEditing = false;
  bool _isPostUploadingFailed = false;
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
  final _currentUser = LMFeedLocalPreference.instance.fetchUserData();

  Timer? _debounceTimer;

  // function to handle swipe event with debounce
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
    WidgetsBinding.instance.addObserver(this);
    _postBloc.add(LMFeedFetchTempPostEvent());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    // play current video when app is resumed
    if (state == AppLifecycleState.resumed) {
      LMFeedVideoProvider.instance.playCurrentVideo();
    } else {
      // pause current video when app is paused
      LMFeedVideoProvider.instance.pauseCurrentVideo();
    }
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
              startFeedWithPostIds: widget.startFeedWithPostIds,
            ),
          );
        } else {
          _universalFeedBloc.add(
            LMFeedGetUniversalFeedEvent(
              pageKey: pageKey,
              pageSize: widget.pageSize,
              topicsIds:
                  _universalFeedBloc.selectedTopics.map((e) => e.id).toList(),
              startFeedWithPostIds: widget.startFeedWithPostIds,
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

      // check if the post is in same ordered as the [startFeedWithPostIds]
      // if not show a snackbar
      if (widget.startFeedWithPostIds != null &&
          widget.startFeedWithPostIds!.isNotEmpty) {
        LMFeedPostUtils.checkForPostDeletionErrorState(
          context,
          postTitleFirstCap,
          listOfPosts,
          widget.startFeedWithPostIds!,
          _widgetSource,
        );
      }

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
        _triggerPostSeenEvent();
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

      // check if the post is in same ordered as the [startFeedWithPostIds]
      // if not show a snackbar
      if (widget.startFeedWithPostIds != null &&
          widget.startFeedWithPostIds!.isNotEmpty) {
        LMFeedPostUtils.checkForPostDeletionErrorState(
          context,
          postTitleFirstCap,
          listOfPosts,
          widget.startFeedWithPostIds!,
          _widgetSource,
        );
      }

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
    // check if index is in the range of the list
    if (index < 0 || index >= (_pagingController.itemList?.length ?? 0)) {
      return;
    }
    // set current video id and position to media provider
    LMFeedVideoProvider.instance.currentVisiblePostId =
        _pagingController.itemList?[index].id;
    LMFeedVideoProvider.instance.currentVisiblePostPosition = 0;
    if (widget.feedType == LMFeedType.personalised) {
      _handleSwipe();
    }
    _prepareInitializationForNextIndex(index);

    // fire analytics event for reel swiped
    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.reelSwiped,
        widgetSource: LMFeedWidgetSource.videoFeed,
        eventProperties: {
          'uuid': _currentUser?.uuid,
          'previous_reel_id': _pagingController.itemList?[index].id,
        },
      ),
    );
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
            return _defBuilderView(state);
          },
        ),
      ),
    );
  }

  Stack _defBuilderView(LMFeedPostState state) {
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
          child: _screenBuilder.pageViewBuilder(
            context,
            _defPageView(),
          ),
        ),
        if (_isPostUploading || _isPostEditing)
          _screenBuilder.uploadingPostContentBuilder(
            context,
            _defUploadingLoader(state),
            _defLoaderForUploading(),
            _defUploadingText(),
            _isPostUploading,
            _isPostEditing,
          ),
        if (_isPostUploadingFailed) _defUploadingLoader(state),
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
          return _screenBuilder.noMoreItemsIndicatorBuilder(
            context,
            _defAllCaughtUpView(),
          );
        },
        noItemsFoundIndicatorBuilder: (context) {
          return _screenBuilder.noItemIndicatorBuilder(
            context,
            _defAllCaughtUpView(),
          );
        },
        firstPageProgressIndicatorBuilder: (context) {
          return _screenBuilder.firstPageProgressIndicatorBuilder(
            context,
            LMFeedLoader(),
          );
        },
        newPageProgressIndicatorBuilder: (context) {
          return _screenBuilder.newPageProgressIndicatorBuilder(
            context,
            LMFeedLoader(),
          );
        },
        firstPageErrorIndicatorBuilder:
            _screenBuilder.firstPageErrorIndicatorBuilder(context),
        newPageErrorIndicatorBuilder:
            _screenBuilder.newPageErrorIndicatorBuilder(context),
        itemBuilder: (context, item, index) {
          // add the post to the seen post ids
          // if it is a personalised feed
          if (widget.feedType == LMFeedType.personalised) {
            _personalisedFeedBloc.seenPost.add(item.id);
          }
          return _screenBuilder.postViewBuilder(
            context,
            LMFeedVerticalVideoPost(
              postViewData: item,
            ),
            item,
          );
        },
      ),
    );
  }

  Container _defUploadingLoader(LMFeedPostState state) {
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
          if (_isPostEditing || _isPostUploading)
            _screenBuilder.uploadingPostLoaderBuilder(
              context,
              _defLoaderForUploading(),
            ),
          SizedBox(
            width: 16,
          ),
          _screenBuilder.uploadingPostTextBuilder(
            context,
            _defUploadingText(),
          ),
          if (_isPostUploadingFailed) ...[
            Spacer(),
            _screenBuilder.uploadingPostRetryButtonBuilder(
                context, _defRetryButton()),
            SizedBox(
              width: 16,
            ),
            _screenBuilder.uploadingPostCancelButtonBuilder(
                context,
                _defCancelButton(
                  state,
                )),
          ],
        ],
      ),
    );
  }

  LMFeedButton _defRetryButton() {
    return LMFeedButton(
      onTap: () {
        _isPostUploadingFailed = false;
        _postBloc.add(LMFeedRetryPostUploadEvent());
      },
      text: LMFeedText(
          text: "Retry",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _theme.onContainer,
            ),
          )),
    );
  }

  LMFeedButton _defCancelButton(LMFeedPostState state) {
    return LMFeedButton(
      onTap: () async {
        if (state is LMFeedMediaUploadErrorState) {
          // delete the temporary post from db
          final DeleteTemporaryPostRequest deleteTemporaryPostRequest =
              (DeleteTemporaryPostRequestBuilder()
                    ..temporaryPostId(state.tempId))
                  .build();
          await LMFeedCore.instance.lmFeedClient
              .deleteTemporaryPost(deleteTemporaryPostRequest);
          _postBloc.add(LMFeedPostInitiateEvent());
        }
      },
      text: LMFeedText(
          text: "Cancel",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: _theme.onContainer,
            ),
          )),
    );
  }

  LMFeedLoader _defLoaderForUploading() {
    return LMFeedLoader(
      style: LMFeedLoaderStyle(
        strokeWidth: 3,
        height: 24,
        width: 24,
      ),
    );
  }

  LMFeedText _defUploadingText() {
    return LMFeedText(
      text:
          "${_isPostEditing ? "Saving" : "Posting"} reel ${_isPostUploadingFailed ? "failed" : ""}",
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: _theme.onContainer,
        ),
      ),
    );
  }

  Column _defAllCaughtUpView() {
    // add analytics event for no more reels shown
    // add analytics event
    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.noMoreReelsShown,
        widgetSource: LMFeedWidgetSource.videoFeed,
        eventProperties: {
          'uuid': _currentUser?.uuid,
        },
      ),
    );
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
    if (state is LMFeedNewPostInitiateState) {
      _isPostUploading = false;
      _isPostEditing = false;
      _isPostUploadingFailed = false;
    }
    if (state is LMFeedNewPostUploadingState) {
      _isPostUploading = true;
    }
    if (state is LMFeedEditPostUploadingState) {
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
      // marked it true to show the error indicator
      _isPostUploadingFailed = true;
      _isPostUploading = false;
      LMFeedCore.showSnackBar(
        context,
        state.errorMessage,
        _widgetSource,
      );
    }
    if (state is LMFeedMediaUploadErrorState) {
      _isPostUploadingFailed = true;
      _isPostUploading = false;
    }
    if (state is LMFeedEditPostErrorState) {
      _isPostEditing = false;
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
}
