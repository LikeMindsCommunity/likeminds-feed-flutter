// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/social/configurations/config.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// {@template lm_feed_social_personalised_screen}
/// A screen to display the feed.
/// The feed can be customized by passing in the required parameters
/// Post creation can be enabled or disabled
/// Post Builder can be used to customize the post widget
/// Topic Chip Builder can be used to customize the topic chip widget
///
/// {@endtemplate}
class LMFeedSocialPersonalisedScreen extends StatefulWidget {
  const LMFeedSocialPersonalisedScreen({
    super.key,
    this.appBar,
    this.customWidgetBuilder,
    this.postBuilder,
    this.floatingActionButtonBuilder,
    this.feedScreenSettings,
    this.floatingActionButtonLocation,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.pendingPostBannerBuilder,
    this.pageSize = 10,
    this.startFeedWithPostIds,
  });

  // Builder for appbar
  final LMFeedAppBarBuilder? appBar;

  /// Builder for custom widget on top
  final LMFeedCustomWidgetBuilder? customWidgetBuilder;
  // Builder for post item
  // {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;
  // Floating action button
  // i.e. new post button
  final LMFeedContextButtonBuilder? floatingActionButtonBuilder;
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

  // Builder for pending post banner on feed screen above post list
  final Widget Function(BuildContext context, int noOfPendingPost)?
      pendingPostBannerBuilder;

  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final LMFeedSocialScreenSetting? feedScreenSettings;
  final int pageSize;

  /// ids of the post to start the feed with
  final List<String>? startFeedWithPostIds;

  @override
  State<LMFeedSocialPersonalisedScreen> createState() =>
      _LMFeedSocialPersonalisedScreenState();

  LMFeedSocialPersonalisedScreen copyWith({
    LMFeedAppBarBuilder? appBar,
    LMFeedCustomWidgetBuilder? customWidgetBuilder,
    LMFeedPostWidgetBuilder? postBuilder,
    LMFeedContextButtonBuilder? floatingActionButtonBuilder,
    LMFeedContextWidgetBuilder? noItemsFoundIndicatorBuilder,
    LMFeedContextWidgetBuilder? firstPageProgressIndicatorBuilder,
    LMFeedContextWidgetBuilder? newPageProgressIndicatorBuilder,
    LMFeedContextWidgetBuilder? noMoreItemsIndicatorBuilder,
    LMFeedContextWidgetBuilder? firstPageErrorIndicatorBuilder,
    LMFeedContextWidgetBuilder? newPageErrorIndicatorBuilder,
    Widget Function(BuildContext context, int noOfPendingPost)?
        pendingPostBannerBuilder,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    LMFeedSocialScreenSetting? config,
    int? pageSize,
    List<String>? startFeedWithPostIds,
  }) {
    return LMFeedSocialPersonalisedScreen(
      appBar: appBar ?? this.appBar,
      customWidgetBuilder: customWidgetBuilder ?? this.customWidgetBuilder,
      postBuilder: postBuilder ?? this.postBuilder,
      floatingActionButtonBuilder:
          floatingActionButtonBuilder ?? this.floatingActionButtonBuilder,
      noItemsFoundIndicatorBuilder:
          noItemsFoundIndicatorBuilder ?? this.noItemsFoundIndicatorBuilder,
      firstPageProgressIndicatorBuilder: firstPageProgressIndicatorBuilder ??
          this.firstPageProgressIndicatorBuilder,
      newPageProgressIndicatorBuilder: newPageProgressIndicatorBuilder ??
          this.newPageProgressIndicatorBuilder,
      noMoreItemsIndicatorBuilder:
          noMoreItemsIndicatorBuilder ?? this.noMoreItemsIndicatorBuilder,
      firstPageErrorIndicatorBuilder:
          firstPageErrorIndicatorBuilder ?? this.firstPageErrorIndicatorBuilder,
      newPageErrorIndicatorBuilder:
          newPageErrorIndicatorBuilder ?? this.newPageErrorIndicatorBuilder,
      pendingPostBannerBuilder:
          pendingPostBannerBuilder ?? this.pendingPostBannerBuilder,
      floatingActionButtonLocation:
          floatingActionButtonLocation ?? this.floatingActionButtonLocation,
      feedScreenSettings: config ?? this.feedScreenSettings,
      pageSize: pageSize ?? this.pageSize,
      startFeedWithPostIds: startFeedWithPostIds ?? this.startFeedWithPostIds,
    );
  }
}

class _LMFeedSocialPersonalisedScreenState
    extends State<LMFeedSocialPersonalisedScreen> with WidgetsBindingObserver {
  late Size screenSize;
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

  // Create an instance of LMFeedScreenBuilderDelegate
  LMFeedSocialScreenBuilderDelegate _screenBuilderDelegate =
      LMFeedCore.config.socialFeedScreenConfig.builder;

  LMFeedPendingPostScreenBuilderDelegate _pendingPostScreenBuilderDelegate =
      LMFeedCore.config.pendingPostScreenConfig.builder;

  // Create an instance of LMFeedPostBloc
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;

  // Get the theme data from LMFeedCore
  LMFeedThemeData feedThemeData = LMFeedCore.theme;

  // Create an instance of LMFeedScreenBuilderDelegate
  LMFeedSocialScreenBuilderDelegate _widgetsBuilder =
      LMFeedCore.config.socialFeedScreenConfig.builder;

  // Set the widget source to personalised feed
  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.personalisedFeed;

  // Create a ValueNotifier to rebuild the post widget
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);

  // Create a ValueNotifier to track if a post is uploading
  final ValueNotifier<bool> postUploading = ValueNotifier(false);
  bool isPostEditing = false;

  LMFeedSocialScreenSetting? feedScreenSettings;
  LMFeedWebConfiguration webConfig = LMFeedCore.config.webConfiguration;
  /* 
  * defines the height of topic feed bar
  * initialy set to 0, after fetching the topics
  * it is set to 62 if the topics are not empty
  */
  final ScrollController _controller = ScrollController();

  // bloc to handle personalised feed
  final LMFeedPersonalisedBloc _feedBloc =
      LMFeedPersonalisedBloc.instance; // bloc to fetch the feedroom data
  bool isCm = LMFeedUserUtils
      .checkIfCurrentUserIsCM(); // whether the logged in user is a community manager or not

  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();

  // future to get the unread notification count
  late Future<GetUnreadNotificationCountResponse> getUnreadNotificationCount;

  late Future<GetUserFeedMetaResponse> getUserFeedMeta;

  // used to rebuild the appbar
  final ValueNotifier _rebuildAppBar = ValueNotifier(false);

  // to control paging on FeedRoom View
  final PagingController<int, LMPostViewData> _pagingController =
      PagingController(firstPageKey: 1);

  bool userPostingRights = true;

  int pendingPostCount = 0;
  bool isDesktopWeb = false;
  Timer? _scrollTimer;

// function to handle scroll event with debounce
  void _handleScroll() {
    if (_scrollTimer != null && _scrollTimer!.isActive) {
      _scrollTimer!.cancel();
    }
    _scrollTimer = Timer(const Duration(seconds: 5), () {
      _callSeenPostEvent();
    });
  }

  @override
  void initState() {
    super.initState();
    // scroll listener to handle the scroll event
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _controller.position.isScrollingNotifier.addListener(() {
        // if the state is idle then call the seen post event
        if (!_controller.position.isScrollingNotifier.value) {
          _handleScroll();
        }
      });
    });
    // add seen event
    _triggerPostSeenEvent();
    WidgetsBinding.instance.addObserver(this);
    // Adds pagination listener to the feed
    _addPaginationListener();

    feedScreenSettings = widget.feedScreenSettings ??
        LMFeedCore.config.socialFeedScreenConfig.setting;

    getUserFeedMeta = getUserFeedMetaFuture();

    // Sets the Bloc observer to LMFeedBlocObserver
    Bloc.observer = LMFeedBlocObserver();

    // Checks the user's posting rights using LMFeedUserUtils
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();

    // Sets the value of postUploading based on the state of newPostBloc
    postUploading.value = newPostBloc.state is LMFeedNewPostUploadingState ||
        newPostBloc.state is LMFeedEditPostUploadingState;

    newPostBloc.stream.listen((state) {
      if (state is LMFeedNewPostUploadingState ||
          state is LMFeedEditPostUploadingState) {
        postUploading.value = true;
        isPostEditing = state is LMFeedEditPostUploadingState;
      } else if (state is LMFeedNewPostUploadedState ||
          state is LMFeedEditPostUploadedState ||
          state is LMFeedNewPostErrorState ||
          state is LMFeedEditPostErrorState ||
          state is LMFeedMediaUploadErrorState) {
        postUploading.value = false;
        isPostEditing = false;
      }
    });

    // Adds a feed opened event to the LMFeedAnalyticsBloc
    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.feedOpened,
        widgetSource: LMFeedWidgetSource.personalisedFeed,
        eventProperties: {
          'feed_type': 'personalised_feed',
        },
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _rebuildAppBar.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
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
      _feedBloc
          .add(LMFeedPersonalisedSeenPostEvent(seenPost: seenPost.toList()));
    }
  }

  // function to call the seen post event
  // with the seen post ids saved in the memory
  void _callSeenPostEvent() {
    List<String> seenPost = _feedBloc.seenPost.toList();
    _feedBloc.add(LMFeedPersonalisedSeenPostEvent(seenPost: seenPost));
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.inactive) {
      List<String> seenPost = _feedBloc.seenPost.toList();
      await LMFeedPersistence.instance.insertSeenPostID(seenPost);
    }
  }

  void _scrollToTop() {
    _controller.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
    );
  }

  void _addPaginationListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _feedBloc.add(
          LMFeedPersonalisedGetEvent(
            pageKey: pageKey,
            pageSize: widget.pageSize,
            startFeedWithPostIds: widget.startFeedWithPostIds,
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function handle the paging controller based on the state changes
  void handleBlocListener(LMFeedPersonalisedState? state) {
    if (state is LMFeedPersonalisedFeedLoadedState) {
      // if page is 1 then trigger the debounce event
      if (state.pageKey == 1) {
        _handleScroll();
      }
      List<LMPostViewData> listOfPosts = state.posts.copy();
      // check if the post is in same ordered as the [startFeedWithPostIds]
      // if not show a snackbar
      if (state.pageKey == 1 &&
          widget.startFeedWithPostIds != null &&
          widget.startFeedWithPostIds!.isNotEmpty) {
        LMFeedPostUtils.checkForPostDeletionErrorState(
          context,
          postTitleFirstCap,
          listOfPosts,
          widget.startFeedWithPostIds!,
          _widgetSource,
        );
      }
      if (state.posts.length < widget.pageSize) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, state.pageKey + 1);
      }
    } else if (state is LMFeedPersonalisedRefreshState) {
      getUserFeedMeta = getUserFeedMetaFuture();
      _rebuildAppBar.value = !_rebuildAppBar.value;
      clearPagingController();
      refresh();
    } else if (state is LMFeedPersonalisedErrorState) {
      _pagingController.error = state.message;
      LMFeedCore.showSnackBar(context, state.message, _widgetSource);
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feed screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    _pagingController.itemList?.clear();
  }

  Future<GetUserFeedMetaResponse> getUserFeedMetaFuture() {
    return LMFeedCore.client.getUserFeedMeta(
      (GetUserFeedMetaRequestBuilder()..uuid(currentUser?.uuid ?? '')).build(),
    );
  }

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
  Widget build(BuildContext context) {
    return _widgetsBuilder.scaffold(
      source: _widgetSource,
      backgroundColor: feedThemeData.backgroundColor,
      appBar: widget.appBar?.call(context, _defAppBar()) ??
          _widgetsBuilder.appBarBuilder(context, _defAppBar()),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: rebuildPostWidget,
        builder: (context, _, __) {
          return widget.floatingActionButtonBuilder
                  ?.call(context, defFloatingActionButton(context)) ??
              _widgetsBuilder.floatingActionButtonBuilder(
                  context, defFloatingActionButton(context));
        },
      ),
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: min(LMFeedCore.config.webConfiguration.maxWidth,
              MediaQuery.sizeOf(context).width),
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              _feedBloc.add(LMFeedPersonalisedRefreshEvent());
            },
            color: feedThemeData.primaryColor,
            backgroundColor: feedThemeData.container,
            child: CustomScrollView(
              controller: _controller,
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: ValueListenableBuilder(
                      valueListenable: _rebuildAppBar,
                      builder: (context, _, __) {
                        return FutureBuilder(
                            future: getUserFeedMeta,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.done) {
                                if (snapshot.hasData && snapshot.data != null) {
                                  GetUserFeedMetaResponse response =
                                      snapshot.data as GetUserFeedMetaResponse;

                                  if (response.success) {
                                    pendingPostCount =
                                        response.pendingPostCount ?? 0;
                                  }
                                }
                              }

                              return Container(
                                child: widget.pendingPostBannerBuilder
                                        ?.call(context, pendingPostCount) ??
                                    _screenBuilderDelegate
                                        .pendingPostBannerBuilder(
                                      context,
                                      pendingPostCount,
                                      LMFeedPendingPostBanner(
                                          pendingPostCount: pendingPostCount,
                                          onPendingPostBannerPressed: () {
                                            Navigator.of(context).push(
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        LMFeedPendingPostsScreen()));
                                          }),
                                    ),
                              );
                            });
                      }),
                ),
                if (feedScreenSettings?.showCustomWidget ?? false)
                  SliverToBoxAdapter(
                    child: widget.customWidgetBuilder
                            ?.call(context, _defPostSomeThingWidget(context)) ??
                        _widgetsBuilder.customWidgetBuilder(
                            _defPostSomeThingWidget(context), context),
                  ),
                SliverToBoxAdapter(
                  child: BlocConsumer<LMFeedPostBloc, LMFeedPostState>(
                    bloc: newPostBloc,
                    listener: (previous, current) {
                      if (current is LMFeedPostDeletedState) {
                        // show a snackbar when post is deleted
                        // will only be shown if a messenger key is provided
                        LMFeedCore.showSnackBar(
                          context,
                          '$postTitleFirstCap Deleted',
                          _widgetSource,
                        );

                        if (current.pendingPostId != null) {
                          if (pendingPostCount > 0) {
                            pendingPostCount--;
                            rebuildPostWidget.value = !rebuildPostWidget.value;
                          }
                          return;
                        }

                        List<LMPostViewData>? feedRoomItemList =
                            _pagingController.itemList;
                        feedRoomItemList
                            ?.removeWhere((item) => item.id == current.postId);
                        _pagingController.itemList = feedRoomItemList;
                        rebuildPostWidget.value = !rebuildPostWidget.value;
                      }
                      if (current is LMFeedNewPostUploadedState) {
                        if (LMFeedPostUtils.doPostNeedsApproval) {
                          _pendingPostScreenBuilderDelegate
                              .showPostApprovalDialog(
                            context,
                            current.postData,
                            LMFeedPendingPostDialog(
                              dialogStyle: feedThemeData.dialogStyle.copyWith(
                                  insetPadding: EdgeInsets.all(40.0),
                                  padding: EdgeInsets.all(24.0)),
                              headingTextStyles:
                                  LMFeedTextStyle.basic().copyWith(
                                maxLines: 2,
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: feedThemeData.onContainer,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              dialogMessageTextStyles:
                                  LMFeedTextStyle.basic().copyWith(
                                overflow: TextOverflow.visible,
                                maxLines: 10,
                                textStyle: TextStyle(
                                  fontSize: 16,
                                  color: feedThemeData.textSecondary,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              pendingPostId: current.postData.id,
                              onCancelButtonClicked: () {
                                Navigator.of(context).pop();
                              },
                              onEditButtonClicked: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LMFeedEditPostScreen(
                                      pendingPostId: current.postData.id,
                                    ),
                                  ),
                                );
                              },
                              title:
                                  "$postTitleFirstCap submitted for approval",
                              description:
                                  "Your $postTitleSmallCap has been submitted for approval. Once approved, you will get a notification and it will be visible to others.",
                            ),
                          );
                          getUserFeedMeta = getUserFeedMetaFuture();
                          pendingPostCount++;
                          _rebuildAppBar.value = !_rebuildAppBar.value;
                          return;
                        }
                        LMPostViewData? item = current.postData;
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
                            feedRoomItemList.length > widget.pageSize) {
                          feedRoomItemList.removeLast();
                        }
                        _pagingController.itemList = feedRoomItemList;
                        postUploading.value = false;
                        rebuildPostWidget.value = !rebuildPostWidget.value;

                        LMFeedCore.showSnackBar(
                          context,
                          '$postTitleFirstCap Created',
                          _widgetSource,
                        );
                        _scrollToTop();
                      }
                      if (current is LMFeedEditPostUploadedState) {
                        LMPostViewData? item = current.postData.copyWith();
                        List<LMPostViewData>? feedRoomItemList =
                            _pagingController.itemList;
                        int index = feedRoomItemList?.indexWhere(
                                (element) => element.id == item.id) ??
                            -1;
                        if (index != -1) {
                          feedRoomItemList![index] = item;
                        }
                        postUploading.value = false;
                        rebuildPostWidget.value = !rebuildPostWidget.value;

                        LMFeedCore.showSnackBar(context,
                            '$postTitleFirstCap Edited', _widgetSource);
                      }
                      if (current is LMFeedNewPostErrorState) {
                        postUploading.value = false;
                        isPostEditing = false;
                        LMFeedCore.showSnackBar(
                          context,
                          current.errorMessage,
                          _widgetSource,
                        );
                      }
                      if (current is LMFeedPostUpdateState) {
                        List<LMPostViewData>? feedRoomItemList =
                            _pagingController.itemList;
                        int index = feedRoomItemList?.indexWhere(
                                (element) => element.id == current.postId) ??
                            -1;

                        if (index != -1) {
                          feedRoomItemList![index] =
                              LMFeedPostUtils.updatePostData(
                            postViewData:
                                current.post ?? feedRoomItemList[index],
                            actionType: current.actionType,
                            commentId: current.commentId,
                            pollOptions: current.pollOptions,
                          );
                        }
                        rebuildPostWidget.value = !rebuildPostWidget.value;
                      }
                      if (current is LMFeedPostDeletionErrorState) {
                        LMFeedCore.showSnackBar(
                          context,
                          current.message,
                          _widgetSource,
                        );
                      }
                    },
                    builder: (context, state) {
                      if (postUploading.value) {
                        return LMPostUploadingBanner(
                          isUploading: true,
                          uploadingMessage:
                              '${isPostEditing ? "Saving" : "Creating"} $postTitleSmallCap',
                          onRetry: () {},
                          onCancel: () {},
                        );
                      }
                      if (state is LMFeedMediaUploadErrorState) {
                        return LMPostUploadingBanner(
                          onRetry: () {
                            newPostBloc.add(LMFeedRetryPostUploadEvent());
                          },
                          onCancel: () async {
                            // delete the temporary post from db
                            final DeleteTemporaryPostRequest
                                deleteTemporaryPostRequest =
                                (DeleteTemporaryPostRequestBuilder()
                                      ..temporaryPostId(state.tempId))
                                    .build();
                            await LMFeedCore.instance.lmFeedClient
                                .deleteTemporaryPost(
                                    deleteTemporaryPostRequest);
                            newPostBloc.add(LMFeedPostInitiateEvent());
                          },
                        );
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
                if (isDesktopWeb)
                  SliverPadding(padding: EdgeInsets.only(top: 12.0)),
                BlocListener<LMFeedPersonalisedBloc, LMFeedPersonalisedState>(
                  bloc: _feedBloc,
                  listener: (context, LMFeedPersonalisedState state) =>
                      handleBlocListener(state),
                  child: ValueListenableBuilder(
                    valueListenable: rebuildPostWidget,
                    builder: (context, _, __) {
                      return PagedSliverList<int, LMPostViewData>(
                        pagingController: _pagingController,
                        builderDelegate:
                            PagedChildBuilderDelegate<LMPostViewData>(
                          itemBuilder: (context, item, index) {
                            LMFeedPostWidget postWidget =
                                LMFeedDefaultWidgets.instance.defPostWidget(
                              context,
                              feedThemeData,
                              item,
                              _widgetSource,
                              postUploading,
                            );
                            return VisibilityDetector(
                              key: ObjectKey(item.id),
                              onVisibilityChanged: (visibilityInfo) {
                                // check if the post is visible more than 40% and is scrolling in reverse direction
                                // then add the post to seen list
                                if (mounted) {
                                  double visiblePercentage =
                                      visibilityInfo.visibleFraction * 100;
                                  if (visiblePercentage > 40) {
                                    LMFeedPersonalisedBloc.instance.seenPost
                                        .add(item.id);
                                  }
                                }
                              },
                              child: widget.postBuilder
                                      ?.call(context, postWidget, item) ??
                                  _widgetsBuilder.postWidgetBuilder.call(
                                      context, postWidget, item,
                                      source: _widgetSource),
                            );
                          },
                          noItemsFoundIndicatorBuilder: (context) {
                            return _widgetsBuilder.noItemsFoundIndicatorBuilder(
                                context,
                                createPostButton: createPostButton(context));
                          },
                          noMoreItemsIndicatorBuilder: (context) {
                            return widget.noMoreItemsIndicatorBuilder
                                    ?.call(context) ??
                                _widgetsBuilder
                                    .noMoreItemsIndicatorBuilder(context);
                          },
                          newPageProgressIndicatorBuilder: (context) {
                            return widget.newPageProgressIndicatorBuilder
                                    ?.call(context) ??
                                _widgetsBuilder
                                    .newPageProgressIndicatorBuilder(context);
                          },
                          firstPageProgressIndicatorBuilder: (context) =>
                              widget.firstPageProgressIndicatorBuilder
                                  ?.call(context) ??
                              _widgetsBuilder
                                  .firstPageProgressIndicatorBuilder(context),
                          firstPageErrorIndicatorBuilder: (context) =>
                              widget.firstPageErrorIndicatorBuilder
                                  ?.call(context) ??
                              _widgetsBuilder
                                  .firstPageErrorIndicatorBuilder(context),
                          newPageErrorIndicatorBuilder: (context) =>
                              widget.newPageErrorIndicatorBuilder
                                  ?.call(context) ??
                              _widgetsBuilder
                                  .newPageErrorIndicatorBuilder(context),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  LMFeedPostSomething _defPostSomeThingWidget(BuildContext context) {
    return LMFeedPostSomething(
      onTap: () {
        LMFeedDefaultWidgets.instance.handleCreatePost(
          context,
          _widgetSource,
          postUploading,
        );
      },
      style: LMFeedPostSomethingStyle.basic(
        theme: feedThemeData,
      ),
    );
  }

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
      leading: const SizedBox.shrink(),
      title: GestureDetector(
        onTap: () {
          _scrollToTop();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: LMFeedText(
            text: "Feed",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                color: feedThemeData.onContainer,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      style: LMFeedAppBarStyle.basic().copyWith(
        backgroundColor: feedThemeData.container,
        height: 64,
      ),
      trailing: [
        LMFeedButton(
          onTap: () {
            // check if the user is a guest user
            if (LMFeedUserUtils.isGuestUser()) {
              LMFeedCore.instance.lmFeedCoreCallback?.loginRequired
                  ?.call(context);
              return;
            }
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => LMFeedSearchScreen(
                  postBuilder: widget.postBuilder,
                  emptyFeedViewBuilder: widget.noItemsFoundIndicatorBuilder,
                  paginationLoaderBuilder:
                      widget.newPageProgressIndicatorBuilder,
                  feedErrorViewBuilder: widget.newPageErrorIndicatorBuilder,
                  noNewPageWidgetBuilder: widget.noMoreItemsIndicatorBuilder,
                  firstPageLoaderBuilder:
                      widget.firstPageProgressIndicatorBuilder,
                ),
              ),
            );
          },
          style: LMFeedButtonStyle.basic().copyWith(
            icon: LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.search,
              style: LMFeedIconStyle.basic().copyWith(
                color: feedThemeData.onContainer,
                size: 24,
              ),
            ),
          ),
        ),
        if (feedScreenSettings?.showNotificationFeedIcon ?? true)
          LMFeedButton(
            onTap: () {
              // check if the user is a guest user
              if (LMFeedUserUtils.isGuestUser()) {
                LMFeedCore.instance.lmFeedCoreCallback?.loginRequired
                    ?.call(context);
                return;
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LMFeedNotificationScreen(),
                ),
              );
            },
            style: LMFeedButtonStyle.basic().copyWith(
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmNotificationBellSvg,
                style: LMFeedIconStyle.basic().copyWith(
                  color: feedThemeData.onContainer,
                  size: 24,
                ),
              ),
            ),
          ),
        BlocBuilder<LMFeedUserMetaBloc, LMFeedUserMetaState>(
          bloc: LMFeedUserMetaBloc.instance,
          buildWhen: (previous, current) =>
              current is LMFeedUserMetaLoadedState,
          builder: (context, state) {
            currentUser = LMFeedLocalPreference.instance.fetchUserData();
            return LMFeedProfilePicture(
              fallbackText: currentUser!.name,
              imageUrl: currentUser!.imageUrl,
              style: LMFeedProfilePictureStyle.basic().copyWith(
                size: 42,
                fallbackTextStyle: LMFeedTextStyle.basic().copyWith(
                  textStyle: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: LMFeedCore.theme.onPrimary,
                  ),
                ),
              ),
            );
          },
        )
      ],
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
      } else if (media.attachmentType == LMMediaType.video) {
        return const SizedBox();
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  LMFeedButton createPostButton(BuildContext context) {
    return LMFeedButton(
      style: LMFeedButtonStyle(
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Icons.add,
          style: LMFeedIconStyle(
            size: 18,
            color: feedThemeData.onPrimary,
          ),
        ),
        borderRadius: 28,
        backgroundColor: feedThemeData.primaryColor,
        height: 44,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        placement: LMFeedIconButtonPlacement.end,
      ),
      text: LMFeedText(
        text: "Create $postTitleFirstCap",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: feedThemeData.onPrimary,
          ),
        ),
      ),
      onTap: () {
        LMFeedDefaultWidgets.instance.handleCreatePost(
          context,
          _widgetSource,
          postUploading,
        );
      },
    );
  }

  LMFeedButton defFloatingActionButton(BuildContext context) => LMFeedButton(
        style: LMFeedButtonStyle(
          icon: LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: Icons.add,
            style: LMFeedIconStyle(
              fit: BoxFit.cover,
              size: 18,
              color: feedThemeData.onPrimary,
            ),
          ),
          height: 44,
          width: 185,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          borderRadius: 28,
          backgroundColor: userPostingRights
              ? feedThemeData.primaryColor
              : feedThemeData.inActiveColor,
          placement: LMFeedIconButtonPlacement.end,
          gap: 5.0,
        ),
        text: LMFeedText(
          text: "Create $postTitleFirstCap",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: feedThemeData.onPrimary,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ),
        onTap: () {
          LMFeedDefaultWidgets.instance.handleCreatePost(
            context,
            _widgetSource,
            postUploading,
          );
        },
      );
}
