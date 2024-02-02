import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/simple_bloc_observer.dart';
import 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
import 'package:likeminds_feed_flutter_core/src/views/feed/topic_select_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/media/media_preview_screen.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/widgets/delete_dialog.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post_something.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/topic_bottom_sheet.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:overlay_support/overlay_support.dart';

part 'feed_screen_configuration.dart';

class LMFeedScreen extends StatefulWidget {
  const LMFeedScreen({
    super.key,
    this.appBar,
    this.customWidgetBuilder,
    this.topicChipBuilder,
    this.postBuilder,
    this.floatingActionButton,
    this.emptyFeedViewBuilder,
    this.firstPageLoaderBuilder,
    this.paginationLoaderBuilder,
    this.feedErrorViewBuilder,
    this.noNewPageWidgetBuilder,
    this.enablePostCreation = true,
    this.config,
    this.topicBarBuilder,
  });

  //Builder for appbar
  final LMFeedPostAppBarBuilder? appBar;

  //Callback for activity

  //Builder for custom widget on top
  final LMFeedContextWidgetBuilder? customWidgetBuilder;
  //Builder for topic chip [Button]
  final Widget Function(BuildContext context, List<LMTopicViewData>? topic)?
      topicChipBuilder;

  // Builder for post item
  // {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;
  // Floating action button
  // i.e. new post button
  final Widget? floatingActionButton;
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

  final LMFeedTopicBarBuilder? topicBarBuilder;

  final bool enablePostCreation;

  final LMFeedScreenConfig? config;

  @override
  State<LMFeedScreen> createState() => _LMFeedScreenState();
}

class _LMFeedScreenState extends State<LMFeedScreen> {
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier postUploading = ValueNotifier(false);
  bool right = true;

  LMFeedScreenConfig? config;
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
  late final LMFeedBloc _feedBloc; // bloc to fetch the feedroom data
  bool isCm = LMFeedUserLocalPreference.instance
      .fetchMemberState(); // whether the logged in user is a community manager or not

  LMUserViewData user = LMUserViewDataConvertor.fromUser(
      LMFeedUserLocalPreference.instance.fetchUserData());

  // future to get the unread notification count
  late Future<GetUnreadNotificationCountResponse> getUnreadNotificationCount;

  // used to rebuild the appbar
  final ValueNotifier _rebuildAppBar = ValueNotifier(false);

  // to control paging on FeedRoom View
  final PagingController<int, LMPostViewData> _pagingController =
      PagingController(firstPageKey: 1);

  bool userPostingRights = true;

  LMFeedThemeData? feedThemeData;

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
    _feedBloc = LMFeedBloc.instance;
    _feedBloc.add(
      LMFeedGetUniversalFeedEvent(
        offset: 1,
        topics: _feedBloc.selectedTopics,
      ),
    );
    userPostingRights = checkPostCreationRights();
  }

  bool checkPostCreationRights() {
    final MemberStateResponse memberStateResponse =
        LMFeedUserLocalPreference.instance.fetchMemberRights();
    if (!memberStateResponse.success || memberStateResponse.state == 1) {
      return true;
    }
    final memberRights = LMFeedUserLocalPreference.instance.fetchMemberRight(9);
    return memberRights;
  }

  void updateSelectedTopics(List<LMTopicViewData> topics) {
    _feedBloc.selectedTopics = topics;
    rebuildTopicFeed.value = !rebuildTopicFeed.value;
    clearPagingController();
    _feedBloc.add(
      LMFeedGetUniversalFeedEvent(
        offset: 1,
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

  int _pageFeed = 1; // current index of FeedRoom

  void _addPaginationListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _feedBloc.add(
          LMFeedGetUniversalFeedEvent(
            offset: pageKey,
            topics: _feedBloc.selectedTopics,
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(Object? state) {
    if (state is LMFeedUniversalFeedLoadedState) {
      _pageFeed++;
      List<LMPostViewData> listOfPosts = state.posts;

      _feedBloc.users.addAll(state.users);
      _feedBloc.topics.addAll(state.topics);
      _feedBloc.widgets.addAll(state.widgets);

      if (state.posts.length < 10) {
        _pagingController.appendLastPage(listOfPosts);
      } else {
        _pagingController.appendPage(listOfPosts, _pageFeed);
      }
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
    _pageFeed = 1;
  }

  void showTopicSelectSheet() {
    showModalBottomSheet(
      context: context,
      elevation: 5,
      isDismissible: true,
      useRootNavigator: true,
      backgroundColor: feedThemeData?.container,
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

  void navigateToTopicSelectScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LMFeedTopicSelectScreen(
          onTopicSelected: (updatedTopics) {
            updateSelectedTopics(updatedTopics);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
    feedThemeData = LMFeedTheme.of(context);
    config = widget.config ?? LMFeedCore.config.feedScreenConfig;
    return Scaffold(
      backgroundColor: feedThemeData?.backgroundColor,
      appBar: widget.appBar?.call(context, _defAppBar()) ?? _defAppBar(),
      floatingActionButton: defFloatingActionButton(),
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          refresh();
          clearPagingController();
        },
        color: feedThemeData?.primaryColor,
        backgroundColor: feedThemeData?.container,
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: config!.showCustomWidget
                  ? widget.customWidgetBuilder == null
                      ? LMFeedPostSomething(
                          enabled: userPostingRights,
                        )
                      : widget.customWidgetBuilder!(context)
                  : const SizedBox(),
            ),
            SliverToBoxAdapter(
              child: config!.enableTopicFiltering
                  ? FutureBuilder<GetTopicsResponse>(
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
                    )
                  : const SizedBox(),
            ),
            SliverToBoxAdapter(
              child: BlocConsumer<LMFeedPostBloc, LMFeedPostState>(
                bloc: newPostBloc,
                listener: (prev, curr) {
                  if (curr is LMFeedPostDeletedState) {
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
                    _feedBloc.users.addAll(curr.userData);
                    _feedBloc.topics.addAll(curr.topics);
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
                    _feedBloc.users.addAll(curr.userData);
                    _feedBloc.topics.addAll(curr.topics);
                    postUploading.value = false;
                    rebuildPostWidget.value = !rebuildPostWidget.value;
                  }
                  if (curr is LMFeedNewPostErrorState) {
                    postUploading.value = false;
                    toast(
                      curr.message,
                      duration: Toast.LENGTH_LONG,
                    );
                  }
                  if (curr is LMFeedPostUpdateState) {
                    List<LMPostViewData>? feedRoomItemList =
                        _pagingController.itemList;
                    int index = feedRoomItemList?.indexWhere(
                            (element) => element.id == curr.post.id) ??
                        -1;
                    if (index != -1) {
                      feedRoomItemList![index] = curr.post;
                    }
                    rebuildPostWidget.value = !rebuildPostWidget.value;
                  }
                },
                builder: (context, state) {
                  if (state is LMFeedEditPostUploadingState) {
                    return Container(
                      height: 60,
                      color: feedThemeData?.container,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                      height: 60,
                      color: LikeMindsTheme.whiteColor,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              getLoaderThumbnail(state.thumbnailMedia),
                              LikeMindsTheme.kHorizontalPaddingMedium,
                              const Text('Posting')
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
                                        feedThemeData?.primaryColor),
                                    strokeWidth: 3,
                                  ),
                                );
                              }),
                        ],
                      ),
                    );
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            BlocListener(
              bloc: _feedBloc,
              listener: (context, state) => updatePagingControllers(state),
              child: ValueListenableBuilder(
                valueListenable: rebuildPostWidget,
                builder: (context, _, __) {
                  return PagedSliverList<int, LMPostViewData>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<LMPostViewData>(
                      noItemsFoundIndicatorBuilder: (context) {
                        if (_feedBloc.state is LMFeedUniversalFeedLoadedState &&
                            (_feedBloc.state as LMFeedUniversalFeedLoadedState)
                                .topics
                                .isNotEmpty) {
                          return noPostUnderTopicWidget();
                        }
                        return noPostInFeedWidget();
                      },
                      itemBuilder: (context, item, index) {
                        if (_feedBloc.users[item.userId] == null) {
                          return const SizedBox();
                        }
                        return widget.postBuilder?.call(
                                context,
                                defPostWidget(
                                  feedThemeData,
                                  item,
                                ),
                                item) ??
                            defPostWidget(
                              feedThemeData,
                              item,
                            );
                      },
                      firstPageProgressIndicatorBuilder: (context) =>
                          LMFeedLoader(
                        color: feedThemeData?.primaryColor,
                      ),
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
                color: feedThemeData?.onContainer,
                fontSize: 27,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
      style: LMFeedAppBarStyle.basic().copyWith(
        backgroundColor: feedThemeData?.container,
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

  void openTopicSelector() {
    LMFeedTopicSelectionWidgetType topicSelectionWidgetType =
        config!.topicSelectionWidgetType;
    if (topicSelectionWidgetType ==
        LMFeedTopicSelectionWidgetType.showTopicSelectionBottomSheet) {
      showTopicSelectSheet();
    } else if (topicSelectionWidgetType ==
        LMFeedTopicSelectionWidgetType.showTopicSelectionScreen) {
      navigateToTopicSelectScreen();
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
          child: LMFeedPostImage(
            imageFile: media.mediaFile!,
            style: const LMFeedPostImageStyle(
              boxFit: BoxFit.contain,
            ),
          ),
        );
      } else if (media.mediaType == LMMediaType.document) {
        return const LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: kAssetDocPDFIcon,
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
    VideoController? postVideoController;
    return LMFeedPostWidget(
      post: post,
      topics: _feedBloc.topics,
      user: _feedBloc.users[post.userId]!,
      isFeed: false,
      onTagTap: (String userId) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            userUniqueId: userId,
          ),
        );
      },
      style: feedThemeData?.postStyle,
      onMediaTap: () async {
        // ignore: dead_code
        postVideoController?.player.pause();
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: _feedBloc.users[post.userId]!,
            ),
          ),
        );
        // ignore: dead_code
        postVideoController?.player.play();
      },
      onPostTap: (context, post) {
        // ignore: dead_code
        postVideoController?.player.pause();
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedPostDetailScreen(
              postId: post.id,
              postBuilder: widget.postBuilder,
            ),
          ),
        );
        // ignore: dead_code
        postVideoController?.player.play();
      },
      footer: _defFooterWidget(post),
      header: _defPostHeader(post),
      content: _defContentWidget(post),
      media: _defPostMedia(post, postVideoController),
      topicWidget: _defTopicWidget(post),
    );
  }

  LMFeedPostTopic _defTopicWidget(LMPostViewData post) {
    return LMFeedPostTopic(
      topics: _feedBloc.topics,
      post: post,
      style: feedThemeData?.topicStyle,
    );
  }

  LMFeedPostContent _defContentWidget(LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String? userId) {},
      style: feedThemeData?.contentStyle,
    );
  }

  LMFeedPostFooter _defFooterWidget(LMPostViewData post) {
    return LMFeedPostFooter(
      likeButton: defLikeButton(post),
      commentButton: defCommentButton(post),
      saveButton: defSaveButton(post),
      shareButton: defShareButton(post),
      postFooterStyle: feedThemeData?.footerStyle,
    );
  }

  LMFeedPostHeader _defPostHeader(LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: _feedBloc.users[postViewData.userId]!,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: feedThemeData?.headerStyle,
      menuBuilder: (menu) {
        return menu.copyWith(
          removeItemIds: {postReportId, postEditId},
          action: LMFeedMenuAction(
            onPostUnpin: () => handlePostPinAction(postViewData),
            onPostPin: () => handlePostPinAction(postViewData),
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
    );
  }

  LMFeedPostMedia _defPostMedia(
      LMPostViewData post, VideoController? videoController) {
    return LMFeedPostMedia(
      attachments: post.attachments!,
      style: feedThemeData?.mediaStyle,
      initialiseVideoController: (controller) {
        videoController = controller;
      },
      onMediaTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: _feedBloc.users[post.userId]!,
            ),
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

  LMFeedButton defCommentButton(LMPostViewData postViewData) => LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(
              postViewData.commentCount),
        ),
        style: feedThemeData?.footerStyle.commentButtonStyle,
        onTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: postViewData.id,
                openKeyboard: true,
                postBuilder: widget.postBuilder,
              ),
            ),
          );
        },
        onTextTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: postViewData.id,
                openKeyboard: true,
                postBuilder: widget.postBuilder,
              ),
            ),
          );
        },
      );

  LMFeedButton defSaveButton(LMPostViewData postViewData) => LMFeedButton(
        onTap: () async {
          postViewData.isSaved = !postViewData.isSaved;
          rebuildPostWidget.value = !rebuildPostWidget.value;
          LMFeedPostBloc.instance
              .add(LMFeedUpdatePostEvent(post: postViewData));

          final savePostRequest =
              (SavePostRequestBuilder()..postId(postViewData.id)).build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            postViewData.isSaved = !postViewData.isSaved;
            rebuildPostWidget.value = !rebuildPostWidget.value;
            LMFeedPostBloc.instance
                .add(LMFeedUpdatePostEvent(post: postViewData));
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

  Widget noPostUnderTopicWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LMFeedText(
              text: "Looks like there are no posts for this topic yet.",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  height: 0,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                LMFeedButton(
                  style: LMFeedButtonStyle(
                    borderRadius: 48,
                    border: Border.all(
                      color: feedThemeData?.primaryColor ??
                          LikeMindsTheme.onContainer,
                      width: 2,
                    ),
                    height: 40,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  text: LMFeedText(
                    text: "Change Filter",
                    style: LMFeedTextStyle(
                      textAlign: TextAlign.center,
                      textStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: feedThemeData?.primaryColor),
                    ),
                  ),
                  onTap: () => openTopicSelector(),
                ),
              ],
            ),
          ],
        ),
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
            const LMFeedText(
              text: 'No posts to show',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            const LMFeedText(
              text: "Be the first one to post here",
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
                backgroundColor: feedThemeData?.primaryColor,
                height: 44,
                width: 153,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                placement: LMFeedIconButtonPlacement.end,
              ),
              text: const LMFeedText(
                text: "Create Post",
                style: LMFeedTextStyle(
                  textStyle: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: right
                  ? () {
                      if (!postUploading.value) {
                        LMFeedAnalyticsBloc.instance.add(
                            const LMFeedFireAnalyticsEvent(
                                eventName:
                                    LMFeedAnalyticsKeys.postCreationStarted,
                                eventProperties: {}));
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LMFeedComposeScreen(),
                          ),
                        );
                      } else {
                        toast(
                          'A post is already uploading.',
                          duration: Toast.LENGTH_LONG,
                        );
                      }
                    }
                  : () => toast("You do not have permission to create a post"),
            ),
          ],
        ),
      );

  Widget defFloatingActionButton() => ValueListenableBuilder(
        valueListenable: rebuildPostWidget,
        builder: (context, _, __) {
          return LMFeedButton(
            style: LMFeedButtonStyle(
              icon: LMFeedIcon(
                type: LMFeedIconType.icon,
                icon: Icons.add,
                style: LMFeedIconStyle(
                  fit: BoxFit.cover,
                  size: 18,
                  color: feedThemeData?.onPrimary,
                ),
              ),
              height: 44,
              width: 153,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              borderRadius: 28,
              backgroundColor: right
                  ? feedThemeData?.primaryColor
                  : feedThemeData?.disabledColor,
              placement: LMFeedIconButtonPlacement.end,
              margin: 5.0,
            ),
            text: LMFeedText(
              text: "Create Post",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  color: feedThemeData?.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            onTap: right
                ? () {
                    if (!postUploading.value) {
                      LMFeedAnalyticsBloc.instance.add(
                          const LMFeedFireAnalyticsEvent(
                              eventName:
                                  LMFeedAnalyticsKeys.postCreationStarted,
                              eventProperties: {}));
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LMFeedComposeScreen(),
                        ),
                      );
                    } else {
                      toast(
                        'A post is already uploading.',
                        duration: Toast.LENGTH_LONG,
                      );
                    }
                  }
                : () => toast("You do not have permission to create a post"),
          );
        },
      );

  void handlePostPinAction(LMPostViewData postViewData) async {
    postViewData.isPinned = !postViewData.isPinned;
    rebuildPostWidget.value = !rebuildPostWidget.value;

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(post: postViewData));

    if (!response.success) {
      postViewData.isPinned = !postViewData.isPinned;
      rebuildPostWidget.value = !rebuildPostWidget.value;
      LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(post: postViewData));
    }
  }
}
