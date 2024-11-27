import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/feedroom/feedroom_bloc.dart';

part 'feedroom_screen_configuration.dart';

/// {@template feed_screen}
/// A screen to display the feed.
/// The feed can be customized by passing in the required parameters
/// Post creation can be enabled or disabled
/// Post Builder can be used to customize the post widget
/// Topic Chip Builder can be used to customize the topic chip widget
///
/// {@endtemplate}
class LMFeedRoomScreen extends StatefulWidget {
  const LMFeedRoomScreen({
    super.key,
    required this.feedroomId,
    this.appBarBuilder,
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

  final int feedroomId;

  // Builder for appbar
  final LMFeedPostAppBarBuilder? appBarBuilder;

  /// Builder for custom widget
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

  final LMFeedRoomScreenConfig? config;

  @override
  State<LMFeedRoomScreen> createState() => _LMFeedRoomScreenState();

  LMFeedRoomScreen copyWith({
    int? feedroomId,
    LMFeedPostAppBarBuilder? appBarBuilder,
    final LMFeedCustomWidgetBuilder? customWidgetBuilder,
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
    LMFeedRoomScreenConfig? config,
  }) {
    return LMFeedRoomScreen(
      feedroomId: feedroomId ?? this.feedroomId,
      appBarBuilder: appBarBuilder ?? this.appBarBuilder,
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

class _LMFeedRoomScreenState extends State<LMFeedRoomScreen> {
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

  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
  LMFeedThemeData feedThemeData = LMFeedCore.theme;
  LMFeedWidgetBuilderDelegate _widgetsBuilder = LMFeedCore.config.widgetBuilderDelegate;
  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.feedroom;
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier<bool> postUploading = ValueNotifier(false);
  bool isPostEditing = false;

  LMFeedRoomScreenConfig? config;
  final ScrollController _controller = ScrollController();

  // notifies value listenable builder to rebuild the topic feed
  ValueNotifier<bool> rebuildTopicFeed = ValueNotifier(false);

  // future to get the topics
  Future<GetTopicsResponse>? getTopicsResponse;

  // bloc to handle universal feed
  late final LMFeedRoomBloc _feedBloc; // bloc to fetch the feedroom data
  bool isCm = LMFeedUserUtils
      .checkIfCurrentUserIsCM(); // whether the logged in user is a community manager or not

  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();

  // future to get the unread notification count
  late Future<GetUnreadNotificationCountResponse> getUnreadNotificationCount;

  // used to rebuild the appbar
  final ValueNotifier _rebuildAppBar = ValueNotifier(false);

  // to control paging on FeedRoom View
  final PagingController<int, LMPostViewData> _pagingController =
      PagingController(firstPageKey: 1);

  bool userPostingRights = true;

  LMFeedRoomViewData? feedroom;

  @override
  void initState() {
    super.initState();
    _addPaginationListener();
    getTopicsResponse = LMFeedCore.client.getTopics(
      (GetTopicsRequestBuilder()
            ..page(1)
            ..pageSize(20))
          .build(),
    );

    Bloc.observer = LMFeedBlocObserver();
    _feedBloc = LMFeedRoomBloc.instance;
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();
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
          state is LMFeedEditPostErrorState) {
        postUploading.value = false;
        isPostEditing = false;
      }
    });

    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.feedOpened,
        eventProperties: {
          'feed_type': 'feedroom',
        },
      ),
    );
  }

  Future<GetUserFeedMetaResponse> getUserFeedMetaFuture() {
    return LMFeedCore.client.getUserFeedMeta(
      (GetUserFeedMetaRequestBuilder()..uuid(currentUser?.uuid ?? '')).build(),
    );
  }

  void updateSelectedTopics(List<LMTopicViewData> topics) {
    _feedBloc.selectedTopics = topics;
    rebuildTopicFeed.value = !rebuildTopicFeed.value;
    clearPagingController();
    _feedBloc.add(
      LMFeedGetFeedRoomEvent(
        offset: 1,
        feedRoomId: widget.feedroomId,
        topics: _feedBloc.selectedTopics,
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
          LMFeedGetFeedRoomEvent(
            offset: pageKey,
            feedRoomId: widget.feedroomId,
            topics: _feedBloc.selectedTopics,
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(LMFeedRoomState? state) {
    if (state is LMFeedRoomLoadedState) {
      List<LMPostViewData> listOfPosts = state.posts;
      if (state.posts.length < 10) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, state.pageKey + 1);
      }

      feedroom = state.feedRoom;
      _rebuildAppBar.value = !_rebuildAppBar.value;
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
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

  @override
  Widget build(BuildContext context) {
    config = widget.config ?? LMFeedCore.config.feedRoomScreenConfig;
    return LMFeedCore.config.widgetBuilderDelegate.scaffold(
      onPopInvoked: (p0) {
        if (p0) {
          _feedBloc.add(LMFeedGetFeedRoomListEvent(offset: 1));
          _feedBloc.selectedTopics = [];
          // Navigator.pop(context);
        }
      },
      backgroundColor: feedThemeData.backgroundColor,
      appBar: widget.appBarBuilder?.call(context, _defAppBar()) ?? _defAppBar(),
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
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          refresh();
          clearPagingController();
        },
        color: feedThemeData.primaryColor,
        backgroundColor: feedThemeData.container,
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverToBoxAdapter(
              child: config!.showCustomWidget
                  ? widget.customWidgetBuilder
                          ?.call(context, _defPostSomethingWidget(context)) ??
                      _defPostSomethingWidget(context)
                  : const SizedBox(),
            ),
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
            SliverToBoxAdapter(
              child: BlocConsumer<LMFeedPostBloc, LMFeedPostState>(
                bloc: newPostBloc,
                listener: (prev, curr) {
                  if (curr is LMFeedPostDeletedState) {
                    // show a snackbar when post is deleted
                    // will only be shown if a messenger key is provided
                    LMFeedCore.showSnackBar(
                      context,
                      'Post Deleted',
                      _widgetSource,
                    );
                    List<LMPostViewData>? feedRoomItemList =
                        _pagingController.itemList;
                    feedRoomItemList
                        ?.removeWhere((item) => item.id == curr.postId);
                    _pagingController.itemList = feedRoomItemList;
                    rebuildPostWidget.value = !rebuildPostWidget.value;
                  }
                  if (curr is LMFeedNewPostUploadingState ||
                      curr is LMFeedEditPostUploadingState) {
                    // if current state is uploading
                    // change postUploading flag to true
                    // to block new post creation
                    postUploading.value = true;
                  }
                  if (prev is LMFeedNewPostUploadingState ||
                      prev is LMFeedEditPostUploadingState) {
                    // if state has changed from uploading
                    // change postUploading flag to false
                    // to allow new post creation
                    postUploading.value = false;
                  }
                  if (curr is LMFeedNewPostUploadedState) {
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
                    _pagingController.itemList = feedRoomItemList;
                    postUploading.value = false;
                    rebuildPostWidget.value = !rebuildPostWidget.value;
                  }
                  if (curr is LMFeedEditPostUploadedState) {
                    LMPostViewData? item = curr.postData.copyWith();
                    List<LMPostViewData>? feedRoomItemList =
                        _pagingController.itemList;
                    int index = feedRoomItemList
                            ?.indexWhere((element) => element.id == item.id) ??
                        -1;
                    if (index != -1) {
                      feedRoomItemList![index] = item;
                    }
                    postUploading.value = false;
                    rebuildPostWidget.value = !rebuildPostWidget.value;
                  }
                  if (curr is LMFeedNewPostErrorState) {
                    postUploading.value = false;
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
                      feedRoomItemList![index] = LMFeedPostUtils.updatePostData(
                          postViewData: feedRoomItemList[index],
                          actionType: curr.actionType);
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
                  if (state is LMFeedEditPostUploadingState) {
                    return Container(
                      height: 72,
                      color: feedThemeData.container,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 6,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              SizedBox(
                                width: 50,
                                height: 50,
                              ),
                              LikeMindsTheme.kHorizontalPaddingMedium,
                              Text('Saving')
                            ],
                          ),
                          LMFeedLoader(),
                        ],
                      ),
                    );
                  }
                  if (state is LMFeedNewPostUploadingState) {
                    if (postUploading.value) {
                      return LMPostUploadingBanner(
                        isUploading: true,
                        uploadingMessage:
                            '${isPostEditing ? "Saving" : "Creating"} $postTitleSmallCap',
                        onRetry: () {},
                        onCancel: () {},
                      );
                    }
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
                            .deleteTemporaryPost(deleteTemporaryPostRequest);
                        newPostBloc.add(LMFeedPostInitiateEvent());
                      },
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            BlocListener<LMFeedRoomBloc, LMFeedRoomState>(
              bloc: _feedBloc,
              listener: (context, LMFeedRoomState state) =>
                  updatePagingControllers(state),
              child: ValueListenableBuilder(
                valueListenable: rebuildPostWidget,
                builder: (context, _, __) {
                  return PagedSliverList<int, LMPostViewData>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<LMPostViewData>(
                      itemBuilder: (context, item, index) {
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
                            LMFeedCore.config.widgetBuilderDelegate.postWidgetBuilder
                                .call(context, postWidget, item);
                      },
                      noItemsFoundIndicatorBuilder: (context) {
                        if (_feedBloc.state is LMFeedUniversalFeedLoadedState &&
                            (_feedBloc.state as LMFeedUniversalFeedLoadedState)
                                .topics
                                .isNotEmpty) {
                          return _widgetsBuilder.noPostUnderTopicFeed(context,
                              actionable: changeFilter(context));
                        }
                        return _widgetsBuilder.noItemsFoundIndicatorBuilderFeed(
                            context,
                            createPostButton: createPostButton(context));
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
                                .newPageProgressIndicatorBuilderFeed(context);
                      },
                      firstPageProgressIndicatorBuilder: (context) =>
                          widget.firstPageProgressIndicatorBuilder
                              ?.call(context) ??
                          _widgetsBuilder
                              .firstPageProgressIndicatorBuilderFeed(context),
                      firstPageErrorIndicatorBuilder: (context) =>
                          widget.firstPageErrorIndicatorBuilder
                              ?.call(context) ??
                          _widgetsBuilder
                              .firstPageErrorIndicatorBuilderFeed(context),
                      newPageErrorIndicatorBuilder: (context) =>
                          widget.newPageErrorIndicatorBuilder?.call(context) ??
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
    );
  }

  LMFeedPostSomething _defPostSomethingWidget(BuildContext context) {
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
      leading: isCm
          ? LMFeedButton(
              onTap: () {
                _feedBloc.add(LMFeedGetFeedRoomListEvent(offset: 1));
                _feedBloc.selectedTopics = [];
                Navigator.pop(context);
              },
              style: LMFeedButtonStyle.basic().copyWith(
                  icon: LMFeedIcon(
                type: LMFeedIconType.icon,
                icon: Icons.arrow_back,
              )),
            )
          : null,
      title: GestureDetector(
        onTap: () {
          _scrollToTop();
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 4.0),
          child: ValueListenableBuilder(
            valueListenable: _rebuildAppBar,
            builder: (context, value, __) {
              if (feedroom == null) {
                return LMFeedTileShimmer();
              }
              return LMFeedText(
                text: feedroom!.title,
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    color: feedThemeData.onContainer,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      style: LMFeedAppBarStyle.basic().copyWith(
        backgroundColor: feedThemeData.container,
        height: 48,
      ),
    );
  }

  LMFeedTopicBar _defTopicBar() {
    return LMFeedTopicBar(
      selectedTopics: _feedBloc.selectedTopics,
      openTopicSelector: openTopicSelector,
      style: const LMFeedTopicBarStyle(
        height: 60,
      ),
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
        // TODO: Add video thumbnail
        // File videoThumbnail;

        // if (kIsWeb) {
        //   videoThumbnail = File(media.attachmentMeta.path!);
        // } else {
        //   videoThumbnail = File.fromRawPath(media.attachmentMeta.bytes!);
        // }

        // final thumbnailFile = VideoCompress.getFileThumbnail(
        //   videoThumbnail.path,
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
        //           image: snapshot.data,
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
        text: "Create Post",
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
          width: 153,
          height: 44,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          borderRadius: 28,
          backgroundColor: userPostingRights
              ? feedThemeData.primaryColor
              : feedThemeData.disabledColor,
          placement: LMFeedIconButtonPlacement.end,
          gap: 5.0,
        ),
        text: LMFeedText(
          text: "Create Post",
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
