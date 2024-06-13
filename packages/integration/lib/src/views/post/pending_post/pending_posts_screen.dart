import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';
import 'package:likeminds_feed_flutter_core/src/utils/web/feed_web_configuration.dart';

part './pending_post_screen_builder_delegate.dart';

class LMFeedPendingPostsScreen extends StatefulWidget {
  // Builder for appbar
  final LMFeedPostAppBarBuilder? appBar;
  // Builder for post item
  /// {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;
  // Floating action button
  // i.e. new post button
  final LMFeedContextButtonBuilder? floatingActionButtonBuilder;
  // Builder for empty feed view
  /// {@macro context_widget_builder}
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

  const LMFeedPendingPostsScreen({
    super.key,
    this.appBar,
    this.postBuilder,
    this.floatingActionButtonBuilder,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
  });

  @override
  State<LMFeedPendingPostsScreen> createState() =>
      _LMFeedPendingPostsScreenState();
}

class _LMFeedPendingPostsScreenState extends State<LMFeedPendingPostsScreen> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  String postTitleFirstCapPlural = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String postTitleSmallCapPlural =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallPlural);

  LMFeedPendingPostScreenBuilderDeletegate _postScreenBuilderDeletegate =
      LMFeedCore.feedBuilderDelegate.pendingPostScreenBuilderDelegate;

  LMFeedPendingBloc pendingBloc = LMFeedPendingBloc.instance;
  LMFeedPostBloc newPostBloc = LMFeedPostBloc.instance;
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);

  bool iSiOS = LMFeedPlatform.instance.isIOS();
  bool isWeb = LMFeedPlatform.instance.isWeb();

  late Size screenSize;
  double? screenWidth;

  int pageSize = 10;

  // Define the initial values for the app bar title and subtitle
  String _appBarTitle = '';
  String _appBarSubtitle = '';

  LMFeedWidgetUtility _widgetsBuilder = LMFeedCore.widgetUtility;

  LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.pendingPostsScreen;

  /// Retrieves the final [LMFeedThemeData] from the [LMFeedCore] theme.
  ///
  /// This step assigns the [LMFeedCore.theme] to the [feedThemeData] variable,
  /// which represents the final theme data for the LMFeed.
  final LMFeedThemeData feedThemeData = LMFeedCore.theme;

  bool isCm = LMFeedUserUtils
      .checkIfCurrentUserIsCM(); // whether the logged in user is a community manager or not

  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();
  // used to rebuild the appbar
  final ValueNotifier _rebuildAppBar = ValueNotifier(false);

  PagingController<int, LMPostViewData> pagingController =
      PagingController<int, LMPostViewData>(
    firstPageKey: 1,
  );

  int pendingPostCount = 0;

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
    pendingBloc = LMFeedPendingBloc.instance;
    super.initState();
    addPageRequestListener();
  }

  void addPageRequestListener() {
    pagingController.addPageRequestListener((pageKey) {
      // Fetch the next page of data
      pendingBloc.add(LMFeedGetPendingPostsEvent(
        page: pageKey,
        pageSize: pageSize,
        uuid: currentUser!.sdkClientInfo.uuid,
      ));
    });
  }

  @override
  void dispose() {
    pagingController.dispose();
    super.dispose();
  }

  void refreshPage() {
    pagingController.itemList?.clear();
    pagingController.refresh();
  }

  void updateAppBarTitle() {
    _appBarTitle =
        '${pendingPostCount == 1 ? postTitleFirstCap : postTitleFirstCapPlural} Under Review';
    _appBarSubtitle =
        '${pendingPostCount} ${pendingPostCount == 1 ? postTitleSmallCap : postTitleSmallCapPlural}';
    _rebuildAppBar.value = !_rebuildAppBar.value;
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = min(LMFeedCore.webConfiguration.maxWidth, screenSize.width);
    return _widgetsBuilder.scaffold(
      appBar: _postScreenBuilderDeletegate.appBarBuilder(
          context, defAppBar(), pendingPostCount),
      backgroundColor: feedThemeData.backgroundColor,
      body: Align(
        alignment: Alignment.topCenter,
        child: Container(
          width: screenWidth,
          child: MultiBlocListener(
            listeners: [
              BlocListener<LMFeedPostBloc, LMFeedPostState>(
                bloc: newPostBloc,
                listener: (context, state) {
                  if (state is LMFeedEditPostUploadedState) {
                    // Clear the post list and refresh the page
                    pagingController.itemList?.clear();
                    pagingController.refresh();
                  } else if (state is LMFeedPostDeletedState) {
                    // Fetch the post id of the deleted post
                    String postId = state.pendingPostId ?? state.postId ?? '';

                    List<LMPostViewData> postList =
                        pagingController.itemList ?? [];
                    // Remove the deleted post from the list
                    postList.removeWhere((element) => element.id == postId);
                    // Update pending post count
                    pendingPostCount--;
                    // Update app bar title according to the newly update
                    // pending post count
                    updateAppBarTitle();
                    // rebuild the post list to update the UI
                    rebuildPostWidget.value = !rebuildPostWidget.value;
                  }
                },
              ),
              BlocListener<LMFeedPendingBloc, LMFeedPendingState>(
                bloc: pendingBloc,
                listener: (context, state) {
                  if (state is LMFeedPendingPostsLoadedState) {
                    if (state.page == 1) {
                      pendingPostCount = state.totalCount;
                      updateAppBarTitle();
                    }
                    if (state.posts.isEmpty || state.posts.length < pageSize)
                      pagingController.appendLastPage(state.posts);
                    else {
                      pagingController.appendPage(state.posts, state.page + 1);
                    }
                  } else if (state is LMFeedPendingPostsErrorState) {
                    pagingController.error = state.errorMessage;
                  }
                },
              ),
            ],
            child: RefreshIndicator.adaptive(
              color: feedThemeData.primaryColor,
              onRefresh: () async {
                refreshPage();
              },
              child: ValueListenableBuilder(
                  valueListenable: rebuildPostWidget,
                  builder: (context, _, __) {
                    return PagedListView(
                      pagingController: pagingController,
                      padding: isDesktopWeb
                          ? EdgeInsets.only(top: 20.0)
                          : EdgeInsets.zero,
                      builderDelegate:
                          PagedChildBuilderDelegate<LMPostViewData>(
                        itemBuilder: (context, item, index) {
                          LMFeedPostWidget postWidget =
                              defPostWidget(context, item);
                          return widget.postBuilder
                                  ?.call(context, postWidget, item) ??
                              _widgetsBuilder.postWidgetBuilder.call(
                                  context, postWidget, item,
                                  source: _widgetSource);
                        },
                        noItemsFoundIndicatorBuilder: (context) {
                          return _widgetsBuilder
                              .noItemsFoundIndicatorBuilderFeed(context);
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
                            widget.newPageErrorIndicatorBuilder
                                ?.call(context) ??
                            _widgetsBuilder
                                .newPageErrorIndicatorBuilderFeed(context),
                      ),
                    );
                  }),
            ),
          ),
        ),
      ),
    );
  }

  LMFeedPostWidget defPostWidget(BuildContext context, LMPostViewData post) {
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
      style: feedThemeData.postStyle,
      onMediaTap: (int index) async {
        LMFeedVideoProvider.instance.pauseCurrentVideo();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments: post.attachments ?? [],
              post: post,
              user: post.user,
              position: index,
            ),
          ),
        )..then((value) => LMFeedVideoProvider.instance.playCurrentVideo());
        // await postVideoController.player.play();
        LMFeedVideoProvider.instance.playCurrentVideo();
      },
      footer: LMFeedPostFooter(hide: true),
      header: _defPostHeader(context, post),
      content: _defContentWidget(post),
      media: _defPostMedia(context, post),
      topicWidget: _defTopicWidget(post),
      reviewBanner: _defPostReviewBanner(post),
    );
  }

  LMFeedPostTopic _defTopicWidget(LMPostViewData postViewData) {
    return LMFeedPostTopic(
      topics: postViewData.topics,
      post: postViewData,
      style: feedThemeData.topicStyle,
      onTopicTap: (context, topicViewData) =>
          LMFeedPostUtils.handlePostTopicTap(
              context, postViewData, topicViewData, _widgetSource),
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

  LMFeedPostHeader _defPostHeader(
      BuildContext context, LMPostViewData postViewData) {
    return LMFeedPostHeader(
      user: postViewData.user,
      isFeed: true,
      postViewData: postViewData,
      postHeaderStyle: feedThemeData.headerStyle,
      createdAt: LMFeedText(
        text: LMFeedTimeAgo.instance.format(postViewData.createdAt),
      ),
      onProfileNameTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, _widgetSource),
      onProfilePictureTap: () => LMFeedPostUtils.handlePostProfileTap(context,
          postViewData, LMFeedAnalyticsKeys.postProfilePicture, _widgetSource),
      menu: LMFeedMenu(
        menuItems: postViewData.menuItems,
        removeItemIds: {},
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
          onPendingPostEdit: () {
            // Mute all video controllers
            // to prevent video from playing in background
            // while editing the post
            LMFeedVideoProvider.instance.forcePauseAllControllers();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LMFeedEditPostScreen(
                  pendingPostId: postViewData.id,
                ),
              ),
            );
          },
          onPendingPostDelete: () {
            String postCreatorUUID = postViewData.user.sdkClientInfo.uuid;

            showDialog(
              context: context,
              builder: (childContext) => LMFeedDeleteConfirmationDialog(
                title: 'Delete $postTitleFirstCap',
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
                      pendingPostId: postViewData.id,
                      reason: reason,
                      isRepost: postViewData.isRepost,
                      postType: postType,
                      userId: postCreatorUUID,
                      userState: isCm ? "CM" : "member",
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

  LMFeedPostReviewBanner _defPostReviewBanner(LMPostViewData postViewData) {
    LMPostReviewStatus postReviewStatus = postViewData.postStatus;
    LMFeedPostReviewBannerStyle postReviewStatusStyle =
        feedThemeData.reviewBannerStyle;
    return LMFeedPostReviewBanner(
      postReviewStatus: postViewData.postStatus,
      reviewStatusIcon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: postReviewStatus == LMPostReviewStatus.pending
            ? lmWarningPendingPostSvg
            : lmRejectPendingPostSvg,
        style: postReviewStatusStyle.reviewStatusIconStyle,
      ),
      infoIcon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: lmInfoPendingPostSvg,
        style: postReviewStatusStyle.infoIconStyle,
      ),
      reviewStatusText: LMFeedText(
        text: postReviewStatus == LMPostReviewStatus.pending
            ? "Under review"
            : "$postTitleFirstCap rejected",
        style: postReviewStatusStyle.reviewStatusTextStyle,
      ),
      style: postReviewStatusStyle,
      onInfoIconClicked: () {
        print("object");
        showPostReviewDialog(postViewData);
      },
    );
  }

  void showPostReviewDialog(LMPostViewData postViewData) {
    LMFeedPendingPostDialog pendingPostDialog =
        _defPendingPostDialog(postViewData);

    if (postViewData.postStatus == LMPostReviewStatus.rejected) {
      _postScreenBuilderDeletegate.showPostRejectionDialog(
          context, postViewData, pendingPostDialog);
    } else if (postViewData.postStatus == LMPostReviewStatus.pending) {
      _postScreenBuilderDeletegate.showPostApprovalDialog(
          context, postViewData, pendingPostDialog);
    }
  }

  LMFeedPendingPostDialog _defPendingPostDialog(LMPostViewData postViewData) {
    LMFeedDialogStyle dialogStyle = feedThemeData.dialogStyle.copyWith(
        insetPadding: EdgeInsets.symmetric(
          horizontal: 40.0,
          vertical: 80.0,
        ),
        padding: EdgeInsets.all(24.0));

    return LMFeedPendingPostDialog(
      dialogStyle: dialogStyle,
      headingTextStyles: LMFeedTextStyle.basic().copyWith(
        maxLines: 2,
        textStyle: TextStyle(
          fontSize: 16,
          color: feedThemeData.onContainer,
          fontWeight: FontWeight.w500,
          height: 1.25,
        ),
      ),
      dialogMessageTextStyles: LMFeedTextStyle.basic().copyWith(
        overflow: TextOverflow.visible,
        maxLines: 10,
        textStyle: TextStyle(
          fontSize: 16,
          color: feedThemeData.textSecondary,
          fontWeight: FontWeight.w400,
          height: 1.25,
        ),
      ),
      onEditButtonClicked: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => LMFeedEditPostScreen(
              pendingPostId: postViewData.id,
            ),
          ),
        );
      },
      onCancelButtonClicked: () {
        Navigator.of(context).pop();
      },
      pendingPostId: postViewData.id,
      title: postViewData.postStatus == LMPostReviewStatus.rejected
          ? "$postTitleFirstCap rejected"
          : "$postTitleFirstCap submitted for approval",
      description: postViewData.postStatus == LMPostReviewStatus.rejected
          ? "This $postTitleSmallCap was rejected by the admin. Edit $postTitleSmallCap to submit again."
          : "Your $postTitleSmallCap has been submitted for approval. Once approved, you will get a notification and it will be visible to others.",
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
      imageBuilder: _widgetsBuilder.imageBuilder,
      videoBuilder: _widgetsBuilder.videoBuilder,
      pollBuilder: _widgetsBuilder.pollWidgetBuilder,
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
      style: feedThemeData.mediaStyle.pollStyle ??
          LMFeedPollStyle.basic(
              primaryColor: feedThemeData.primaryColor,
              containerColor: feedThemeData.container),
      showSubmitButton: false,
      showEditVoteButton: false,
      showAddOptionButton: false,
      showTick: (option) {
        return false;
      },
      isMultiChoicePoll: false,
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
    );
  }

  AppBar defAppBar() {
    return AppBar(
      backgroundColor: feedThemeData.container,
      elevation: 4,
      shadowColor: feedThemeData.shadowColor,
      centerTitle: iSiOS,
      leading: InkWell(
        onTap: () => Navigator.of(context).pop(),
        child: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: iSiOS ? Icons.chevron_left : Icons.arrow_back,
          style: LMFeedIconStyle(
            size: 24,
            color: feedThemeData.onContainer,
          ),
        ),
      ),
      title: ValueListenableBuilder(
          valueListenable: _rebuildAppBar,
          builder: (context, _, __) {
            return Column(
              crossAxisAlignment:
                  iSiOS ? CrossAxisAlignment.center : CrossAxisAlignment.start,
              children: [
                LMFeedText(
                  text: _appBarTitle,
                  style: LMFeedTextStyle(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: TextStyle(
                      color: feedThemeData.onContainer,
                      fontSize: 20,
                    ),
                  ),
                ),
                LMFeedText(
                  text: _appBarSubtitle,
                  style: LMFeedTextStyle(
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textStyle: TextStyle(
                      color: feedThemeData.primaryColor,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            );
          }),
    );
  }
}
