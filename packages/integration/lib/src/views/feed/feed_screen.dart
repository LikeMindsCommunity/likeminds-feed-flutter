import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/simple_bloc_observer.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/user/user_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_driver_fl/src/utils/typedefs.dart';
import 'package:likeminds_feed_driver_fl/src/widgets/post_something.dart';
import 'package:likeminds_feed_driver_fl/src/widgets/topic_bottom_sheet.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

class LMFeedScreen extends StatefulWidget {
  const LMFeedScreen({
    super.key,
    this.appBar,
    this.customWidgetBuilder,
    this.topicChipBuilder,
    this.topicWidgetBuilder,
    this.postBuilder,
    this.floatingActionButton,
    this.emptyFeedViewBuilder,
    this.firstPageLoaderBuilder,
    this.paginationLoaderBuilder,
    this.feedErrorViewBuilder,
    this.noNewPageWidgetBuilder,
    this.enablePostCreation = true,
    this.enableTopicFiltering = true,
    this.showCustomWidget = false,
  });

  //Builder for appbar
  final LMFeedAppBar? appBar;
  final bool showCustomWidget;

  //Callback for activity

  //Builder for custom widget on top
  final LMFeedContextWidgetBuilder? customWidgetBuilder;
  //Builder for topic chip [Button]
  final Widget Function(BuildContext context, List<LMTopicViewData>? topic)?
      topicChipBuilder;

  final Widget Function(BuildContext context)? topicWidgetBuilder;

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

  final bool enablePostCreation;
  final bool enableTopicFiltering;

  @override
  State<LMFeedScreen> createState() => _LMFeedScreenState();
}

class _LMFeedScreenState extends State<LMFeedScreen> {
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

  // list of selected topics by the user
  List<LMTopicViewData> selectedTopics = [];
  bool topicVisible = true;

  // list of all the topics
  Map<String, LMTopicViewData> topics = {};
  // list of all the users
  Map<String, LMUserViewData> users = {};
  // list of all the widgets
  Map<String, LMWidgetViewData> widgets = {};

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

  final ValueNotifier postSomethingNotifier = ValueNotifier(false);
  bool userPostingRights = true;
  var iconContainerHeight = 60.00;

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
    _feedBloc = LMFeedBloc();
    _feedBloc
        .add(LMFeedGetUniversalFeedEvent(offset: 1, topics: selectedTopics));
    _controller.addListener(_scrollListener);
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

  void _scrollListener() {
    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      if (iconContainerHeight != 0) {
        iconContainerHeight = 0;
        topicVisible = false;
        rebuildTopicFeed.value = !rebuildTopicFeed.value;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
    if (_controller.position.userScrollDirection == ScrollDirection.forward) {
      if (iconContainerHeight == 0) {
        iconContainerHeight = 60.0;
        topicVisible = true;
        rebuildTopicFeed.value = !rebuildTopicFeed.value;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
  }

  void updateSelectedTopics(List<LMTopicViewData> topics) {
    selectedTopics = topics;
    rebuildTopicFeed.value = !rebuildTopicFeed.value;
    clearPagingController();
    _feedBloc.add(
      LMFeedGetUniversalFeedEvent(
        offset: 1,
        topics: selectedTopics,
      ),
    );
  }

  @override
  void dispose() {
    _pagingController.dispose();
    _rebuildAppBar.dispose();
    _feedBloc.close();
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
            topics: selectedTopics,
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

      users.addAll(state.users);
      topics.addAll(state.topics);
      widgets.addAll(state.widgets);

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
      backgroundColor: LMThemeData.kWhiteColor,
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
        selectedTopics: selectedTopics,
        onTopicSelected: (updatedTopics, tappedTopic) {
          updateSelectedTopics(updatedTopics);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = LMThemeData.theme;
    return Scaffold(
      backgroundColor: LMThemeData.kWhiteColor,
      appBar: widget.appBar ??
          AppBar(
            backgroundColor: LMThemeData.kWhiteColor,
            centerTitle: false,
            title: GestureDetector(
              onTap: () {
                _scrollToTop();
              },
              child: const Padding(
                padding: EdgeInsets.only(left: 4.0),
                child: LMFeedText(
                  text: "Feed",
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      color: Colors.black,
                      fontSize: 27,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
            elevation: 1,
          ),
      body: RefreshIndicator(
        onRefresh: () async {
          refresh();
          clearPagingController();
        },
        child: Column(
          children: [
            LMThemeData.kVerticalPaddingLarge,
            widget.showCustomWidget
                ? ValueListenableBuilder(
                    valueListenable: postSomethingNotifier,
                    builder: (context, _, __) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        height: iconContainerHeight,
                        clipBehavior: Clip.hardEdge,
                        decoration: const BoxDecoration(),
                        child: widget.customWidgetBuilder == null
                            ? LMFeedPostSomething(
                                enabled: userPostingRights,
                              )
                            : widget.customWidgetBuilder!(context),
                      );
                    },
                  )
                : const SizedBox(),
            ValueListenableBuilder(
              valueListenable: rebuildTopicFeed,
              builder: (context, _, __) {
                return Visibility(
                  visible: topicVisible,
                  maintainAnimation: true,
                  maintainState: true,
                  child: FutureBuilder<GetTopicsResponse>(
                      future: getTopicsResponse,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const SizedBox.shrink();
                        } else if (snapshot.hasData &&
                            snapshot.data != null &&
                            snapshot.data!.success == true) {
                          if (snapshot.data!.topics!.isNotEmpty) {
                            return Container(
                              height: 54,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 12.0),
                              child: GestureDetector(
                                onTap: () => showTopicSelectSheet(),
                                child: Row(
                                  children: [
                                    selectedTopics.isEmpty
                                        ? LMFeedTopicChip(
                                            topic: (LMTopicViewDataBuilder()
                                                  ..id("0")
                                                  ..isEnabled(true)
                                                  ..name("Topic"))
                                                .build(),
                                            borderRadius: 20.0,
                                            borderWidth: 1,
                                            showBorder: true,
                                            borderColor:
                                                LMThemeData.appSecondaryBlack,
                                            textStyle: const TextStyle(
                                              color: LMThemeData.appBlack,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12.0,
                                                vertical: 4.0),
                                            icon: const LMFeedIcon(
                                              type: LMFeedIconType.icon,
                                              icon: CupertinoIcons.chevron_down,
                                              style: LMFeedIconStyle(
                                                size: 16,
                                                color: LMThemeData.appBlack,
                                              ),
                                            ),
                                          )
                                        : selectedTopics.length == 1
                                            ? LMFeedTopicChip(
                                                topic: (LMTopicViewDataBuilder()
                                                      ..id(selectedTopics
                                                          .first.id)
                                                      ..isEnabled(selectedTopics
                                                          .first.isEnabled)
                                                      ..name(selectedTopics
                                                          .first.name))
                                                    .build(),
                                                borderRadius: 20.0,
                                                backgroundColor:
                                                    theme.colorScheme.secondary,
                                                textStyle: const TextStyle(
                                                  color:
                                                      LMThemeData.kWhiteColor,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 4.0),
                                                icon: const LMFeedIcon(
                                                  type: LMFeedIconType.icon,
                                                  icon: CupertinoIcons
                                                      .chevron_down,
                                                  style: LMFeedIconStyle(
                                                    size: 16,
                                                    color:
                                                        LMThemeData.kWhiteColor,
                                                  ),
                                                ),
                                              )
                                            : LMFeedTopicChip(
                                                topic: (LMTopicViewDataBuilder()
                                                      ..id("0")
                                                      ..isEnabled(true)
                                                      ..name("Topics"))
                                                    .build(),
                                                borderRadius: 20.0,
                                                backgroundColor:
                                                    theme.colorScheme.secondary,
                                                textStyle: const TextStyle(
                                                  color:
                                                      LMThemeData.kWhiteColor,
                                                ),
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12.0,
                                                        vertical: 4.0),
                                                icon: Row(
                                                  children: [
                                                    LMThemeData
                                                        .kHorizontalPaddingXSmall,
                                                    Container(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 4),
                                                      decoration:
                                                          ShapeDecoration(
                                                        color: Colors.white,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            4)),
                                                      ),
                                                      child: LMFeedText(
                                                        text: selectedTopics
                                                            .length
                                                            .toString(),
                                                        style:
                                                            const LMFeedTextStyle(
                                                          textStyle: TextStyle(
                                                            color: Color(
                                                                0xFF4666F6),
                                                            fontSize: 12,
                                                            fontFamily: 'Inter',
                                                            fontWeight:
                                                                FontWeight.w500,
                                                            height: 1.30,
                                                            letterSpacing:
                                                                -0.48,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    LMThemeData
                                                        .kHorizontalPaddingSmall,
                                                    const LMFeedIcon(
                                                      type: LMFeedIconType.icon,
                                                      icon: CupertinoIcons
                                                          .chevron_down,
                                                      style: LMFeedIconStyle(
                                                        size: 16,
                                                        color: LMThemeData
                                                            .kWhiteColor,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                  ],
                                ),
                              ),
                            );
                          } else {
                            return const SizedBox.shrink();
                          }
                        }
                        return const SizedBox();
                      }),
                );
              },
            ),
            Expanded(
              child: BlocListener(
                bloc: _feedBloc,
                listener: (context, state) => updatePagingControllers(state),
                child: FeedRoomView(
                  isCm: isCm,
                  universalFeedBloc: _feedBloc,
                  feedRoomPagingController: _pagingController,
                  user: user,
                  topics: topics,
                  users: users,
                  widgets: widgets,
                  onRefresh: refresh,
                  scrollController: _controller,
                  openTopicBottomSheet: showTopicSelectSheet,
                  postBuilder: widget.postBuilder,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FeedRoomView extends StatefulWidget {
  final bool isCm;
  final LMUserViewData user;
  final LMFeedBloc universalFeedBloc;
  final Map<String, LMUserViewData> users;
  final Map<String, LMWidgetViewData> widgets;
  final Map<String, LMTopicViewData> topics;
  final PagingController<int, LMPostViewData> feedRoomPagingController;
  final ScrollController scrollController;
  final VoidCallback onRefresh;
  final VoidCallback openTopicBottomSheet;
  final LMFeedPostWidgetBuilder? postBuilder;

  const FeedRoomView({
    super.key,
    required this.isCm,
    required this.universalFeedBloc,
    required this.feedRoomPagingController,
    required this.user,
    required this.onRefresh,
    required this.scrollController,
    required this.openTopicBottomSheet,
    required this.users,
    required this.widgets,
    required this.topics,
    this.postBuilder,
  });

  @override
  State<FeedRoomView> createState() => _FeedRoomViewState();
}

class _FeedRoomViewState extends State<FeedRoomView> {
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  final ValueNotifier postUploading = ValueNotifier(false);
  ScrollController? _controller;
  final ValueNotifier postSomethingNotifier = ValueNotifier(false);
  bool right = true;

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
            boxFit: BoxFit.contain,
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

  bool checkPostCreationRights() {
    final MemberStateResponse memberStateResponse =
        LMFeedUserLocalPreference.instance.fetchMemberRights();
    if (!memberStateResponse.success || memberStateResponse.state == 1) {
      return true;
    }
    final memberRights = LMFeedUserLocalPreference.instance.fetchMemberRight(9);
    return memberRights;
  }

  var iconContainerHeight = 90.00;

  @override
  void initState() {
    super.initState();
    LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.feedOpened,
        eventProperties: {'feed_type': "universal_feed"}));
    _controller = widget.scrollController..addListener(_scrollListener);
    right = checkPostCreationRights();
  }

  void _scrollListener() {
    if (_controller != null &&
        _controller!.position.userScrollDirection == ScrollDirection.reverse) {
      if (iconContainerHeight != 0) {
        iconContainerHeight = 0;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
    if (_controller != null &&
        _controller!.position.userScrollDirection == ScrollDirection.forward) {
      if (iconContainerHeight == 0) {
        iconContainerHeight = 90.0;
        postSomethingNotifier.value = !postSomethingNotifier.value;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
    final ThemeData theme = LMThemeData.theme;
    return Scaffold(
      backgroundColor: LMThemeData.theme.colorScheme.background,
      body: Column(
        children: [
          BlocConsumer<LMFeedPostBloc, LMFeedPostState>(
            bloc: newPostBloc,
            listener: (prev, curr) {
              if (curr is LMFeedPostDeletedState) {
                List<LMPostViewData>? feedRoomItemList =
                    widget.feedRoomPagingController.itemList;
                feedRoomItemList?.removeWhere((item) => item.id == curr.postId);
                widget.feedRoomPagingController.itemList = feedRoomItemList;
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
                int length =
                    widget.feedRoomPagingController.itemList?.length ?? 0;
                List<LMPostViewData> feedRoomItemList =
                    widget.feedRoomPagingController.itemList ?? [];
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
                widget.users.addAll(curr.userData);
                widget.topics.addAll(curr.topics);
                widget.feedRoomPagingController.itemList = feedRoomItemList;
                postUploading.value = false;
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
              if (curr is LMFeedEditPostUploadedState) {
                LMPostViewData? item = curr.postData;
                List<LMPostViewData>? feedRoomItemList =
                    widget.feedRoomPagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == item.id) ??
                    -1;
                if (index != -1) {
                  feedRoomItemList?[index] = item;
                }
                widget.users.addAll(curr.userData);
                widget.topics.addAll(curr.topics);
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
                    widget.feedRoomPagingController.itemList;
                int index = feedRoomItemList
                        ?.indexWhere((element) => element.id == curr.post.id) ??
                    -1;
                if (index != -1) {
                  feedRoomItemList?[index] = curr.post;
                }
                rebuildPostWidget.value = !rebuildPostWidget.value;
              }
            },
            builder: (context, state) {
              if (state is LMFeedEditPostUploadingState) {
                return Container(
                  height: 60,
                  color: LMThemeData.theme.colorScheme.background,
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
                          LMThemeData.kHorizontalPaddingMedium,
                          Text('Saving')
                        ],
                      ),
                      CircularProgressIndicator(
                        backgroundColor: LMThemeData.kGrey3Color,
                        valueColor:
                            AlwaysStoppedAnimation(LMThemeData.kPrimaryColor),
                        strokeWidth: 3,
                      ),
                    ],
                  ),
                );
              }
              if (state is LMFeedNewPostUploadingState) {
                return Container(
                  height: 60,
                  color: LMThemeData.kWhiteColor,
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          getLoaderThumbnail(state.thumbnailMedia),
                          LMThemeData.kHorizontalPaddingMedium,
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
                                  backgroundColor: LMThemeData.kGrey3Color,
                                  valueColor: const AlwaysStoppedAnimation(
                                      LMThemeData.kPrimaryColor),
                                  strokeWidth: 3,
                                ));
                          }),
                    ],
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            },
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: rebuildPostWidget,
                    builder: (context, _, __) {
                      return PagedListView<int, LMPostViewData>(
                        pagingController: widget.feedRoomPagingController,
                        scrollController: _controller,
                        padding: EdgeInsets.zero,
                        builderDelegate:
                            PagedChildBuilderDelegate<LMPostViewData>(
                          noItemsFoundIndicatorBuilder: (context) {
                            if (widget.universalFeedBloc.state
                                    is LMFeedUniversalFeedLoadedState &&
                                (widget.universalFeedBloc.state
                                        as LMFeedUniversalFeedLoadedState)
                                    .topics
                                    .isNotEmpty) {
                              return Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const LMFeedText(
                                      text:
                                          "Looks like there are no posts for this topic yet.",
                                      style: LMFeedTextStyle(
                                        textStyle: TextStyle(
                                          fontSize: 15,
                                          color: LMThemeData.onSurface500,
                                          fontWeight: FontWeight.w600,
                                          height: 0,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        LMFeedButton(
                                          style: LMFeedButtonStyle(
                                            borderRadius: 48,
                                            border: Border.all(
                                              color: LMThemeData.primary500,
                                              width: 2,
                                            ),
                                            height: 40,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                          ),
                                          text: const LMFeedText(
                                            text: "Change Filter",
                                            style: LMFeedTextStyle(
                                              textAlign: TextAlign.center,
                                              textStyle: TextStyle(
                                                color: LMThemeData.primary500,
                                                fontSize: 15,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                          onTap: () =>
                                              widget.openTopicBottomSheet(),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            }
                            return Center(
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
                                          color: LMThemeData.kGrey2Color),
                                    ),
                                  ),
                                  const SizedBox(height: 28),
                                  LMFeedButton(
                                    style: LMFeedButtonStyle(
                                      borderRadius: 28,
                                      backgroundColor:
                                          theme.colorScheme.primary,
                                      height: 44,
                                      width: 153,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 20),
                                      placement: LMFeedIconButtonPlacement.end,
                                    ),
                                    text: LMFeedText(
                                      text: "Create Post",
                                      style: LMFeedTextStyle(
                                        textStyle: TextStyle(
                                          color: theme.colorScheme.onPrimary,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    icon: LMFeedIcon(
                                      type: LMFeedIconType.icon,
                                      icon: Icons.add,
                                      style: LMFeedIconStyle(
                                        size: 18,
                                        color: theme.colorScheme.onPrimary,
                                      ),
                                    ),
                                    onTap: right
                                        ? () {
                                            if (!postUploading.value) {
                                              LMFeedAnalyticsBloc.instance.add(
                                                  const LMFeedFireAnalyticsEvent(
                                                      eventName:
                                                          LMFeedAnalyticsKeys
                                                              .postCreationStarted,
                                                      eventProperties: {}));
                                              // TODO: Navigate to NewPostScreen
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         const NewPostScreen(),
                                              //   ),
                                              // );
                                            } else {
                                              toast(
                                                'A post is already uploading.',
                                                duration: Toast.LENGTH_LONG,
                                              );
                                            }
                                          }
                                        : () => toast(
                                            "You do not have permission to create a post"),
                                  ),
                                ],
                              ),
                            );
                          },
                          itemBuilder: (context, item, index) {
                            if (widget.users[item.userId] == null) {
                              return const SizedBox();
                            }
                            return Column(
                              children: [
                                const SizedBox(height: 8),
                                widget.postBuilder?.call(
                                        context, defPostWidget(item), item) ??
                                    defPostWidget(item),
                                const SizedBox(height: 8),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          )
        ],
      ),
      floatingActionButtonAnimator: FloatingActionButtonAnimator.scaling,
      floatingActionButton: ValueListenableBuilder(
        valueListenable: rebuildPostWidget,
        builder: (context, _, __) {
          return LMFeedButton(
            style: LMFeedButtonStyle(
              height: 44,
              width: 153,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              borderRadius: 28,
              backgroundColor:
                  right ? theme.colorScheme.primary : LMThemeData.kGrey3Color,
              placement: LMFeedIconButtonPlacement.end,
              margin: 5,
            ),
            text: LMFeedText(
              text: "Create Post",
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  color: theme.colorScheme.onPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            icon: LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.add,
              style: LMFeedIconStyle(
                fit: BoxFit.cover,
                size: 18,
                color: theme.colorScheme.onPrimary,
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
                      // TODO: Navigate to NewPostScreen
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const NewPostScreen(),
                      //   ),
                      // );
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
      ),
    );
  }

  LMFeedPostWidget defPostWidget(LMPostViewData post) {
    return LMFeedPostWidget(
      post: post,
      topics: widget.topics,
      user: widget.users[post.userId]!,
      isFeed: false,
      onTagTap: (String userId) {},
    );
  }
}
