// ignore_for_file: deprecated_member_use_from_same_package

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/comment_reply_widget.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/default_empty_comment_widget.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/handler/post_detail_screen_handler.dart';
// import 'package:media_kit_video/media_kit_video.dart';

part 'post_detail_screen_configuration.dart';

/// {@template post_detail_screen}
/// A screen that displays a post in detail
/// with comments and likes
/// {@endtemplate}
class LMFeedPostDetailScreen extends StatefulWidget {
  ///{@macro post_detail_screen}
  const LMFeedPostDetailScreen({
    super.key,
    required this.postId,
    this.postBuilder,
    this.appBarBuilder,
    this.commentBuilder,
    this.bottomTextFieldBuilder,
    this.commentSeparatorBuilder,
    this.onPostTap,
    this.onLikeClick,
    this.onCommentClick,
    this.openKeyboard = false,
    this.config,
  });
  // Required variables
  final String postId;

  final Function()? onPostTap;
  final Function()? onLikeClick;
  final Function()? onCommentClick;

  // Optional variables
  // In case the below props are not provided,
  // the default in each case will be used
  /// {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;

  /// {@macro post_appbar_builder}
  final LMFeedPostAppBarBuilder? appBarBuilder;

  /// {@macro post_comment_builder}
  final LMFeedPostCommentBuilder? commentBuilder;

  final Widget Function(BuildContext, LMPostViewData)? bottomTextFieldBuilder;

  final Widget Function(BuildContext)? commentSeparatorBuilder;

  final bool openKeyboard;

  final LMPostDetailScreenConfig? config;

  @override
  State<LMFeedPostDetailScreen> createState() => _LMFeedPostDetailScreenState();
}

class _LMFeedPostDetailScreenState extends State<LMFeedPostDetailScreen> {
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

  final LMFeedPostBloc postBloc = LMFeedPostBloc.instance;
  final LMFeedWidgetUtility _widgetBuilder = LMFeedCore.widgetUtility;
  final LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.postDetailScreen;
  final ValueNotifier _rebuildComment = ValueNotifier(false);
  final PagingController<int, LMCommentViewData> _pagingController =
      PagingController(firstPageKey: 1);
  final LMFeedFetchCommentReplyBloc _commentRepliesBloc =
      LMFeedFetchCommentReplyBloc.instance;
  LMFeedPostDetailScreenHandler? _postDetailScreenHandler;
  Future<LMPostViewData?>? getPostData;
  LMUserViewData currentUser = LMFeedLocalPreference.instance.fetchUserData()!;
  String? commentIdReplyId;
  bool replyShown = false;
  LMFeedThemeData feedTheme = LMFeedCore.theme;

  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();

  bool right = true;
  List<LMUserTagViewData> userTags = [];
  LMPostDetailScreenConfig? config;

  @override
  void initState() {
    super.initState();
    _postDetailScreenHandler =
        LMFeedPostDetailScreenHandler(_pagingController, widget.postId);
    updatePostAndCommentData();
    right = LMFeedUserUtils.checkCommentRights();
    if (widget.openKeyboard) {
      _postDetailScreenHandler!.openOnScreenKeyboard();
    }

    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.commentListOpen,
        widgetSource: LMFeedWidgetSource.postDetailScreen,
        deprecatedEventName: LMFeedAnalyticsKeysDep.commentListOpen,
        eventProperties: {
          'postId': widget.postId,
        },
      ),
    );
    config = widget.config ?? LMFeedCore.config.postDetailConfig;
  }

  @override
  void didUpdateWidget(covariant LMFeedPostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      _pagingController.itemList?.clear();
      _postDetailScreenHandler =
          LMFeedPostDetailScreenHandler(_pagingController, widget.postId);
      updatePostAndCommentData();
    }
    config = widget.config ?? LMFeedCore.config.postDetailConfig;
  }

  @override
  void dispose() {
    LMFeedCommentBloc.instance.add(LMFeedCommentCancelEvent());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator.adaptive(
        onRefresh: () {
          _pagingController.refresh();
          _commentRepliesBloc.add(LMFeedClearCommentRepliesEvent());
          return Future.value();
        },
        color: feedTheme.primaryColor,
        backgroundColor: feedTheme.container,
        child: FutureBuilder<LMPostViewData?>(
          future: getPostData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return BlocListener(
                listener: (context, state) {
                  if (state is LMFeedPostUpdateState) {
                    if (state.postId == widget.postId) {
                      LMFeedPostUtils.updatePostData(
                        postViewData: _postDetailScreenHandler!.postData!,
                        actionType: state.actionType,
                        commentId: state.commentId,
                      );
                      _postDetailScreenHandler!.rebuildPostWidget.value =
                          !_postDetailScreenHandler!.rebuildPostWidget.value;
                    }
                  } else if (state is LMFeedEditPostUploadedState) {
                    LMPostViewData editedPost = state.postData.copyWith();

                    _postDetailScreenHandler!.postData = editedPost;
                    _postDetailScreenHandler!.rebuildPostWidget.value =
                        !_postDetailScreenHandler!.rebuildPostWidget.value;
                  } else if (state is LMFeedPostDeletionErrorState) {
                    LMFeedCore.showSnackBar(
                      LMFeedSnackBar(
                        content: LMFeedText(text: (state).message),
                      ),
                    );
                  }
                },
                bloc: postBloc,
                child: ValueListenableBuilder(
                    valueListenable:
                        _postDetailScreenHandler!.rebuildPostWidget,
                    builder: (context, _, __) {
                      if (_postDetailScreenHandler!.postData == null) {
                        return const SizedBox.shrink();
                      }
                      return _widgetBuilder.scaffold(
                        source: _widgetSource,
                        resizeToAvoidBottomInset: true,
                        backgroundColor: feedTheme.backgroundColor,
                        bottomNavigationBar: widget.bottomTextFieldBuilder
                                ?.call(context,
                                    _postDetailScreenHandler!.postData!) ??
                            defBottomTextField(),
                        appBar:
                            widget.appBarBuilder?.call(context, defAppBar()) ??
                                defAppBar(),
                        body: Builder(builder: (context) {
                          return CustomScrollView(
                            slivers: [
                              SliverToBoxAdapter(
                                child: widget.postBuilder?.call(
                                        context,
                                        defPostWidget(context),
                                        _postDetailScreenHandler!.postData!) ??
                                    _widgetBuilder.postWidgetBuilder.call(
                                        context,
                                        defPostWidget(context),
                                        _postDetailScreenHandler!.postData!,
                                        source: _widgetSource),
                              ),
                              SliverToBoxAdapter(
                                child: _postDetailScreenHandler!
                                                .postData!.commentCount ==
                                            0 ||
                                        !config!.showCommentCountOnList
                                    ? const SizedBox.shrink()
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: feedTheme.container),
                                        margin:
                                            const EdgeInsets.only(top: 10.0),
                                        padding:
                                            feedTheme.commentStyle.padding ??
                                                const EdgeInsets.symmetric(
                                                  horizontal: 16.0,
                                                ),
                                        alignment: Alignment.topLeft,
                                        child: LMFeedText(
                                          text: LMFeedPostUtils
                                              .getCommentCountTextWithCount(
                                                  _postDetailScreenHandler!
                                                      .postData!.commentCount),
                                          style: LMFeedTextStyle(
                                            textStyle: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                              color: feedTheme.onContainer,
                                            ),
                                          ),
                                        ),
                                      ),
                              ),
                              BlocListener<LMFeedCommentBloc,
                                  LMFeedCommentHandlerState>(
                                bloc: _postDetailScreenHandler!
                                    .commentHandlerBloc,
                                listener: (context, state) {
                                  _postDetailScreenHandler!
                                      .handleBlocChanges(state);
                                },
                                child: PagedSliverList.separated(
                                  pagingController: _postDetailScreenHandler!
                                      .commentListPagingController,
                                  builderDelegate: PagedChildBuilderDelegate<
                                      LMCommentViewData>(
                                    firstPageProgressIndicatorBuilder:
                                        (context) {
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 150.0),
                                        child: LMFeedLoader(),
                                      );
                                    },
                                    newPageProgressIndicatorBuilder: (context) {
                                      return _widgetBuilder
                                          .newPageProgressIndicatorBuilderFeed(
                                              context);
                                    },
                                    noItemsFoundIndicatorBuilder: (context) =>
                                        const LMFeedEmptyCommentWidget(),
                                    itemBuilder:
                                        (context, commentViewData, index) {
                                      LMUserViewData userViewData;
                                      if (!_postDetailScreenHandler!.users
                                          .containsKey(commentViewData.uuid)) {
                                        return const SizedBox.shrink();
                                      }
                                      userViewData = _postDetailScreenHandler!
                                          .users[commentViewData.uuid]!;

                                      LMFeedCommentWidget commentWidget =
                                          defCommentTile(commentViewData,
                                              userViewData, context);

                                      return ValueListenableBuilder(
                                          valueListenable: _rebuildComment,
                                          builder: (context, _, __) {
                                            return SizedBox(
                                              child: Column(
                                                children: [
                                                  widget.commentBuilder?.call(
                                                          context,
                                                          commentWidget,
                                                          _postDetailScreenHandler!
                                                              .postData!) ??
                                                      _widgetBuilder
                                                          .commentBuilder
                                                          .call(
                                                              context,
                                                              commentWidget,
                                                              _postDetailScreenHandler!
                                                                  .postData!),
                                                  (replyShown &&
                                                          commentIdReplyId ==
                                                              commentViewData
                                                                  .id)
                                                      ? LMFeedCommentReplyWidget(
                                                          post:
                                                              _postDetailScreenHandler!
                                                                  .postData!,
                                                          commentBuilder: widget
                                                                  .commentBuilder ??
                                                              LMFeedCore
                                                                  .widgetUtility
                                                                  .commentBuilder,
                                                          refresh: () {
                                                            _pagingController
                                                                .refresh();
                                                          },
                                                          postId: widget.postId,
                                                          reply:
                                                              commentViewData,
                                                          user:
                                                              _postDetailScreenHandler!
                                                                      .users[
                                                                  commentViewData
                                                                      .uuid]!,
                                                        )
                                                      : const SizedBox.shrink()
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                  ),
                                  separatorBuilder: (context, index) =>
                                      widget.commentSeparatorBuilder
                                          ?.call(context) ??
                                      const Divider(
                                        thickness: 0.2,
                                        height: 0,
                                      ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(
                                  height: 100,
                                ),
                              ),
                            ],
                          );
                        }),
                      );
                    }),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                backgroundColor: feedTheme.backgroundColor,
                body: const LMFeedLoader(),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                backgroundColor: feedTheme.backgroundColor,
                body: Center(
                  child: Text(
                    '${snapshot.error}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  LMFeedMenuAction defLMFeedMenuAction(LMCommentViewData commentViewData) =>
      LMFeedMenuAction(
        onCommentReport: () {
          showModalBottomSheet(
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
            backgroundColor: feedTheme.container,
            clipBehavior: Clip.hardEdge,
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            builder: (context) => LMFeedReportBottomSheet(
              entityId: commentViewData.id,
              entityType: 6,
              entityCreatorId: commentViewData.uuid,
            ),
          );
        },
        onCommentEdit: () {
          debugPrint('Editing functionality');

          LMCommentMetaDataBuilder commentMetaDataBuilder =
              LMCommentMetaDataBuilder()
                ..postId(_postDetailScreenHandler!.postData!.id)
                ..commentActionType(LMFeedCommentActionType.edit)
                ..commentText(LMFeedTaggingHelper.convertRouteToTag(
                    commentViewData.text));

          if (commentViewData.level == 0) {
            commentMetaDataBuilder
              ..commentActionEntity(LMFeedCommentType.parent)
              ..level(0)
              ..commentId(commentViewData.id);
          } else {
            commentMetaDataBuilder
              ..level(1)
              ..commentActionEntity(LMFeedCommentType.reply)
              ..commentId(commentViewData.parentComment!.id)
              ..replyId(commentViewData.id);
          }

          _postDetailScreenHandler!.commentHandlerBloc.add(
            LMFeedCommentOngoingEvent(
              commentMetaData: commentMetaDataBuilder.build(),
            ),
          );
        },
        onCommentDelete: () {
          String commentCreatorUUID = commentViewData.user.sdkClientInfo.uuid;

          showDialog(
            context: context,
            builder: (childContext) => LMFeedDeleteConfirmationDialog(
              title: 'Delete $commentTitleFirstCapSingular',
              uuid: commentCreatorUUID,
              content:
                  'Are you sure you want to delete this $commentTitleSmallCapSingular. This action can not be reversed.',
              action: (String reason) async {
                Navigator.of(childContext).pop();

                DeleteCommentRequest deleteCommentRequest =
                    (DeleteCommentRequestBuilder()
                          ..postId(widget.postId)
                          ..commentId(commentViewData.id)
                          ..reason(
                              reason.isEmpty ? "Reason for deletion" : reason))
                        .build();

                LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
                      ..commentActionEntity(LMFeedCommentType.parent)
                      ..postId(_postDetailScreenHandler!.postData!.id)
                      ..commentActionType(LMFeedCommentActionType.delete)
                      ..level(0)
                      ..commentId(commentViewData.id))
                    .build();
                _postDetailScreenHandler!
                    .deleteCommentFromController(commentViewData.id);
                _postDetailScreenHandler!.rebuildPostWidget.value =
                    !_postDetailScreenHandler!.rebuildPostWidget.value;

                _postDetailScreenHandler!.commentHandlerBloc.add(
                    LMFeedCommentActionEvent(
                        commentActionRequest: deleteCommentRequest,
                        commentMetaData: commentMetaData));

                LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
                  postId: _postDetailScreenHandler!.postData!.id,
                  commentId: commentViewData.id,
                  actionType: LMFeedPostActionType.commentDeleted,
                  source: LMFeedWidgetSource.postDetailScreen,
                ));
              },
              actionText: 'Delete',
            ),
          );
        },
      );

  LMFeedAppBar defAppBar() {
    return LMFeedAppBar(
      leading: LMFeedButton(
        style: LMFeedButtonStyle(
          margin: 20.0,
          icon: LMFeedIcon(
            type: LMFeedIconType.icon,
            icon: Platform.isAndroid
                ? Icons.arrow_back
                : CupertinoIcons.chevron_back,
            style: LMFeedIconStyle(
              size: 28,
              color: feedTheme.onContainer,
            ),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LMFeedText(
            text: postTitleFirstCap,
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: feedTheme.onContainer,
              ),
            ),
          ),
          (_postDetailScreenHandler?.postData?.commentCount == null ||
                  _postDetailScreenHandler!.postData!.commentCount == 0)
              ? const SizedBox.shrink()
              : LMFeedText(
                  text: LMFeedPostUtils.getCommentCountTextWithCount(
                          _postDetailScreenHandler!.postData?.commentCount ?? 0)
                      .toLowerCase(),
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: feedTheme.primaryColor,
                    ),
                  ),
                ),
        ],
      ),
      trailing: const [SizedBox(width: 36)],
      style: LMFeedAppBarStyle(
        backgroundColor: feedTheme.container,
        height: 61,
      ),
    );
  }

  LMFeedPostWidget defPostWidget(BuildContext context) {
    return LMFeedPostWidget(
      post: _postDetailScreenHandler!.postData!,
      user: _postDetailScreenHandler!
          .users[_postDetailScreenHandler!.postData!.uuid]!,
      topics: _postDetailScreenHandler!.postData!.topics,
      onMediaTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments:
                  _postDetailScreenHandler!.postData!.attachments ?? [],
              post: _postDetailScreenHandler!.postData!,
              user: _postDetailScreenHandler!
                  .users[_postDetailScreenHandler!.postData!.uuid]!,
            ),
          ),
        );
      },
      onPostTap: (context, post) {
        widget.onPostTap?.call();
      },
      isFeed: false,
      onTagTap: (String uuid) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid,
            context: context,
          ),
        );
      },
      style: feedTheme.postStyle,
      header: _defPostHeader(context),
      content: _defContentWidget(_postDetailScreenHandler!.postData!),
      footer: _defFooterWidget(),
      topicWidget: _defTopicWidget(),
      media: _defPostMedia(),
    );
  }

  LMFeedPostTopic _defTopicWidget() {
    return LMFeedPostTopic(
      topics: _postDetailScreenHandler!.postData!.topics,
      post: _postDetailScreenHandler!.postData!,
      style: feedTheme.topicStyle,
    );
  }

  LMFeedPostContent _defContentWidget(LMPostViewData post) {
    return LMFeedPostContent(
      onTagTap: (String uuid) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid,
            context: context,
          ),
        );
      },
      style: feedTheme.contentStyle,
      text: post.text,
      heading: post.heading,
      expanded: true,
    );
  }

  LMFeedPostFooter _defFooterWidget() {
    return LMFeedPostFooter(
      likeButton: defLikeButton(),
      commentButton: defCommentButton(),
      shareButton: defShareButton(),
      saveButton: defSaveButton(),
      repostButton: defRepostButton(),
      postFooterStyle: feedTheme.footerStyle,
      showRepostButton: !_postDetailScreenHandler!.postData!.isRepost,
    );
  }

  LMFeedPostHeader _defPostHeader(BuildContext context) {
    return LMFeedPostHeader(
      user: _postDetailScreenHandler!
          .users[_postDetailScreenHandler!.postData!.uuid]!,
      isFeed: true,
      postViewData: _postDetailScreenHandler!.postData!,
      postHeaderStyle: feedTheme.headerStyle,
      onProfileTap: () {
        LMFeedCore.instance.lmFeedClient.routeToProfile(
            _postDetailScreenHandler!
                .users[_postDetailScreenHandler!.postData!.uuid]!
                .sdkClientInfo
                .uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: _postDetailScreenHandler!
                .users[_postDetailScreenHandler!.postData!.uuid]!
                .sdkClientInfo
                .uuid,
            context: context,
          ),
        );
      },
      menu: LMFeedMenu(
        menuItems: _postDetailScreenHandler!.postData?.menuItems ?? [],
        removeItemIds: {},
        action: LMFeedMenuAction(
          onPostReport: () => handlePostReportAction(),
          onPostPin: () => handlePostPinAction(),
          onPostUnpin: () => handlePostPinAction(),
          onPostEdit: () {
            // Mute all video controllers
            // to prevent video from playing in background
            // while editing the post
            LMFeedVideoProvider.instance.forcePauseAllControllers();

            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => LMFeedEditPostScreen(
                  postId: widget.postId,
                ),
              ),
            );
          },
          onPostDelete: () {
            String postCreatorUUID =
                _postDetailScreenHandler!.postData!.user.sdkClientInfo.uuid;

            showDialog(
              context: context,
              builder: (childContext) => LMFeedDeleteConfirmationDialog(
                title: 'Delete $postTitleFirstCap',
                uuid: postCreatorUUID,
                content:
                    'Are you sure you want to delete this $postTitleSmallCap. This action can not be reversed.',
                action: (String reason) async {
                  Navigator.of(childContext).pop();

                  String postType = LMFeedPostUtils.getPostType(
                      _postDetailScreenHandler!.postData!.attachments);

                  LMFeedAnalyticsBloc.instance.add(
                    LMFeedFireAnalyticsEvent(
                      eventName: LMFeedAnalyticsKeys.postDeleted,
                      widgetSource: LMFeedWidgetSource.postDetailScreen,
                      deprecatedEventName: LMFeedAnalyticsKeysDep.postDeleted,
                      eventProperties: {
                        "post_id": _postDetailScreenHandler!.postData!.id,
                        "post_type": postType,
                        "user_id": _postDetailScreenHandler!.postData!.uuid,
                        "user_state": isCm ? "CM" : "member",
                      },
                    ),
                  );

                  postBloc.add(
                    LMFeedDeletePostEvent(
                      postId: _postDetailScreenHandler!.postData!.id,
                      reason: reason,
                      isRepost: _postDetailScreenHandler!.postData!.isRepost,
                    ),
                  );
                  Navigator.of(context).pop();
                },
                actionText: 'Delete',
              ),
            );
          },
        ),
      ),
    );
  }

  LMFeedPostMedia _defPostMedia() {
    return LMFeedPostMedia(
      postId: _postDetailScreenHandler!.postData!.id,
      attachments: _postDetailScreenHandler!.postData!.attachments!,
      style: feedTheme.mediaStyle.copyWith(
        pollStyle: LMFeedPollStyle.inFeed(),
      ),
      carouselIndicatorBuilder:
          _widgetBuilder.postMediaCarouselIndicatorBuilder,
      imageBuilder: _widgetBuilder.imageBuilder,
      videoBuilder: _widgetBuilder.videoBuilder,
      onMediaTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LMFeedMediaPreviewScreen(
              postAttachments:
                  _postDetailScreenHandler!.postData!.attachments ?? [],
              post: _postDetailScreenHandler!.postData!,
              user: _postDetailScreenHandler!
                  .users[_postDetailScreenHandler!.postData!.uuid]!,
            ),
          ),
        );
      },
    );
  }

  LMFeedButton defLikeButton() => LMFeedButton(
        isActive: _postDetailScreenHandler!.postData!.isLiked,
        text: LMFeedText(
            text: LMFeedPostUtils.getLikeCountTextWithCount(
                _postDetailScreenHandler!.postData!.likeCount)),
        style: feedTheme.footerStyle.likeButtonStyle,
        onTextTap: () {
          // VideoController? videoController = LMFeedVideoProvider.instance
          //     .getVideoController(_postDetailScreenHandler!.postData!.id);

          // videoController?.player.pause();

          LMFeedVideoProvider.instance.pauseCurrentVideo();

          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedLikesScreen(
                postId: _postDetailScreenHandler!.postData!.id,
              ),
            ),
          );
        },
        onTap: () async {
          postBloc.add(LMFeedUpdatePostEvent(
              postId: _postDetailScreenHandler!.postData!.id,
              source: LMFeedWidgetSource.postDetailScreen,
              actionType: _postDetailScreenHandler!.postData!.isLiked
                  ? LMFeedPostActionType.unlike
                  : LMFeedPostActionType.like));

          final likePostRequest = (LikePostRequestBuilder()
                ..postId(_postDetailScreenHandler!.postData!.id))
              .build();

          final LikePostResponse response =
              await LMFeedCore.client.likePost(likePostRequest);

          // if (!response.success) {
          //   postBloc.add(LMFeedUpdatePostEvent(
          //       postId: _postDetailScreenHandler!.postData!.id,
          //       source: LMFeedWidgetSource.postDetailScreen,
          //       actionType: _postDetailScreenHandler!.postData!.isLiked
          //           ? LMFeedPostActionType.unlike
          //           : LMFeedPostActionType.like));
          // }
        },
      );

  LMFeedButton defCommentButton() => LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(
              _postDetailScreenHandler!.postData!.commentCount),
        ),
        style: feedTheme.footerStyle.commentButtonStyle,
        onTap: () {
          _postDetailScreenHandler!.openOnScreenKeyboard();
        },
        onTextTap: () {
          _postDetailScreenHandler!.openOnScreenKeyboard();
        },
      );

  LMFeedButton defSaveButton() => LMFeedButton(
        isActive: _postDetailScreenHandler!.postData!.isSaved,
        onTap: () async {
          postBloc.add(LMFeedUpdatePostEvent(
            postId: _postDetailScreenHandler!.postData!.id,
            source: LMFeedWidgetSource.postDetailScreen,
            actionType: _postDetailScreenHandler!.postData!.isSaved
                ? LMFeedPostActionType.unsaved
                : LMFeedPostActionType.saved,
          ));

          final savePostRequest = (SavePostRequestBuilder()
                ..postId(_postDetailScreenHandler!.postData!.id))
              .build();

          final SavePostResponse response =
              await LMFeedCore.client.savePost(savePostRequest);

          if (!response.success) {
            postBloc.add(LMFeedUpdatePostEvent(
              postId: _postDetailScreenHandler!.postData!.id,
              source: LMFeedWidgetSource.postDetailScreen,
              actionType: _postDetailScreenHandler!.postData!.isSaved
                  ? LMFeedPostActionType.unsaved
                  : LMFeedPostActionType.saved,
            ));
          } else {
            LMFeedCore.showSnackBar(
              LMFeedSnackBar(
                content: LMFeedText(
                    text: _postDetailScreenHandler!.postData!.isSaved
                        ? "$postTitleFirstCap Saved"
                        : "$postTitleFirstCap Unsaved"),
              ),
            );
          }
        },
        style: feedTheme.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton() => LMFeedButton(
        text: const LMFeedText(text: "Share"),
        onTap: () {
          LMFeedDeepLinkHandler()
              .sharePost(_postDetailScreenHandler!.postData!.id);
        },
        style: feedTheme.footerStyle.shareButtonStyle,
      );
  LMFeedButton defRepostButton() => LMFeedButton(
        text: LMFeedText(
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: _postDetailScreenHandler!.postData!.isRepostedByUser
                  ? feedTheme.primaryColor
                  : null,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          text: _postDetailScreenHandler!.postData!.repostCount == 0
              ? ''
              : _postDetailScreenHandler!.postData!.repostCount.toString(),
        ),
        onTap: right
            ? () async {
                if (postBloc.state is! LMFeedEditPostUploadingState) {
                  LMFeedAnalyticsBloc.instance.add(
                      const LMFeedFireAnalyticsEvent(
                          eventName: LMFeedAnalyticsKeys.postCreationStarted,
                          widgetSource: LMFeedWidgetSource.postDetailScreen,
                          deprecatedEventName:
                              LMFeedAnalyticsKeysDep.postCreationStarted,
                          eventProperties: {}));

                  LMFeedVideoProvider.instance.forcePauseAllControllers();
                  // ignore: use_build_context_synchronously
                  LMAttachmentViewData attachmentViewData =
                      (LMAttachmentViewDataBuilder()
                            ..attachmentType(8)
                            ..attachmentMeta((LMAttachmentMetaViewDataBuilder()
                                  ..repost(_postDetailScreenHandler!.postData!))
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
                    LMFeedSnackBar(
                      content: LMFeedText(
                        text: 'A $postTitleSmallCap is already uploading.',
                      ),
                    ),
                  );
                }
              }
            : () {
                LMFeedCore.showSnackBar(
                  LMFeedSnackBar(
                    content: LMFeedText(
                      text:
                          'You do not have permission to create a $postTitleSmallCap',
                    ),
                  ),
                );
              },
        style: feedTheme.footerStyle.repostButtonStyle?.copyWith(
            icon: feedTheme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedTheme.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color:
                          _postDetailScreenHandler!.postData!.isRepostedByUser
                              ? feedTheme.primaryColor
                              : null),
            ),
            activeIcon: feedTheme.footerStyle.repostButtonStyle?.icon?.copyWith(
              style: feedTheme.footerStyle.repostButtonStyle?.icon?.style
                  ?.copyWith(
                      color:
                          _postDetailScreenHandler!.postData!.isRepostedByUser
                              ? feedTheme.primaryColor
                              : null),
            )),
      );

  LMFeedCommentWidget defCommentTile(LMCommentViewData commentViewData,
      LMUserViewData userViewData, BuildContext context) {
    return LMFeedCommentWidget(
      user: userViewData,
      comment: commentViewData,
      menu: (menu) {
        return menu.copyWith(
          removeItemIds: {
            // commentEditId,
            // commentReportId,
          },
        );
      },
      style: feedTheme.commentStyle,
      lmFeedMenuAction: defLMFeedMenuAction(commentViewData),
      profilePicture: LMFeedProfilePicture(
        style: LMFeedProfilePictureStyle(
          size: 36,
          backgroundColor: feedTheme.primaryColor,
        ),
        fallbackText:
            _postDetailScreenHandler!.users[commentViewData.uuid]!.name,
        onTap: () {
          LMFeedCore.instance.lmFeedClient.routeToProfile(
              _postDetailScreenHandler!
                  .users[commentViewData.uuid]!.sdkClientInfo.uuid);

          LMFeedProfileBloc.instance.add(
            LMFeedRouteToUserProfileEvent(
              uuid: _postDetailScreenHandler!
                  .users[commentViewData.uuid]!.sdkClientInfo.uuid,
              context: context,
            ),
          );
        },
        imageUrl:
            _postDetailScreenHandler!.users[commentViewData.uuid]!.imageUrl,
      ),
      likeButton: defCommentLikeButton(commentViewData),
      replyButton: defCommentReplyButton(commentViewData),
      showRepliesButton: defCommentShowRepliesButton(commentViewData),
      onTagTap: (String uuid) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(uuid);
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: uuid,
            context: context,
          ),
        );
      },
    );
  }

  LMFeedButton defCommentLikeButton(LMCommentViewData commentViewData) {
    return LMFeedButton(
      style: feedTheme.commentStyle.likeButtonStyle?.copyWith(
              showText: commentViewData.likesCount == 0 ? false : true) ??
          LMFeedButtonStyle(
            margin: 10.0,
            showText: commentViewData.likesCount == 0 ? false : true,
            icon: const LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.thumb_up_alt_outlined,
              style: LMFeedIconStyle(
                size: 20,
              ),
            ),
            activeIcon: LMFeedIcon(
              type: LMFeedIconType.icon,
              style: LMFeedIconStyle(
                color: feedTheme.primaryColor,
                size: 20,
              ),
              icon: Icons.thumb_up_alt_rounded,
            ),
          ),
      text: LMFeedText(
        text: LMFeedPostUtils.getLikeCountTextWithCount(
            commentViewData.likesCount),
        style: const LMFeedTextStyle(
          textStyle: TextStyle(fontSize: 12),
        ),
      ),
      activeText: LMFeedText(
        text: LMFeedPostUtils.getLikeCountTextWithCount(
            commentViewData.likesCount),
        style: LMFeedTextStyle(
          textStyle: TextStyle(color: feedTheme.primaryColor, fontSize: 12),
        ),
      ),
      onTextTap: () {
        // VideoController? videoController = LMFeedVideoProvider.instance
        //     .getVideoController(_postDetailScreenHandler!.postData!.id);

        // videoController?.player.pause();

        LMFeedVideoProvider.instance.pauseCurrentVideo();

        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedLikesScreen(
              postId: _postDetailScreenHandler!.postData!.id,
              commentId: commentViewData.id,
            ),
          ),
        );
      },
      onTap: () async {
        commentViewData.likesCount = commentViewData.isLiked
            ? commentViewData.likesCount - 1
            : commentViewData.likesCount + 1;
        commentViewData.isLiked = !commentViewData.isLiked;
        _postDetailScreenHandler!.rebuildPostWidget.value =
            !_postDetailScreenHandler!.rebuildPostWidget.value;

        ToggleLikeCommentRequest toggleLikeCommentRequest =
            (ToggleLikeCommentRequestBuilder()
                  ..commentId(commentViewData.id)
                  ..postId(widget.postId))
                .build();

        final ToggleLikeCommentResponse response = await LMFeedCore
            .instance.lmFeedClient
            .likeComment(toggleLikeCommentRequest);

        if (!response.success) {
          commentViewData.likesCount = commentViewData.isLiked
              ? commentViewData.likesCount - 1
              : commentViewData.likesCount + 1;
          commentViewData.isLiked = !commentViewData.isLiked;

          _postDetailScreenHandler!.rebuildPostWidget.value =
              !_postDetailScreenHandler!.rebuildPostWidget.value;
        }
      },
      isActive: commentViewData.isLiked,
    );
  }

  LMFeedButton defCommentReplyButton(LMCommentViewData commentViewData) {
    return LMFeedButton(
      style: feedTheme.commentStyle.replyButtonStyle ??
          const LMFeedButtonStyle(
            margin: 10,
            icon: LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.comment_outlined,
              style: LMFeedIconStyle(
                size: 20,
              ),
            ),
          ),
      text: const LMFeedText(
        text: "Reply",
        style: LMFeedTextStyle(
            textStyle: TextStyle(
          fontSize: 12,
        )),
      ),
      onTap: () {
        LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
              ..commentActionEntity(LMFeedCommentType.parent)
              ..postId(widget.postId)
              ..commentActionType(LMFeedCommentActionType.replying)
              ..level(0)
              ..user(_postDetailScreenHandler!.users[commentViewData.uuid]!)
              ..commentId(commentViewData.id))
            .build();

        _postDetailScreenHandler!.commentHandlerBloc
            .add(LMFeedCommentOngoingEvent(
          commentMetaData: commentMetaData,
        ));

        _postDetailScreenHandler!.openOnScreenKeyboard();
      },
    );
  }

  LMFeedButton defCommentShowRepliesButton(LMCommentViewData commentViewData) {
    return LMFeedButton(
      onTap: () {
        if (replyShown &&
            commentIdReplyId != null &&
            commentIdReplyId == commentViewData.id) {
          _commentRepliesBloc.add(LMFeedClearCommentRepliesEvent());
          replyShown = false;
          commentIdReplyId = null;
        } else if (replyShown &&
            commentIdReplyId != null &&
            commentIdReplyId != commentViewData.id) {
          _commentRepliesBloc.add(LMFeedClearCommentRepliesEvent());
          replyShown = true;
          commentIdReplyId = commentViewData.id;
          _commentRepliesBloc.add(LMFeedGetCommentRepliesEvent(
              commentDetailRequest: (GetCommentRequestBuilder()
                    ..commentId(commentViewData.id)
                    ..postId(widget.postId)
                    ..page(1))
                  .build(),
              forLoadMore: true));
        } else {
          replyShown = true;
          commentIdReplyId = commentViewData.id;
          _commentRepliesBloc.add(LMFeedGetCommentRepliesEvent(
              commentDetailRequest: (GetCommentRequestBuilder()
                    ..commentId(commentViewData.id)
                    ..postId(widget.postId)
                    ..page(1))
                  .build(),
              forLoadMore: true));
        }
        _postDetailScreenHandler!.rebuildPostWidget.value =
            !_postDetailScreenHandler!.rebuildPostWidget.value;
      },
      text: LMFeedText(
        text:
            "${commentViewData.repliesCount} ${commentViewData.repliesCount > 1 ? 'Replies' : 'Reply'}",
        style: LMFeedTextStyle(
          textStyle: TextStyle(
            color: feedTheme.primaryColor,
            fontSize: 14,
          ),
        ),
      ),
      style: feedTheme.commentStyle.showRepliesButtonStyle,
    );
  }

  Widget defBottomTextField() {
    return SafeArea(
      child: BlocBuilder<LMFeedCommentBloc, LMFeedCommentHandlerState>(
        bloc: _postDetailScreenHandler!.commentHandlerBloc,
        builder: (context, state) => Container(
          decoration: BoxDecoration(
            color: feedTheme.container,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              LikeMindsTheme.kVerticalPaddingMedium,
              state is LMFeedCommentActionOngoingState
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Row(
                        children: [
                          LMFeedText(
                            text: state.commentMetaData.commentActionType ==
                                    LMFeedCommentActionType.edit
                                ? "Editing ${state.commentMetaData.replyId != null ? 'reply' : '$commentTitleSmallCapSingular'} "
                                : "Replying to ",
                            style: LMFeedTextStyle(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: feedTheme.onContainer,
                              ),
                            ),
                          ),
                          state.commentMetaData.commentActionType ==
                                  LMFeedCommentActionType.edit
                              ? const SizedBox()
                              : LMFeedText(
                                  text: state.commentMetaData.user!.name,
                                  style: const LMFeedTextStyle(
                                    textStyle: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                          const Spacer(),
                          LMFeedButton(
                            onTap: () {
                              _postDetailScreenHandler!.commentHandlerBloc
                                  .add(LMFeedCommentCancelEvent());
                            },
                            style: const LMFeedButtonStyle(
                              icon: LMFeedIcon(
                                type: LMFeedIconType.icon,
                                icon: Icons.close,
                                style: LMFeedIconStyle(
                                  color: LikeMindsTheme.greyColor,
                                  size: 24,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              Container(
                decoration: BoxDecoration(
                    color: feedTheme.primaryColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24)),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding:
                    const EdgeInsets.symmetric(vertical: 2.0, horizontal: 6.0),
                child: Row(
                  children: [
                    LMFeedProfilePicture(
                      fallbackText: currentUser.name,
                      imageUrl: currentUser.imageUrl,
                      style: LMFeedProfilePictureStyle.basic().copyWith(
                        backgroundColor: feedTheme.primaryColor,
                        size: 36,
                        fallbackTextStyle: LMFeedProfilePictureStyle.basic()
                            .fallbackTextStyle
                            ?.copyWith(
                              textStyle: LMFeedProfilePictureStyle.basic()
                                  .fallbackTextStyle
                                  ?.textStyle
                                  ?.copyWith(
                                    fontSize: 14,
                                  ),
                            ),
                      ),
                      onTap: () {
                        LMFeedCore.instance.lmFeedClient
                            .routeToProfile(currentUser.sdkClientInfo.uuid);
                      },
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: LMTaggingAheadTextField(
                        isDown: false,
                        enabled: LMFeedCore.config.composeConfig.enableTagging,
                        maxLines: 5,
                        onTagSelected: (tag) {
                          userTags.add(tag);
                        },
                        controller: _postDetailScreenHandler!.commentController,
                        decoration:
                            feedTheme.textFieldStyle.decoration?.copyWith(
                          enabled: right,
                          hintText: right
                              ? config?.commentTextFieldHint ??
                                  'Write a $commentTitleSmallCapSingular'
                              : "You do not have permission to create a $commentTitleSmallCapSingular.",
                        ),
                        focusNode: _postDetailScreenHandler!.focusNode,
                        onChange: (String p0) {},
                        scrollPhysics: const AlwaysScrollableScrollPhysics(),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: !right
                          ? null
                          : LMFeedButton(
                              style: const LMFeedButtonStyle(
                                height: 18,
                              ),
                              text: LMFeedText(
                                text: "Create",
                                style: LMFeedTextStyle(
                                  textAlign: TextAlign.center,
                                  textStyle: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: feedTheme.textFieldStyle
                                            .decoration?.hintStyle?.fontSize ??
                                        13,
                                    color: feedTheme.primaryColor,
                                  ),
                                ),
                              ),
                              onTap: () {
                                _postDetailScreenHandler!
                                    .closeOnScreenKeyboard();
                                String commentText =
                                    LMFeedTaggingHelper.encodeString(
                                  _postDetailScreenHandler!
                                      .commentController.text,
                                  userTags,
                                ).trim();
                                commentText = commentText.trim();
                                if (commentText.isEmpty) {
                                  LMFeedCore.showSnackBar(
                                    LMFeedSnackBar(
                                      content: LMFeedText(
                                        text:
                                            "Please write something to create a $commentTitleSmallCapSingular",
                                      ),
                                    ),
                                  );

                                  return;
                                }

                                _postDetailScreenHandler!.users.putIfAbsent(
                                    currentUser.uuid, () => currentUser);

                                if (state is LMFeedCommentActionOngoingState) {
                                  if (state.commentMetaData.commentActionType ==
                                      LMFeedCommentActionType.edit) {
                                    if (state.commentMetaData
                                            .commentActionEntity ==
                                        LMFeedCommentType.parent) {
                                      EditCommentRequest editCommentRequest =
                                          (EditCommentRequestBuilder()
                                                ..postId(widget.postId)
                                                ..commentId(state
                                                    .commentMetaData.commentId!)
                                                ..text(commentText))
                                              .build();

                                      _postDetailScreenHandler!
                                          .addTempEditingComment(
                                              state.commentMetaData.commentId ??
                                                  '',
                                              commentText);

                                      _postDetailScreenHandler!
                                          .commentHandlerBloc
                                          .add(LMFeedCommentActionEvent(
                                              commentActionRequest:
                                                  editCommentRequest,
                                              commentMetaData:
                                                  state.commentMetaData));
                                    } else {
                                      EditCommentReplyRequest
                                          editCommentReplyRequest =
                                          (EditCommentReplyRequestBuilder()
                                                ..commentId(state
                                                    .commentMetaData.commentId!)
                                                ..postId(widget.postId)
                                                ..replyId(state
                                                    .commentMetaData.replyId!)
                                                ..text(commentText))
                                              .build();

                                      _commentRepliesBloc.add(
                                          LMFeedEditLocalReplyEvent(
                                              text: commentText,
                                              replyId: state
                                                  .commentMetaData.replyId!));

                                      _postDetailScreenHandler!
                                          .commentHandlerBloc
                                          .add(LMFeedCommentActionEvent(
                                              commentActionRequest:
                                                  editCommentReplyRequest,
                                              commentMetaData:
                                                  state.commentMetaData));
                                    }
                                  } else if (state
                                          .commentMetaData.commentActionType ==
                                      LMFeedCommentActionType.replying) {
                                    LMCommentMetaData commentMetaData =
                                        (LMCommentMetaDataBuilder()
                                              ..commentActionEntity(
                                                  LMFeedCommentType.reply)
                                              ..level(1)
                                              ..postId(widget.postId)
                                              ..commentId(state
                                                  .commentMetaData.commentId!)
                                              ..commentActionType(
                                                  LMFeedCommentActionType
                                                      .replying))
                                            .build();
                                    AddCommentReplyRequest addReplyRequest =
                                        (AddCommentReplyRequestBuilder()
                                              ..postId(widget.postId)
                                              ..text(commentText)
                                              ..tempId(
                                                  '${-DateTime.now().millisecondsSinceEpoch}')
                                              ..commentId(state
                                                  .commentMetaData.commentId!))
                                            .build();

                                    _postDetailScreenHandler!
                                        .addTempReplyCommentToController(
                                      addReplyRequest.tempId ?? '',
                                      commentText,
                                      1,
                                      state.commentMetaData.commentId!,
                                      replyShown,
                                    );
                                    commentIdReplyId =
                                        state.commentMetaData.commentId;
                                    replyShown = true;
                                    _rebuildComment.value =
                                        !_rebuildComment.value;
                                    _postDetailScreenHandler!.commentHandlerBloc
                                        .add(LMFeedCommentActionEvent(
                                            commentActionRequest:
                                                addReplyRequest,
                                            commentMetaData: commentMetaData));
                                  }
                                } else {
                                  DateTime currentTime = DateTime.now();

                                  LMCommentMetaData commentMetaData =
                                      (LMCommentMetaDataBuilder()
                                            ..commentActionEntity(
                                                LMFeedCommentType.parent)
                                            ..level(0)
                                            ..postId(widget.postId)
                                            ..commentActionType(
                                                LMFeedCommentActionType.add))
                                          .build();
                                  AddCommentRequest addCommentRequest =
                                      (AddCommentRequestBuilder()
                                            ..postId(widget.postId)
                                            ..text(commentText)
                                            ..tempId(
                                                '${-DateTime.now().millisecondsSinceEpoch}'))
                                          .build();
                                  _postDetailScreenHandler!
                                      .addTempCommentToController(
                                    addCommentRequest.tempId ?? '',
                                    commentText,
                                    0,
                                    createdTime: currentTime,
                                  );
                                  _postDetailScreenHandler!.commentHandlerBloc
                                      .add(LMFeedCommentActionEvent(
                                          commentActionRequest:
                                              addCommentRequest,
                                          commentMetaData: commentMetaData));
                                }

                                _postDetailScreenHandler!
                                    .closeOnScreenKeyboard();
                                _postDetailScreenHandler!.commentController
                                    .clear();
                              },
                            ),
                    ),
                  ],
                ),
              ),
              LikeMindsTheme.kVerticalPaddingLarge,
            ],
          ),
        ),
      ),
    );
  }

  Future<dynamic> handlePostReportAction() {
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
      backgroundColor: feedTheme.container,
      clipBehavior: Clip.hardEdge,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.0),
          topRight: Radius.circular(20.0),
        ),
      ),
      builder: (context) => LMFeedReportBottomSheet(
        entityId: _postDetailScreenHandler!.postId,
        entityType: 5,
        entityCreatorId: _postDetailScreenHandler!.postData!.uuid,
      ),
    );
  }

  void handlePostPinAction() async {
    final pinPostRequest = (PinPostRequestBuilder()
          ..postId(_postDetailScreenHandler!.postData!.id))
        .build();

    postBloc.add(LMFeedUpdatePostEvent(
      postId: _postDetailScreenHandler!.postData!.id,
      source: LMFeedWidgetSource.postDetailScreen,
      actionType: _postDetailScreenHandler!.postData!.isPinned
          ? LMFeedPostActionType.unpinned
          : LMFeedPostActionType.pinned,
    ));

    final PinPostResponse response =
        await LMFeedCore.client.pinPost(pinPostRequest);

    if (!response.success) {
      postBloc.add(LMFeedUpdatePostEvent(
        postId: _postDetailScreenHandler!.postData!.id,
        source: LMFeedWidgetSource.postDetailScreen,
        actionType: _postDetailScreenHandler!.postData!.isPinned
            ? LMFeedPostActionType.unpinned
            : LMFeedPostActionType.pinned,
      ));
    } else {
      String postType = LMFeedPostUtils.getPostType(
          _postDetailScreenHandler!.postData!.attachments);

      LMFeedAnalyticsBloc.instance.add(
        LMFeedFireAnalyticsEvent(
          eventName: _postDetailScreenHandler!.postData!.isPinned
              ? LMFeedAnalyticsKeys.postPinned
              : LMFeedAnalyticsKeys.postUnpinned,
          widgetSource: LMFeedWidgetSource.postDetailScreen,
          deprecatedEventName: _postDetailScreenHandler!.postData!.isPinned
              ? LMFeedAnalyticsKeysDep.postPinned
              : LMFeedAnalyticsKeysDep.postUnpinned,
          eventProperties: {
            'created_by_id': _postDetailScreenHandler!.postData!.uuid,
            'post_id': _postDetailScreenHandler!.postData!.id,
            'post_type': postType,
          },
        ),
      );
    }
  }

  void updatePostAndCommentData() {
    getPostData =
        _postDetailScreenHandler!.fetchCommentListWithPage(1).then((value) {
      _postDetailScreenHandler!.postData = value;
      _postDetailScreenHandler!.rebuildPostWidget.value =
          !_postDetailScreenHandler!.rebuildPostWidget.value;
      return value;
    });
  }
}
