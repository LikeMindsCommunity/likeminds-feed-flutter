// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_feed_social_universal_screen}
/// A screen to display the feed.
/// The feed can be customized by passing in the required parameters
/// Post creation can be enabled or disabled
/// Post Builder can be used to customize the post widget
/// Topic Chip Builder can be used to customize the topic chip widget
///
/// {@endtemplate}
class LMFeedSocialUniversalScreen extends StatefulWidget {
  const LMFeedSocialUniversalScreen({
    super.key,
    this.appBar,
    this.customWidgetBuilder,
    this.topicChipBuilder,
    this.postBuilder,
    this.floatingActionButtonBuilder,
    this.config,
    this.topicBarBuilder,
    this.floatingActionButtonLocation,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.pendingPostBannerBuilder,
  });

  // Builder for appbar
  final LMFeedPostAppBarBuilder? appBar;

  /// Builder for custom widget on top
  final LMFeedCustomWidgetBuilder? customWidgetBuilder;
  // Builder for topic chip [Button]
  final Widget Function(BuildContext context, List<LMTopicViewData>? topic)?
      topicChipBuilder;

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

  final LMFeedTopicBarBuilder? topicBarBuilder;

  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final LMFeedScreenConfig? config;

  @override
  State<LMFeedSocialUniversalScreen> createState() =>
      _LMFeedSocialUniversalScreenState();

  LMFeedSocialUniversalScreen copyWith({
    LMFeedPostAppBarBuilder? appBar,
    LMFeedCustomWidgetBuilder? customWidgetBuilder,
    Widget Function(BuildContext context, List<LMTopicViewData>? topic)?
        topicChipBuilder,
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
    LMFeedTopicBarBuilder? topicBarBuilder,
    FloatingActionButtonLocation? floatingActionButtonLocation,
    LMFeedScreenConfig? config,
  }) {
    return LMFeedSocialUniversalScreen(
      appBar: appBar ?? this.appBar,
      customWidgetBuilder: customWidgetBuilder ?? this.customWidgetBuilder,
      topicChipBuilder: topicChipBuilder ?? this.topicChipBuilder,
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
      topicBarBuilder: topicBarBuilder ?? this.topicBarBuilder,
      floatingActionButtonLocation:
          floatingActionButtonLocation ?? this.floatingActionButtonLocation,
      config: config ?? this.config,
    );
  }
}

class _LMFeedSocialUniversalScreenState
    extends State<LMFeedSocialUniversalScreen> {
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
  LMFeedScreenBuilderDelegate _screenBuilderDelegate =
      LMFeedCore.feedBuilderDelegate.feedScreenBuilderDelegate;

  LMFeedPendingPostScreenBuilderDeletegate _pendingPostScreenBuilderDelegate =
      LMFeedCore.feedBuilderDelegate.pendingPostScreenBuilderDelegate;

  // Create an instance of LMFeedPostBloc
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;

  // Get the theme data from LMFeedCore
  LMFeedThemeData feedThemeData = LMFeedCore.theme;

  // Create an instance of LMFeedWidgetUtility
  LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;

  // Set the widget source to universal feed
  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.universalFeed;

  // Create a ValueNotifier to rebuild the post widget
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);

  // Create a ValueNotifier to track if a post is uploading
  final ValueNotifier<bool> postUploading = ValueNotifier(false);
  bool isPostEditing = false;

  LMFeedScreenConfig? config;
  LMFeedWebConfiguration webConfig = LMFeedCore.webConfiguration;
  /* 
  * defines the height of topic feed bar
  * initialy set to 0, after fetching the topics
  * it is set to 62 if the topics are not empty
  */
  final ScrollController _controller = ScrollController();

  // notifies value listenable builder to rebuild the topic feed
  ValueNotifier<bool> rebuildTopicFeed = ValueNotifier(false);

  // future to get the topics
  Future<GetTopicsResponse>? getTopicsResponse;

  // bloc to handle universal feed
  late final LMFeedUniversalBloc _feedBloc; // bloc to fetch the feedroom data
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
  bool isTempPostPresent = false;

  @override
  void initState() {
    super.initState();
    newPostBloc.add(LMFeedFetchTempPostEvent());
    // Adds pagination listener to the feed
    _addPaginationListener();

    config = widget.config ?? LMFeedCore.config.feedScreenConfig;

    // Retrieves topics from the LMFeedCore client
    getTopicsResponse = LMFeedCore.client.getTopics(
      (GetTopicsRequestBuilder()
            ..page(1)
            ..pageSize(20))
          .build(),
    );

    getUserFeedMeta = getUserFeedMetaFuture();

    // Sets the Bloc observer to LMFeedBlocObserver
    Bloc.observer = LMFeedBlocObserver();

    // Initializes the feed Bloc instance
    _feedBloc = LMFeedUniversalBloc.instance;

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
        widgetSource: LMFeedWidgetSource.universalFeed,
        eventProperties: {
          'feed_type': 'universal_feed',
        },
      ),
    );
  }

  // This function updates the selected topics and fetches the universal
  // feed based on the selected topics
  void updateSelectedTopics(List<LMTopicViewData> topics) {
    _feedBloc.selectedTopics = topics;
    rebuildTopicFeed.value = !rebuildTopicFeed.value;
    clearPagingController();
    _feedBloc.add(
      LMFeedGetUniversalFeedEvent(
        pageKey: 1,
        topicsIds: _feedBloc.selectedTopics.map((e) => e.id).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _rebuildAppBar.dispose();
    super.dispose();
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
          LMFeedGetUniversalFeedEvent(
            pageKey: pageKey,
            topicsIds: _feedBloc.selectedTopics.map((e) => e.id).toList(),
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(LMFeedUniversalState? state) {
    if (state is LMFeedUniversalFeedLoadedState) {
      List<LMPostViewData> listOfPosts = state.posts;

      _feedBloc.users.addAll(state.users);
      _feedBloc.topics.addAll(state.topics);
      _feedBloc.widgets.addAll(state.widgets);

      if (state.posts.length < 10) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, state.pageKey + 1);
      }
    } else if (state is LMFeedUniversalRefreshState) {
      getUserFeedMeta = getUserFeedMetaFuture();
      _rebuildAppBar.value = !_rebuildAppBar.value;
      clearPagingController();
      refresh();
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feed screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
  }

  void showTopicSelectSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isDismissible: true,
      useRootNavigator: true,
      backgroundColor: feedThemeData.container,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28.0),
          topRight: Radius.circular(28.0),
        ),
      ),
      enableDrag: true,
      clipBehavior: Clip.hardEdge,
      builder: (context) => LMFeedTopicBottomSheet(
        key: GlobalKey(),
        selectedTopics: _feedBloc.selectedTopics,
        onTopicSelected: (updatedTopics, tappedTopic) {
          updateSelectedTopics(updatedTopics);
        },
      ),
    );
  }

  void navigateToTopicSelectScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LMFeedTopicSelectScreen(
          onTopicSelected: (updatedTopics) {
            updateSelectedTopics(updatedTopics);
          },
          selectedTopics: _feedBloc.selectedTopics,
        ),
      ),
    );
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
      appBar: widget.appBar?.call(context, _defAppBar()) ?? _defAppBar(),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: rebuildPostWidget,
        builder: (context, _, __) {
          return widget.floatingActionButtonBuilder
                  ?.call(context, defFloatingActionButton(context)) ??
              defFloatingActionButton(context);
        },
      ),
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: min(LMFeedCore.webConfiguration.maxWidth,
              MediaQuery.sizeOf(context).width),
          child: RefreshIndicator.adaptive(
            onRefresh: () async {
              _feedBloc.add(LMFeedUniversalRefreshEvent());
            },
            color: feedThemeData.primaryColor,
            backgroundColor: feedThemeData.container,
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _controller,
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
                SliverToBoxAdapter(
                  child: config!.showCustomWidget
                      ? widget.customWidgetBuilder?.call(
                              context, _defPostSomeThingWidget(context)) ??
                          _defPostSomeThingWidget(context)
                      : const SizedBox(),
                ),
                SliverToBoxAdapter(
                  child: BlocConsumer<LMFeedPostBloc, LMFeedPostState>(
                    bloc: newPostBloc,
                    listener: (prev, curr) {
                      if (curr is LMFeedPostDeletedState) {
                        // show a snackbar when post is deleted
                        // will only be shown if a messenger key is provided
                        LMFeedCore.showSnackBar(
                          context,
                          '$postTitleFirstCap Deleted',
                          _widgetSource,
                        );

                        if (curr.pendingPostId != null) {
                          if (pendingPostCount > 0) {
                            pendingPostCount--;
                            rebuildPostWidget.value = !rebuildPostWidget.value;
                          }
                          return;
                        }

                        List<LMPostViewData>? feedRoomItemList =
                            _pagingController.itemList;
                        feedRoomItemList
                            ?.removeWhere((item) => item.id == curr.postId);
                        _pagingController.itemList = feedRoomItemList;
                        rebuildPostWidget.value = !rebuildPostWidget.value;
                      }
                      if (curr is LMFeedNewPostUploadedState) {
                        if (LMFeedPostUtils.doPostNeedsApproval) {
                          _pendingPostScreenBuilderDelegate
                              .showPostApprovalDialog(
                            context,
                            curr.postData,
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
                              pendingPostId: curr.postData.id,
                              onCancelButtonClicked: () {
                                Navigator.of(context).pop();
                              },
                              onEditButtonClicked: () {
                                Navigator.of(context).pop();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => LMFeedEditPostScreen(
                                      pendingPostId: curr.postData.id,
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
                        LMPostViewData? item = curr.postData;
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
                        }
                        _feedBloc.users.addAll(curr.userData);
                        _feedBloc.topics.addAll(curr.topics);
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
                      if (curr is LMFeedEditPostUploadedState) {
                        LMPostViewData? item = curr.postData.copyWith();
                        List<LMPostViewData>? feedRoomItemList =
                            _pagingController.itemList;
                        int index = feedRoomItemList?.indexWhere(
                                (element) => element.id == item.id) ??
                            -1;
                        if (index != -1) {
                          feedRoomItemList![index] = item;
                        }
                        _feedBloc.users.addAll(curr.userData);
                        _feedBloc.topics.addAll(curr.topics);
                        postUploading.value = false;
                        rebuildPostWidget.value = !rebuildPostWidget.value;

                        LMFeedCore.showSnackBar(context,
                            '$postTitleFirstCap Edited', _widgetSource);
                      }
                      if (curr is LMFeedNewPostErrorState) {
                        postUploading.value = false;
                        isPostEditing = false;
                        LMFeedCore.showSnackBar(
                          context,
                          curr.errorMessage,
                          _widgetSource,
                        );
                      }
                      if (curr is LMFeedPostUpdateState) {
                        List<LMPostViewData>? feedRoomItemList =
                            _pagingController.itemList;
                        int index = feedRoomItemList?.indexWhere(
                                (element) => element.id == curr.postId) ??
                            -1;

                        if (index != -1) {
                          feedRoomItemList![index] =
                              LMFeedPostUtils.updatePostData(
                            postViewData: curr.post ?? feedRoomItemList[index],
                            actionType: curr.actionType,
                            commentId: curr.commentId,
                            pollOptions: curr.pollOptions,
                          );
                        }
                        rebuildPostWidget.value = !rebuildPostWidget.value;
                      }
                      if (curr is LMFeedPostDeletionErrorState) {
                        LMFeedCore.showSnackBar(
                          context,
                          curr.message,
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
                SliverToBoxAdapter(
                  child: config!.enableTopicFiltering
                      ? ValueListenableBuilder(
                          valueListenable: rebuildTopicFeed,
                          builder: (context, _, __) {
                            return FutureBuilder<GetTopicsResponse>(
                              future: getTopicsResponse,
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox.shrink();
                                } else if (snapshot.hasData &&
                                    snapshot.data != null &&
                                    snapshot.data!.success == true) {
                                  if (snapshot.data!.topics!.isNotEmpty) {
                                    return widget.topicBarBuilder
                                            ?.call(_defTopicBar()) ??
                                        _defTopicBar();
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }
                                return const SizedBox();
                              },
                            );
                          })
                      : const SizedBox(),
                ),
                if (isDesktopWeb)
                  SliverPadding(padding: EdgeInsets.only(top: 12.0)),
                BlocListener<LMFeedUniversalBloc, LMFeedUniversalState>(
                  bloc: _feedBloc,
                  listener: (context, LMFeedUniversalState state) =>
                      updatePagingControllers(state),
                  child: ValueListenableBuilder(
                    valueListenable: rebuildPostWidget,
                    builder: (context, _, __) {
                      return PagedSliverList<int, LMPostViewData>(
                        pagingController: _pagingController,
                        builderDelegate:
                            PagedChildBuilderDelegate<LMPostViewData>(
                          itemBuilder: (context, item, index) {
                            if (_feedBloc.users[item.uuid] == null) {
                              return const SizedBox();
                            }
                            LMFeedPostWidget postWidget =
                                LMFeedDefaultWidgets.instance.defPostWidget(
                              context,
                              feedThemeData,
                              item,
                              _widgetSource,
                              postUploading,
                            );
                            return widget.postBuilder
                                    ?.call(context, postWidget, item) ??
                                _widgetsBuilder.postWidgetBuilder.call(
                                    context, postWidget, item,
                                    source: _widgetSource);
                          },
                          noItemsFoundIndicatorBuilder: (context) {
                            if (_feedBloc.state
                                    is LMFeedUniversalFeedLoadedState &&
                                (_feedBloc.state
                                        as LMFeedUniversalFeedLoadedState)
                                    .topics
                                    .isNotEmpty) {
                              return _widgetsBuilder.noPostUnderTopicFeed(
                                  context,
                                  actionable: changeFilter(context));
                            }
                            return _widgetsBuilder
                                .noItemsFoundIndicatorBuilderFeed(context,
                                    createPostButton:
                                        createPostButton(context));
                          },
                          noMoreItemsIndicatorBuilder: (context) {
                            return widget.noMoreItemsIndicatorBuilder
                                    ?.call(context) ??
                                _widgetsBuilder
                                    .noMoreItemsIndicatorBuilderFeed(context);
                          },
                          newPageProgressIndicatorBuilder: (context) {
                            return widget.newPageProgressIndicatorBuilder
                                    ?.call(context) ??
                                _widgetsBuilder
                                    .newPageProgressIndicatorBuilderFeed(
                                        context);
                          },
                          firstPageProgressIndicatorBuilder: (context) =>
                              widget.firstPageProgressIndicatorBuilder
                                  ?.call(context) ??
                              _widgetsBuilder
                                  .firstPageProgressIndicatorBuilderFeed(
                                      context),
                          firstPageErrorIndicatorBuilder: (context) =>
                              widget.firstPageErrorIndicatorBuilder
                                  ?.call(context) ??
                              _widgetsBuilder
                                  .firstPageErrorIndicatorBuilderFeed(context),
                          newPageErrorIndicatorBuilder: (context) =>
                              widget.newPageErrorIndicatorBuilder
                                  ?.call(context) ??
                              _widgetsBuilder
                                  .newPageErrorIndicatorBuilderFeed(context),
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
              LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
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
        if (config?.showNotificationFeedIcon ?? true)
          LMFeedButton(
            onTap: () {
              // check if the user is a guest user
              if (LMFeedUserUtils.isGuestUser()) {
                LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
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

  LMFeedTopicBar _defTopicBar() {
    return LMFeedTopicBar(
      isDesktopWeb: isDesktopWeb,
      selectedTopics: _feedBloc.selectedTopics,
      openTopicSelector: openTopicSelector,
      clearAllSelection: () {
        updateSelectedTopics([]);
      },
      removeTopicFromSelection: (topic) {
        List<LMTopicViewData> updatedTopics = [..._feedBloc.selectedTopics];
        updatedTopics.removeWhere((element) => element.id == topic.id);
        updateSelectedTopics(updatedTopics);
      },
      style: LMFeedTopicBarStyle(
          height: 60,
          padding: EdgeInsets.symmetric(vertical: isDesktopWeb ? 0.0 : 8.0),
          border: isDesktopWeb
              ? null
              : Border.symmetric(
                  horizontal: BorderSide(
                    color: LMFeedCore.theme.onContainer,
                    width: 0.1,
                  ),
                )),
    );
  }

  void openTopicSelector(BuildContext context) {
    LMFeedTopicSelectionWidgetType topicSelectionWidgetType =
        config!.topicSelectionWidgetType;
    if (topicSelectionWidgetType ==
        LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet) {
      showTopicSelectSheet(context);
    } else if (topicSelectionWidgetType ==
        LMFeedTopicSelectionWidgetType.showTopicSelectionScreen) {
      navigateToTopicSelectScreen(context);
    }
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
        // TODO: add video thumbnail
        // final thumbnailFile = VideoCompress.getFileThumbnail(
        //   media.mediaFile!.path,
        //   quality: 50, // default(100)
        //   position: -1, // default(-1)
        // );
        // return FutureBuilder(
        //   future: thumbnailFile,
        //   builder: (context, snapshot) {
        //     if (snapshot.hasData) {
        //       return Container(
        //         height: 50,
        //         width: 50,
        //         clipBehavior: Clip.hardEdge,
        //         decoration: BoxDecoration(
        //           color: Colors.black,
        //           borderRadius: BorderRadius.circular(6.0),
        //         ),
        //         child: LMFeedImage(
        //           imageFile: snapshot.data,
        //           style: const LMFeedPostImageStyle(
        //             boxFit: BoxFit.contain,
        //           ),
        //         ),
        //       );
        //     }
        //     return LMFeedLoader();
        //   },
        // );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  LMFeedButton changeFilter(BuildContext context) => LMFeedButton(
        style: LMFeedButtonStyle(
          borderRadius: 48,
          border: Border.all(
            color: feedThemeData.primaryColor,
            width: 2,
          ),
          height: 40,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        ),
        text: LMFeedText(
          text: "Change Filter",
          style: LMFeedTextStyle(
            textAlign: TextAlign.center,
            textStyle: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: feedThemeData.primaryColor),
          ),
        ),
        onTap: () => openTopicSelector(context),
      );

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
