// ignore_for_file: deprecated_member_use_from_same_package, depend_on_referenced_packages

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/builder/widgets_builder.dart';
import 'package:likeminds_feed_sample/themes/qna/screens/search_screen.dart';
import 'package:likeminds_feed_sample/themes/qna/screens/user_profile_screen.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/theme/theme.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/utils.dart';
import 'package:likeminds_feed_sample/themes/qna/widgets/notification_icon.dart';

/// {@template feed_screen}
/// A screen to display the feed.
/// The feed can be customized by passing in the required parameters
/// Post creation can be enabled or disabled
/// Post Builder can be used to customize the post widget
/// Topic Chip Builder can be used to customize the topic chip widget
///
/// {@endtemplate}
class LMQnAFeedScreen extends StatefulWidget {
  const LMQnAFeedScreen({
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
  });

  // Builder for appbar
  final LMFeedPostAppBarBuilder? appBar;

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

  final LMFeedScreenConfig? config;

  @override
  State<LMQnAFeedScreen> createState() => _LMQnAFeedScreenState();
}

class _LMQnAFeedScreenState extends State<LMQnAFeedScreen> {
  final LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.universalFeed;

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

  final LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;
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
  final LMFeedBloc _feedBloc =
      LMFeedBloc.instance; // bloc to fetch the feedroom data
  bool isCm = LMFeedUserUtils
      .checkIfCurrentUserIsCM(); // whether the logged in user is a community manager or not

  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();

  // future to get the unread notification count
  late Future<GetUnreadNotificationCountResponse> getUnreadNotificationCount;

  // used to rebuild the appbar
  final ValueNotifier<bool> _rebuildAppBar = ValueNotifier(false);

  // to control paging on FeedRoom View
  final PagingController<int, LMPostViewData> _pagingController =
      PagingController(firstPageKey: 1);
  ValueNotifier<bool> showSearchIcon = ValueNotifier(false);

  bool userPostingRights = true;

  LMFeedThemeData feedThemeData = LMFeedCore.theme;

  List<String> selectedTopics = [];

  @override
  void initState() {
    super.initState();
    Bloc.observer = LMFeedBlocObserver();
    userPostingRights = LMFeedUserUtils.checkPostCreationRights();
    _addPaginationListener();
    _controller.addListener(() {
      if (_controller.position.pixels > 50 && !showSearchIcon.value) {
        showSearchIcon.value = true;
      } else if (_controller.position.pixels <= 50 && showSearchIcon.value) {
        showSearchIcon.value = false;
      }
    });
    LMFeedAnalyticsBloc.instance.add(
      const LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.feedOpened,
        eventProperties: {
          'feed_type': 'universal_feed',
        },
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _rebuildAppBar.dispose();
    _controller.dispose();
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
      (pageKey) async {
        if (pageKey == 1) {
          await onBoardFeedForUser();
        }
        _feedBloc.add(
          LMFeedGetUniversalFeedEvent(
            pageKey: pageKey,
            topicsIds: selectedTopics,
          ),
        );
      },
    );
  }

  void refresh() {
    clearPagingController();
    _pagingController.refresh();
    // Rebuilds the notication bell icon on pull to refresh
    _rebuildAppBar.value = !_rebuildAppBar.value;
  }

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(LMFeedState? state) {
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
    LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
    config = widget.config ?? LMFeedCore.config.feedScreenConfig;
    return LMFeedQnAWidgets.instance.scaffold(
      backgroundColor: feedThemeData.backgroundColor,
      appBar: widget.appBar?.call(context, _defAppBar()) ?? _defAppBar(),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: rebuildPostWidget,
        builder: (context, _, __) {
          debugPrint("floating action button builder called");
          return widget.floatingActionButtonBuilder
                  ?.call(context, defFloatingActionButton(context)) ??
              defFloatingActionButton(context);
        },
      ),
      floatingActionButtonLocation: widget.floatingActionButtonLocation,
      body: RefreshIndicator.adaptive(
        onRefresh: () async {
          refresh();
        },
        color: feedThemeData.primaryColor,
        backgroundColor: feedThemeData.container,
        child: CustomScrollView(
          controller: _controller,
          slivers: [
            SliverToBoxAdapter(
                child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const LMQnASearchScreen(),
                  ),
                );
              },
              child: Container(
                color: feedThemeData.container,
                padding: const EdgeInsets.symmetric(
                    vertical: 10.0, horizontal: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(50.0),
                    border: Border.all(color: feedThemeData.disabledColor),
                  ),
                  padding: const EdgeInsets.all(15.0),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: textPrimary),
                      SizedBox(width: 10.0),
                      LMFeedText(
                        text: 'Search anything in this community',
                        style: LMFeedTextStyle(
                          textStyle: TextStyle(
                            color: textTertiary,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )),
            SliverToBoxAdapter(
              child: BlocConsumer<LMFeedPostBloc, LMFeedPostState>(
                bloc: newPostBloc,
                listener: (prev, curr) {
                  if (curr is LMFeedPostDeletedState) {
                    // show a snackbar when post is deleted
                    // will only be shown if a messenger key is provided

                    LMFeedCore.showSnackBar(
                        context, "$postTitleFirstCap Deleted", _widgetSource);
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

                    LMQnAFeedUtils.checkIfTopicFollowInPost(currentUser!.uuid,
                        item.topics, currentUser!.topics ?? []);

                    LMFeedCore.showSnackBar(
                        context, "$postTitleFirstCap Created", _widgetSource);
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

                    LMFeedCore.showSnackBar(
                        context, "$postTitleFirstCap Edited", _widgetSource);
                  }
                  if (curr is LMFeedNewPostErrorState) {
                    postUploading.value = false;
                    LMFeedCore.showSnackBar(
                        context, curr.errorMessage, _widgetSource);
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
                          actionType: curr.actionType,
                          commentId: curr.commentId);
                    }
                    rebuildPostWidget.value = !rebuildPostWidget.value;
                  }
                  if (curr is LMFeedPostDeletionErrorState) {
                    LMFeedCore.showSnackBar(
                        context, curr.message, _widgetSource);
                  }
                },
                builder: (context, state) {
                  if (state is LMFeedEditPostUploadingState) {
                    return Container(
                      height: 60,
                      color: feedThemeData.container,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              const SizedBox(
                                width: 50,
                                height: 50,
                              ),
                              LikeMindsTheme.kHorizontalPaddingMedium,
                              Text('Saving $postTitleFirstCap')
                            ],
                          ),
                          const LMFeedLoader(),
                        ],
                      ),
                    );
                  }
                  if (state is LMFeedNewPostUploadingState) {
                    return Container(
                      height: 60,
                      color: feedThemeData.backgroundColor,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              getLoaderThumbnail(state.thumbnailMedia),
                              LikeMindsTheme.kHorizontalPaddingMedium,
                              Text('Creating $postTitleFirstCap')
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
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ),
            BlocListener<LMFeedBloc, LMFeedState>(
              bloc: _feedBloc,
              listener: (context, LMFeedState state) =>
                  updatePagingControllers(state),
              child: ValueListenableBuilder(
                valueListenable: rebuildPostWidget,
                builder: (context, _, __) {
                  return PagedSliverList<int, LMPostViewData>(
                    pagingController: _pagingController,
                    builderDelegate: PagedChildBuilderDelegate<LMPostViewData>(
                      itemBuilder: (context, item, index) {
                        if (_feedBloc.users[item.uuid] == null) {
                          return const SizedBox();
                        }
                        LMFeedPostWidget postWidget =
                            defPostWidget(context, feedThemeData, item);
                        return widget.postBuilder
                                ?.call(context, postWidget, item) ??
                            LMFeedCore.widgetUtility.postWidgetBuilder
                                .call(context, postWidget, item);
                      },
                      noItemsFoundIndicatorBuilder: (context) {
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
        leading: LMFeedButton(
          onTap: () {
            Navigator.of(context).pop();
          },
          style: const LMFeedButtonStyle(
            icon: LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.arrow_back,
              style: LMFeedIconStyle(
                color: Colors.black,
                size: 24,
                boxPadding: 6,
                boxSize: 36,
              ),
            ),
          ),
        ),
        title: GestureDetector(
          onTap: () {
            _scrollToTop();
          },
          child: const Padding(
            padding: EdgeInsets.only(left: 4.0),
            child: LMFeedText(
              text: "Real Travellers. Real Talk.",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
        style: LMFeedAppBarStyle.basic().copyWith(
          backgroundColor: feedThemeData.container,
          height: 60,
          border: const Border(),
          shadow: [
            const BoxShadow(color: Color.fromARGB(10, 0, 0, 0), blurRadius: 10)
          ],
        ),
        trailing: [
          ValueListenableBuilder(
              valueListenable: showSearchIcon,
              builder: (context, value, _) {
                return AnimatedOpacity(
                  opacity: value ? 1 : 0,
                  duration: const Duration(milliseconds: 400),
                  child: LMFeedButton(
                    onTap: () {
                      if (value) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LMQnASearchScreen(),
                          ),
                        );
                      }
                    },
                    style: const LMFeedButtonStyle.basic().copyWith(
                      padding: const EdgeInsets.only(left: 10),
                      icon: const LMFeedIcon(
                        type: LMFeedIconType.icon,
                        icon: Icons.search,
                      ),
                    ),
                  ),
                );
              }),
          ValueListenableBuilder(
              valueListenable: _rebuildAppBar,
              builder: (context, value, __) {
                return NotificationIcon(
                  key: Key(value.toString()),
                );
              }),
          const SizedBox(width: 10),
          LMFeedProfilePicture(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => LMQnAUserProfileScreen(
                    uuid: currentUser!.sdkClientInfo.uuid,
                  ),
                ),
              );
            },
            imageUrl: currentUser!.imageUrl,
            fallbackText: currentUser!.name,
            style: LMFeedProfilePictureStyle.basic().copyWith(
              size: 40,
              fallbackTextStyle: LMFeedTextStyle.basic().copyWith(
                textStyle: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w600, color: surface),
              ),
            ),
          ),
          const SizedBox(width: 5),
        ]);
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
            const LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.picture_as_pdf,
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

  LMFeedPostWidget defPostWidget(BuildContext context,
      LMFeedThemeData? feedThemeData, LMPostViewData post) {
    return LMFeedPostWidget(
      post: post,
      topics: post.topics,
      user: _feedBloc.users[post.uuid]!,
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
      onMediaTap: (position) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        // ignore: use_build_context_synchronously
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: _feedBloc.users[post.uuid]!,
              position: position,
            ),
          ),
        );
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
      user: _feedBloc.users[postViewData.uuid]!,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: feedThemeData.headerStyle,
      onProfileNameTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfileName, _widgetSource),
      onProfilePictureTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, _widgetSource),
      menu: LMFeedMenu(
        menuItems: postViewData.menuItems,
        removeItemIds: const {postReportId, postEditId},
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
                widgetSource: _widgetSource,
                title: 'Delete $postTitleFirstCap',
                uuid: postCreatorUUID,
                content:
                    'Are you sure you want to delete this $postTitleSmallCap. This action can not be reversed.',
                action: (String reason) async {
                  Navigator.of(childContext).pop();

                  String postType =
                      LMFeedPostUtils.getPostType(postViewData.attachments);

                  LMFeedAnalyticsBloc.instance.add(
                    LMFeedFireAnalyticsEvent(
                      eventName: LMFeedAnalyticsKeys.postDeleted,
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
      pollBuilder: LMFeedCore.widgetUtility.pollWidgetBuilder,
      onMediaTap: (position) {
        LMFeedVideoProvider.instance.pauseCurrentVideo();

        // ignore: use_build_context_synchronously
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: _feedBloc.users[post.uuid]!,
              position: position,
            ),
          ),
        );
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
        },
        onTextTap: () async {
          LMFeedVideoProvider.instance.pauseCurrentVideo();

          // ignore: use_build_context_synchronously
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedPostDetailScreen(
                postId: post.id,
                openKeyboard: true,
                postBuilder: widget.postBuilder,
              ),
            ),
          );
        },
      );

  LMFeedButton defSaveButton(LMPostViewData postViewData) => LMFeedButton(
        isActive: postViewData.isSaved,
        onTap: () async {
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
          } else {
            LMFeedCore.showSnackBar(
                context,
                postViewData.isSaved
                    ? "$postTitleFirstCap Saved"
                    : "$postTitleFirstCap Unsaved",
                _widgetSource);
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
                if (!postUploading.value) {
                  LMFeedAnalyticsBloc.instance.add(
                      const LMFeedFireAnalyticsEvent(
                          eventName: LMFeedAnalyticsKeys.postCreationStarted,
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
                      ),
                    ),
                  );
                } else {
                  LMFeedCore.showSnackBar(
                      context,
                      "A $postTitleFirstCap is already uploading.",
                      _widgetSource);
                }
              }
            : () {
                LMFeedCore.showSnackBar(
                    context,
                    "You do not have permission to create a $postTitleFirstCap",
                    _widgetSource);
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
        onTap: () {},
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
        text: "Create $postTitleFirstCap",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: feedThemeData.onPrimary,
          ),
        ),
      ),
      onTap: right
          ? () async {
              if (!postUploading.value) {
                LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
                    eventName: LMFeedAnalyticsKeys.postCreationStarted,
                    eventProperties: {}));

                LMFeedVideoProvider.instance.forcePauseAllControllers();
                // ignore: use_build_context_synchronously
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LMFeedComposeScreen(),
                  ),
                );
              } else {
                LMFeedCore.showSnackBar(context,
                    "A $postTitleFirstCap is already uploading", _widgetSource);
              }
            }
          : () {
              LMFeedCore.showSnackBar(
                context,
                "You do not have permission to create a $postTitleFirstCap",
                _widgetSource,
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
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
          borderRadius: 28,
          backgroundColor:
              right ? feedThemeData.primaryColor : feedThemeData.disabledColor,
          placement: LMFeedIconButtonPlacement.end,
          margin: 5.0,
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
        onTap: right
            ? () async {
                if (!postUploading.value) {
                  LMFeedAnalyticsBloc.instance.add(
                      const LMFeedFireAnalyticsEvent(
                          eventName: LMFeedAnalyticsKeys.postCreationStarted,
                          eventProperties: {}));

                  LMFeedVideoProvider.instance.forcePauseAllControllers();
                  // ignore: use_build_context_synchronously
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LMFeedComposeScreen(),
                    ),
                  );
                } else {
                  LMFeedCore.showSnackBar(
                    context,
                    "A $postTitleSmallCap is already uploading.",
                    _widgetSource,
                  );
                }
              }
            : () {
                LMFeedCore.showSnackBar(
                  context,
                  "You do not have permission to create a $postTitleSmallCap",
                  _widgetSource,
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
    if (postViewData.isPinned) {
      int index = postViewData.menuItems.indexWhere(
          (element) => element.id == postPinId || element.id == postUnpinId);
      if (index != -1) {
        postViewData.menuItems[index].title = "Unpin This $postTitleFirstCap";
        postViewData.menuItems[index].id = postUnpinId;
      }
    } else {
      int index = postViewData.menuItems.indexWhere(
          (element) => element.id == postUnpinId || element.id == postPinId);

      if (index != -1) {
        postViewData.menuItems[index]
          ..title = "Pin This $postTitleFirstCap"
          ..id = postPinId;
      }
    }

    LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
        postId: postViewData.id,
        actionType: postViewData.isPinned
            ? LMFeedPostActionType.pinned
            : LMFeedPostActionType.unpinned));

    rebuildPostWidget.value = !rebuildPostWidget.value;

    final pinPostRequest =
        (PinPostRequestBuilder()..postId(postViewData.id)).build();

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    if (!response.success) {
      if (postViewData.isPinned) {
        int index = postViewData.menuItems
            .indexWhere((element) => element.id == postPinId);
        if (index != -1) {
          postViewData.menuItems[index]
            ..title = "Unpin This $postTitleFirstCap"
            ..id = postUnpinId;
        }
      } else {
        int index = postViewData.menuItems
            .indexWhere((element) => element.id == postUnpinId);

        if (index != -1) {
          postViewData.menuItems[index]
            ..title = "Pin This $postTitleFirstCap"
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
          eventProperties: {
            'created_by_id': postViewData.uuid,
            'post_id': postViewData.id,
            'post_type': postType,
          },
        ),
      );
    }
  }

  Future<void> onBoardFeedForUser() async {
    LMUserViewData? user = LMFeedLocalPreference.instance.fetchUserData();

    GetUserFeedMetaResponse userFeedMetaResponse =
        await LMQnAFeedUtils.getUserMetaForCurrentUser();

    if (userFeedMetaResponse.success) {
      selectedTopics = userFeedMetaResponse.userTopics?[user?.uuid] ?? [];

      List<LMTopicViewData> userTopics = [];

      for (var element in selectedTopics) {
        LMTopicViewData? topicViewData =
            userFeedMetaResponse.topics?[element] == null
                ? null
                : LMTopicViewDataConvertor.fromTopic(
                    userFeedMetaResponse.topics![element]!);

        if (topicViewData != null) {
          userTopics.add(topicViewData);
        }
      }
      currentUser!.topics = userTopics;
    }

    LMResponse cacheResponse =
        LMFeedCore.client.getCache("maximum_priority_topic");

    if (!cacheResponse.success || cacheResponse.data == null) {
      await LMQnAFeedUtils.getParentTopics();
    }
  }
}
