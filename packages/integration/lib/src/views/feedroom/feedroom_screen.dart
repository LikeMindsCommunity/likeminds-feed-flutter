import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/feedroom/feedroom_bloc.dart';
import 'package:video_compress/video_compress.dart';

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
  });

  final int feedroomId;

  // Builder for appbar
  final LMFeedPostAppBarBuilder? appBarBuilder;

  // Builder for custom widget on top
  final LMFeedContextWidgetBuilder? customWidgetBuilder;
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

  final LMFeedTopicBarBuilder? topicBarBuilder;

  final FloatingActionButtonLocation? floatingActionButtonLocation;

  final LMFeedRoomScreenConfig? config;

  @override
  State<LMFeedRoomScreen> createState() => _LMFeedRoomScreenState();
}

class _LMFeedRoomScreenState extends State<LMFeedRoomScreen> {
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
  LMFeedThemeData feedThemeData = LMFeedCore.theme;
  LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier postUploading = ValueNotifier(false);
  bool right = true;

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
    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.feedOpened,
        deprecatedEventName: LMFeedAnalyticsKeysDep.feedOpened,
        eventProperties: {
          'feed_type': 'feedroom',
        },
      ),
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
    return LMFeedCore.widgetUtility.scaffold(
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
                  ? widget.customWidgetBuilder == null
                      ? LMFeedPostSomething(
                          onTap: userPostingRights
                              ? () async {
                                  LMFeedAnalyticsBloc.instance
                                      .add(const LMFeedFireAnalyticsEvent(
                                    eventName:
                                        LMFeedAnalyticsKeys.postCreationStarted,
                                    deprecatedEventName: LMFeedAnalyticsKeysDep
                                        .postCreationStarted,
                                    eventProperties: {},
                                  ));

                                  LMFeedVideoProvider.instance
                                      .forcePauseAllControllers();
                                  // ignore: use_build_context_synchronously
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            LMFeedComposeScreen(
                                              feedroomId: widget.feedroomId,
                                            )),
                                  );
                                }
                              : () {
                                  LMFeedCore.showSnackBar(
                                    LMFeedSnackBar(
                                      content: LMFeedText(
                                        text:
                                            "You do not have permission to create a post",
                                      ),
                                    ),
                                  );
                                })
                      : widget.customWidgetBuilder!(context)
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
                      LMFeedSnackBar(
                        content: LMFeedText(
                          text: 'Post Deleted',
                        ),
                      ),
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
                    LMPostViewData? item = curr.postData;
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
                      LMFeedSnackBar(
                        content: LMFeedText(
                          text: curr.errorMessage,
                        ),
                      ),
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
                          feedRoomItemList[index], curr.actionType);
                    }
                    rebuildPostWidget.value = !rebuildPostWidget.value;
                  }
                  if (curr is LMFeedPostDeletionErrorState) {
                    LMFeedCore.showSnackBar(
                      LMFeedSnackBar(
                        content: LMFeedText(text: (curr).message),
                      ),
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
                    return Container(
                      height: 72,
                      color: feedThemeData.container,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 6,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              getLoaderThumbnail(state.thumbnailMedia),
                              LikeMindsTheme.kHorizontalPaddingMedium,
                              const Text('Uploading Post')
                            ],
                          ),
                          StreamBuilder<num>(
                              initialData: 0,
                              stream: state.progress,
                              builder: (context, snapshot) {
                                return SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    value: (snapshot.data == null ||
                                            snapshot.data == 0.0
                                        ? null
                                        : snapshot.data?.toDouble()),
                                    valueColor: AlwaysStoppedAnimation(
                                        feedThemeData.primaryColor),
                                    strokeWidth: 3,
                                  ),
                                );
                              }),
                        ],
                      ),
                    );
                  }
                  if (state is LMFeedNewPostErrorState) {
                    return Container(
                      height: 72,
                      color: feedThemeData.backgroundColor,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20.0,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          LMFeedText(
                            text: "Post uploading failed.. try again",
                            style: LMFeedTextStyle(
                              maxLines: 1,
                              textStyle: TextStyle(
                                color: Colors.red,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          LMFeedButton(
                            onTap: () {
                              newPostBloc.add(state.event!);
                            },
                            style: LMFeedButtonStyle(
                              icon: LMFeedIcon(
                                type: LMFeedIconType.icon,
                                icon: Icons.refresh_rounded,
                              ),
                            ),
                          )
                        ],
                      ),
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
                            defPostWidget(context, feedThemeData, item);
                        return widget.postBuilder
                                ?.call(context, postWidget, item) ??
                            LMFeedCore.widgetUtility.postWidgetBuilder
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

  LMFeedAppBar _defAppBar() {
    return LMFeedAppBar(
      leading: isCm
          ? LMFeedButton(
              onTap: () {
                // _feedBloc.add(LMFeedGetFeedRoomListEvent(offset: 1));
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
      } else if (media.mediaType == LMMediaType.video) {
        final thumbnailFile = VideoCompress.getFileThumbnail(
          media.mediaFile!.path,
          quality: 50, // default(100)
          position: -1, // default(-1)
        );
        return FutureBuilder(
          future: thumbnailFile,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              return Container(
                height: 50,
                width: 50,
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(6.0),
                ),
                child: LMFeedImage(
                  imageFile: snapshot.data,
                  style: const LMFeedPostImageStyle(
                    boxFit: BoxFit.contain,
                  ),
                ),
              );
            }
            return LMFeedLoader();
          },
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  LMFeedPostWidget defPostWidget(BuildContext context,
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
      footer: _defFooterWidget(context, post),
      header: _defPostHeader(context, post),
      content: _defContentWidget(post),
      media: _defPostMedia(context, post),
      topicWidget: _defTopicWidget(post),
    );
  }

  LMFeedPostTopic _defTopicWidget(LMPostViewData post) {
    return LMFeedPostTopic(
      topics: post.topics,
      post: post,
      style: feedThemeData.topicStyle,
    );
  }

  LMFeedPostContent _defContentWidget(LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String? uuid) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid ?? post.uuid,
            context: context,
          ),
        );
      },
      style: feedThemeData.contentStyle,
      text: post.text,
      heading: post.heading,
    );
  }

  LMFeedPostFooter _defFooterWidget(BuildContext context, LMPostViewData post) {
    return LMFeedPostFooter(
      likeButton: defLikeButton(context, post),
      commentButton: defCommentButton(context, post),
      saveButton: defSaveButton(post),
      shareButton: defShareButton(post),
      repostButton: defRepostButton(context, post),
      postFooterStyle: feedThemeData.footerStyle,
      showRepostButton: !post.isRepost,
    );
  }

  LMFeedPostHeader _defPostHeader(
      BuildContext context, LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: postViewData.user,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: feedThemeData.headerStyle,
      onProfileTap: () {
        LMFeedCore.instance.lmFeedClient
            .routeToProfile(postViewData.user.sdkClientInfo.uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: postViewData.user.sdkClientInfo.uuid,
            context: context,
          ),
        );
      },
      menu: LMFeedMenu(
        menuItems: postViewData.menuItems,
        removeItemIds: {postReportId, postEditId},
        action: LMFeedMenuAction(
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
          onPostReport: () => handlePostReportAction(postViewData),
          onPostUnpin: () => handlePostPinAction(postViewData),
          onPostPin: () => handlePostPinAction(postViewData),
          onPostDelete: () {
            String postCreatorUUID = postViewData.user.sdkClientInfo.uuid;
            showDialog(
              context: context,
              builder: (childContext) => LMFeedDeleteConfirmationDialog(
                title: 'Delete Post',
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
                        "user_id": currentUser?.sdkClientInfo.uuid,
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
      ),
    );
  }

  LMFeedPostMedia _defPostMedia(
    BuildContext context,
    LMPostViewData post,
  ) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      postId: post.id,
      style: feedThemeData.mediaStyle,
      carouselIndicatorBuilder:
          LMFeedCore.widgetUtility.postMediaCarouselIndicatorBuilder,
      imageBuilder: LMFeedCore.widgetUtility.imageBuilder,
      videoBuilder: LMFeedCore.widgetUtility.videoBuilder,
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

  LMFeedButton defLikeButton(
          BuildContext context, LMPostViewData postViewData) =>
      LMFeedButton(
        isActive: postViewData.isLiked,
        text: LMFeedText(
            text: LMFeedPostUtils.getLikeCountTextWithCount(
                postViewData.likeCount)),
        style: feedThemeData.footerStyle.likeButtonStyle,
        onTextTap: () {
          LMFeedVideoProvider.instance.pauseCurrentVideo();

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
          rebuildPostWidget.value = !rebuildPostWidget.value;

          final likePostRequest =
              (LikePostRequestBuilder()..postId(postViewData.id)).build();

          LMFeedAnalyticsBloc.instance.add(
            LMFeedFireAnalyticsEvent(
              eventName: LMFeedAnalyticsKeys.postLiked,
              deprecatedEventName: LMFeedAnalyticsKeysDep.postLiked,
              eventProperties: {'post_id': postViewData.id},
            ),
          );

          final LikePostResponse response =
              await LMFeedCore.client.likePost(likePostRequest);

          if (!response.success) {
            postViewData.isLiked = !postViewData.isLiked;
            postViewData.likeCount = postViewData.isLiked
                ? postViewData.likeCount + 1
                : postViewData.likeCount - 1;
            rebuildPostWidget.value = !rebuildPostWidget.value;
          }
        },
      );

  LMFeedButton defCommentButton(BuildContext context, LMPostViewData post) =>
      LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(post.commentCount),
        ),
        style: feedThemeData.footerStyle.commentButtonStyle,
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
          postViewData.isSaved = !postViewData.isSaved;
          rebuildPostWidget.value = !rebuildPostWidget.value;
          LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
              postId: postViewData.id,
              actionType: postViewData.isSaved
                  ? LMFeedPostActionType.saved
                  : LMFeedPostActionType.unsaved));

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            postViewData.isSaved = !postViewData.isSaved;
            rebuildPostWidget.value = !rebuildPostWidget.value;
            LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
                postId: postViewData.id,
                actionType: postViewData.isSaved
                    ? LMFeedPostActionType.saved
                    : LMFeedPostActionType.unsaved));
          }
        },
        style: feedThemeData.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton(LMPostViewData postViewData) => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          LMFeedDeepLinkHandler().sharePost(postViewData.id);
        },
        style: feedThemeData.footerStyle.shareButtonStyle,
      );

  LMFeedButton defRepostButton(
          BuildContext context, LMPostViewData postViewData) =>
      LMFeedButton(
        text: LMFeedText(
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: postViewData.isRepostedByUser
                  ? feedThemeData.primaryColor
                  : null,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          text: postViewData.repostCount == 0
              ? ''
              : postViewData.repostCount.toString(),
        ),
        onTap: right
            ? () async {
                if (!postUploading.value && feedroom != null) {
                  LMFeedAnalyticsBloc.instance.add(
                      const LMFeedFireAnalyticsEvent(
                          eventName: LMFeedAnalyticsKeys.postCreationStarted,
                          deprecatedEventName:
                              LMFeedAnalyticsKeysDep.postCreationStarted,
                          eventProperties: {}));

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
                        feedroomId: widget.feedroomId,
                      ),
                    ),
                  );
                } else {
                  LMFeedCore.showSnackBar(
                    LMFeedSnackBar(
                      content: LMFeedText(
                        text: 'A post is already uploading.',
                      ),
                    ),
                  );
                }
              }
            : () {
                LMFeedCore.showSnackBar(
                  LMFeedSnackBar(
                    content: LMFeedText(
                      text: "You do not have permission to create a post",
                    ),
                  ),
                );
              },
        style: feedThemeData.footerStyle.repostButtonStyle?.copyWith(
            icon: feedThemeData.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedThemeData.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? feedThemeData.primaryColor
                          : null),
            ),
            activeIcon:
                feedThemeData.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedThemeData.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color: postViewData.isRepostedByUser
                          ? feedThemeData.primaryColor
                          : null),
            )),
      );

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
        width: 160,
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
      onTap: right
          ? () async {
              if (!postUploading.value &&
                  LMFeedPostBloc.instance.state != LMFeedUploadingState()) {
                LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
                    eventName: LMFeedAnalyticsKeys.postCreationStarted,
                    deprecatedEventName:
                        LMFeedAnalyticsKeysDep.postCreationStarted,
                    eventProperties: {}));

                LMFeedVideoProvider.instance.forcePauseAllControllers();
                // ignore: use_build_context_synchronously
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LMFeedComposeScreen(
                      feedroomId: widget.feedroomId,
                    ),
                  ),
                );
              } else {
                LMFeedCore.showSnackBar(
                  LMFeedSnackBar(
                    content: LMFeedText(
                      text: 'A post is already uploading.',
                    ),
                  ),
                );
              }
            }
          : () {
              LMFeedCore.showSnackBar(
                LMFeedSnackBar(
                  content: LMFeedText(
                    text: "You do not have permission to create a post",
                  ),
                ),
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
          backgroundColor:
              right ? feedThemeData.primaryColor : feedThemeData.disabledColor,
          placement: LMFeedIconButtonPlacement.end,
          margin: 5.0,
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
        onTap: right
            ? () async {
                if (!postUploading.value) {
                  LMFeedAnalyticsBloc.instance.add(
                      const LMFeedFireAnalyticsEvent(
                          eventName: LMFeedAnalyticsKeys.postCreationStarted,
                          deprecatedEventName:
                              LMFeedAnalyticsKeysDep.postCreationStarted,
                          eventProperties: {}));

                  LMFeedVideoProvider.instance.forcePauseAllControllers();
                  // ignore: use_build_context_synchronously
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LMFeedComposeScreen(
                        feedroomId: widget.feedroomId,
                      ),
                    ),
                  );
                } else {
                  LMFeedCore.showSnackBar(
                    LMFeedSnackBar(
                      content: LMFeedText(
                        text: 'A post is already uploading.',
                      ),
                    ),
                  );
                }
              }
            : () {
                LMFeedCore.showSnackBar(
                  LMFeedSnackBar(
                    content: LMFeedText(
                      text: "You do not have permission to create a post",
                    ),
                  ),
                );
              },
      );

  Future<dynamic> handlePostReportAction(LMPostViewData postViewData) {
    return showModalBottomSheet(
      context: context,
      useRootNavigator: true,
      useSafeArea: true,
      isScrollControlled: true,
      elevation: 10,
      enableDrag: true,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
        minHeight: MediaQuery.of(context).size.height * 0.3,
      ),
      backgroundColor: feedThemeData.container,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) => LMFeedReportBottomSheet(
        entityId: postViewData.id,
        entityType: 5,
        entityCreatorId: postViewData.uuid,
      ),
    );
  }

  void handlePostPinAction(LMPostViewData postViewData) async {
    postViewData.isPinned = !postViewData.isPinned;

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        postId: postViewData.id,
        actionType: postViewData.isPinned
            ? LMFeedPostActionType.pinned
            : LMFeedPostActionType.unpinned));

    if (postViewData.isPinned) {
      int index = postViewData.menuItems
          .indexWhere((element) => element.id == postPinId);
      if (index != -1) {
        postViewData.menuItems[index].title = "Unpin This Post";
        postViewData.menuItems[index].id = postUnpinId;
      }
    } else {
      int index = postViewData.menuItems
          .indexWhere((element) => element.id == postUnpinId);
      if (index != -1) {
        postViewData.menuItems[index]
          ..title = "Pin This Post"
          ..id = postPinId;
      }
    }

    rebuildPostWidget.value = !rebuildPostWidget.value;

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    if (!response.success) {
      postViewData.isPinned = !postViewData.isPinned;

      if (postViewData.isPinned) {
        int index = postViewData.menuItems
            .indexWhere((element) => element.id == postUnpinId);
        if (index != -1) {
          postViewData.menuItems[index]
            ..title = "Unpin This Post"
            ..id = postUnpinId;
        }
      } else {
        int index = postViewData.menuItems
            .indexWhere((element) => element.id == postPinId);

        if (index != -1) {
          postViewData.menuItems[index]
            ..title = "Pin This Post"
            ..id = postPinId;
        }
      }

      rebuildPostWidget.value = !rebuildPostWidget.value;

      LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
          postId: postViewData.id,
          actionType: postViewData.isPinned
              ? LMFeedPostActionType.pinned
              : LMFeedPostActionType.unpinned));
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