import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/deep_link/deep_link_handler.dart';
import 'package:likeminds_feed_flutter_core/src/utils/post/post_utils.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';
import 'package:likeminds_feed_flutter_core/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/widgets/comment/comment_reply_widget.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/widgets/comment/default_empty_comment_widget.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/handler/post_detail_screen_handler.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/widgets/delete_dialog.dart';
import 'package:overlay_support/overlay_support.dart';

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
    this.onPostTap,
    this.onLikeClick,
    this.onCommentClick,
    this.openKeyboard = false,
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

  final bool openKeyboard;

  @override
  State<LMFeedPostDetailScreen> createState() => _LMFeedPostDetailScreenState();
}

class _LMFeedPostDetailScreenState extends State<LMFeedPostDetailScreen> {
  final PagingController<int, LMCommentViewData> _pagingController =
      PagingController(firstPageKey: 1);
  final LMFeedFetchCommentReplyBloc _commentRepliesBloc =
      LMFeedFetchCommentReplyBloc.instance;
  LMFeedPostDetailScreenHandler? _postDetailScreenHandler;
  Future<LMPostViewData?>? getPostData;
  LMUserViewData currentUser = LMUserViewDataConvertor.fromUser(
      LMFeedUserLocalPreference.instance.fetchUserData());
  String? commentIdReplyId;
  bool replyShown = false;
  LMFeedThemeData? feedTheme;

  bool right = true;
  List<LMUserTagViewData> userTags = [];

  void onLikeTap() {}

  @override
  void initState() {
    super.initState();
    _postDetailScreenHandler =
        LMFeedPostDetailScreenHandler(_pagingController, widget.postId);
    getPostData =
        _postDetailScreenHandler!.fetchCommentListWithPage(1).then((value) {
      _postDetailScreenHandler!.postData = value;
      _postDetailScreenHandler!.rebuildPostWidget.value =
          !_postDetailScreenHandler!.rebuildPostWidget.value;
      return value;
    });
    right = _postDetailScreenHandler!.checkCommentRights();
    if (widget.openKeyboard) {
      _postDetailScreenHandler!.openOnScreenKeyboard();
    }
  }

  @override
  void didUpdateWidget(covariant LMFeedPostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      _pagingController.itemList?.clear();
      _pagingController.refresh();
      _postDetailScreenHandler =
          LMFeedPostDetailScreenHandler(_pagingController, widget.postId);
      getPostData =
          _postDetailScreenHandler!.fetchCommentListWithPage(1).then((value) {
        _postDetailScreenHandler!.postData = value;
        _postDetailScreenHandler!.rebuildPostWidget.value =
            !_postDetailScreenHandler!.rebuildPostWidget.value;
        return value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    feedTheme = LMFeedTheme.of(context);
    return RefreshIndicator.adaptive(
      onRefresh: () {
        _pagingController.itemList?.clear();
        _pagingController.refresh();
        _commentRepliesBloc.add(LMFeedClearCommentRepliesEvent());
        return Future.value();
      },
      color: feedTheme?.primaryColor,
      backgroundColor: feedTheme?.container,
      child: FutureBuilder<LMPostViewData?>(
        future: getPostData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            return ValueListenableBuilder(
                valueListenable: _postDetailScreenHandler!.rebuildPostWidget,
                builder: (context, _, __) {
                  return Scaffold(
                    resizeToAvoidBottomInset: true,
                    backgroundColor: feedTheme!.backgroundColor,
                    bottomSheet: widget.bottomTextFieldBuilder?.call(
                            context, _postDetailScreenHandler!.postData!) ??
                        defBottomTextField(),
                    appBar: widget.appBarBuilder?.call(context, defAppBar()) ??
                        defAppBar(),
                    body: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                            child: widget.postBuilder?.call(
                                    context,
                                    defPostWidget(),
                                    _postDetailScreenHandler!.postData!) ??
                                defPostWidget()),
                        SliverToBoxAdapter(
                          child: BlocListener<LMFeedCommentHandlerBloc,
                              LMFeedCommentHandlerState>(
                            bloc: _postDetailScreenHandler!.commentHandlerBloc,
                            listener: (context, state) {
                              _postDetailScreenHandler!
                                  .handleBlocChanges(state);
                            },
                            child: Column(
                              children: [
                                _postDetailScreenHandler!
                                            .postData!.commentCount ==
                                        0
                                    ? const SizedBox.shrink()
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: feedTheme?.container),
                                        margin:
                                            const EdgeInsets.only(top: 10.0),
                                        padding:
                                            feedTheme?.commentStyle.padding ??
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
                                              color: feedTheme!.onContainer,
                                            ),
                                          ),
                                        ),
                                      ),
                                PagedListView.separated(
                                  pagingController: _postDetailScreenHandler!
                                      .commetListPagingController,
                                  physics: const NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  builderDelegate: PagedChildBuilderDelegate<
                                      LMCommentViewData>(
                                    firstPageProgressIndicatorBuilder:
                                        (context) {
                                      return const Padding(
                                        padding: EdgeInsets.only(top: 150.0),
                                        child: LMFeedLoader(),
                                      );
                                    },
                                    noItemsFoundIndicatorBuilder: (context) =>
                                        const LMFeedEmptyCommentWidget(),
                                    itemBuilder:
                                        (context, commentViewData, index) {
                                      LMUserViewData userViewData;
                                      if (!_postDetailScreenHandler!.users
                                          .containsKey(
                                              commentViewData.userId)) {
                                        return const SizedBox.shrink();
                                      }
                                      userViewData = _postDetailScreenHandler!
                                          .users[commentViewData.userId]!;

                                      return SizedBox(
                                        child: Column(
                                          children: [
                                            widget.commentBuilder?.call(
                                                    context,
                                                    defCommentTile(
                                                        commentViewData,
                                                        userViewData),
                                                    _postDetailScreenHandler!
                                                        .postData!) ??
                                                defCommentTile(commentViewData,
                                                    userViewData),
                                            (replyShown &&
                                                    commentIdReplyId ==
                                                        commentViewData.id)
                                                ? LMFeedCommentReplyWidget(
                                                    refresh: () {
                                                      _pagingController
                                                          .refresh();
                                                    },
                                                    postId: widget.postId,
                                                    reply: commentViewData,
                                                    user:
                                                        _postDetailScreenHandler!
                                                                .users[
                                                            commentViewData
                                                                .userId]!,
                                                  )
                                                : const SizedBox.shrink()
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  padding: EdgeInsets.zero,
                                  separatorBuilder: (context, index) =>
                                      const Divider(
                                    thickness: 0.2,
                                    height: 0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                  );
                });
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: LMFeedLoader(),
            );
          } else if (snapshot.hasError) {
            return Scaffold(
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
    );
  }

  LMFeedMenuAction defLMFeedMenuAction(LMCommentViewData commentViewData) =>
      LMFeedMenuAction(
        onCommentEdit: () {
          debugPrint('Editing functionality');
          LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
                ..commentActionEntity(LMFeedCommentType.parent)
                ..commentActionType(LMFeedCommentActionType.edit)
                ..level(0)
                ..commentId(commentViewData.id)
                ..commentText(LMFeedTaggingHelper.convertRouteToTag(
                    commentViewData.text)))
              .build();

          _postDetailScreenHandler!.commentHandlerBloc.add(
            LMFeedCommentOngoingEvent(
              commentMetaData: commentMetaData,
            ),
          );
        },
        onCommentDelete: () {
          showDialog(
            context: context,
            builder: (childContext) => LMFeedDeleteConfirmationDialog(
              title: 'Delete Comment',
              userId: commentViewData.userId,
              content:
                  'Are you sure you want to delete this post. This action can not be reversed.',
              action: (String reason) async {
                Navigator.of(childContext).pop();

                LMFeedAnalyticsBloc.instance.add(
                  LMFeedFireAnalyticsEvent(
                    eventName: LMFeedAnalyticsKeys.commentDeleted,
                    eventProperties: {
                      "post_id": widget.postId,
                      "comment_id": commentViewData.id,
                    },
                  ),
                );

                DeleteCommentRequest deleteCommentRequest =
                    (DeleteCommentRequestBuilder()
                          ..postId(widget.postId)
                          ..commentId(commentViewData.id)
                          ..reason(
                              reason.isEmpty ? "Reason for deletion" : reason))
                        .build();

                LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
                      ..commentActionEntity(LMFeedCommentType.parent)
                      ..commentActionType(LMFeedCommentActionType.delete)
                      ..level(0)
                      ..commentId(commentViewData.id))
                    .build();

                _postDetailScreenHandler!.commentHandlerBloc.add(
                    LMFeedCommentActionEvent(
                        commentActionRequest: deleteCommentRequest,
                        commentMetaData: commentMetaData));
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
              color: feedTheme?.onContainer,
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
            text: "Post",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w400,
                color: feedTheme?.onContainer,
              ),
            ),
          ),
          (_postDetailScreenHandler?.postData?.commentCount == null ||
                  _postDetailScreenHandler!.postData!.commentCount == 0)
              ? const SizedBox.shrink()
              : LMFeedText(
                  text: LMFeedPostUtils.getCommentCountTextWithCount(
                      _postDetailScreenHandler!.postData?.commentCount ?? 0),
                  style: LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: feedTheme?.primaryColor,
                    ),
                  ),
                ),
        ],
      ),
      trailing: const SizedBox(width: 36),
      style: const LMFeedAppBarStyle(
        backgroundColor: LikeMindsTheme.whiteColor,
        height: 61,
        mainAxisAlignment: MainAxisAlignment.start,
      ),
    );
  }

  LMFeedPostFooter defPostFooter() {
    return LMFeedPostFooter();
  }

  LMFeedPostWidget defPostWidget() {
    return LMFeedPostWidget(
      post: _postDetailScreenHandler!.postData!,
      user: _postDetailScreenHandler!
          .users[_postDetailScreenHandler!.postData!.userId]!,
      topics: _postDetailScreenHandler!.topics,
      onPostTap: (context, post) {
        debugPrint("Post in detail screen tapped");
        widget.onPostTap?.call();
      },
      isFeed: false,
      onTagTap: (String userId) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            userUniqueId: userId,
          ),
        );
      },
      style: feedTheme!.postStyle,
      header: _defPostHeader(),
      content: _defContentWidget(),
      footer: _defFooterWidget(),
      topicWidget: _defTopicWidget(),
      media: _defPostMedia(),
    );
  }

  LMFeedPostTopic _defTopicWidget() {
    return LMFeedPostTopic(
      topics: _postDetailScreenHandler!.topics,
      post: _postDetailScreenHandler!.postData!,
    );
  }

  LMFeedPostContent _defContentWidget() {
    return LMFeedPostContent(
      onTagTap: (String? userId) {},
    );
  }

  LMFeedPostFooter _defFooterWidget() {
    return LMFeedPostFooter(
      likeButton: defLikeButton(),
      commentButton: defCommentButton(),
      shareButton: defShareButton(),
      saveButton: defSaveButton(),
    );
  }

  LMFeedPostHeader _defPostHeader() {
    return LMFeedPostHeader(
      user: _postDetailScreenHandler!
          .users[_postDetailScreenHandler!.postData!.userId]!,
      isFeed: true,
      postViewData: _postDetailScreenHandler!.postData!,
    );
  }

  LMFeedPostMedia _defPostMedia() {
    return LMFeedPostMedia(
      attachments: _postDetailScreenHandler!.postData!.attachments!,
    );
  }

  LMFeedButton defLikeButton() => LMFeedButton(
        isActive: _postDetailScreenHandler!.postData!.isLiked,
        text: LMFeedText(
          text: LMFeedPostUtils.getLikeCountTextWithCount(
              _postDetailScreenHandler!.postData!.likeCount),
        ),
        style: feedTheme!.footerStyle.likeButtonStyle,
        onTap: () async {
          if (_postDetailScreenHandler!.postData!.isLiked) {
            _postDetailScreenHandler!.postData!.isLiked = false;
            _postDetailScreenHandler!.postData!.likeCount -= 1;
          } else {
            _postDetailScreenHandler!.postData!.isLiked = true;
            _postDetailScreenHandler!.postData!.likeCount += 1;
          }
          _postDetailScreenHandler!.rebuildPostWidget.value =
              !_postDetailScreenHandler!.rebuildPostWidget.value;
          LMFeedPostBloc.instance.add(
              LMFeedUpdatePostEvent(post: _postDetailScreenHandler!.postData!));

          final likePostRequest = (LikePostRequestBuilder()
                ..postId(_postDetailScreenHandler!.postData!.id))
              .build();

          final LikePostResponse response =
              await LMFeedCore.client.likePost(likePostRequest);

          if (!response.success) {
            _postDetailScreenHandler!.postData!.isLiked =
                !_postDetailScreenHandler!.postData!.isLiked;
            _postDetailScreenHandler!.postData!.likeCount =
                _postDetailScreenHandler!.postData!.isLiked
                    ? _postDetailScreenHandler!.postData!.likeCount + 1
                    : _postDetailScreenHandler!.postData!.likeCount - 1;
            _postDetailScreenHandler!.rebuildPostWidget.value =
                !_postDetailScreenHandler!.rebuildPostWidget.value;
            LMFeedPostBloc.instance.add(
              LMFeedUpdatePostEvent(
                post: _postDetailScreenHandler!.postData!,
              ),
            );
          }
        },
      );

  LMFeedButton defCommentButton() => LMFeedButton(
        text: LMFeedText(
          text: LMFeedPostUtils.getCommentCountTextWithCount(
              _postDetailScreenHandler!.postData!.commentCount),
        ),
        style: feedTheme?.footerStyle.commentButtonStyle,
        onTap: () {
          _postDetailScreenHandler!.openOnScreenKeyboard();
        },
      );

  LMFeedButton defSaveButton() => LMFeedButton(
        onTap: () {},
        style: feedTheme?.footerStyle.saveButtonStyle,
      );

  LMFeedButton defShareButton() => LMFeedButton(
        onTap: () {
          LMFeedDeepLinkHandler()
              .sharePost(_postDetailScreenHandler!.postData!.id);
        },
        style: feedTheme?.footerStyle.shareButtonStyle,
      );

  LMFeedCommentWidget defCommentTile(
      LMCommentViewData commentViewData, LMUserViewData userViewData) {
    return LMFeedCommentWidget(
      user: userViewData,
      comment: commentViewData,
      style: feedTheme?.commentStyle ??
          const LMFeedCommentStyle(
            padding: EdgeInsets.all(16.0),
            actionsPadding: EdgeInsets.only(left: 48),
          ),
      lmFeedMenuAction: defLMFeedMenuAction(commentViewData),
      profilePicture: LMFeedProfilePicture(
        style: LMFeedProfilePictureStyle(
          size: 36,
          backgroundColor: feedTheme?.primaryColor,
        ),
        fallbackText:
            _postDetailScreenHandler!.users[commentViewData.userId]!.name,
        onTap: () {
          if (_postDetailScreenHandler!
                  .users[commentViewData.userId]!.sdkClientInfo !=
              null) {
            LMFeedCore.instance.lmFeedClient.routeToProfile(
                _postDetailScreenHandler!.users[commentViewData.userId]!
                    .sdkClientInfo!.userUniqueId);
          }
        },
        imageUrl:
            _postDetailScreenHandler!.users[commentViewData.userId]!.imageUrl,
      ),
      likeButton: defCommentLikeButton(commentViewData),
      replyButton: defCommentReplyButton(commentViewData),
      showRepliesButton: defCommentShowRepliesButton(commentViewData),
      onTagTap: (String userId) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(userId);
      },
    );
  }

  LMFeedButton defCommentLikeButton(LMCommentViewData commentViewData) {
    return LMFeedButton(
      style: feedTheme?.commentStyle.likeButtonStyle?.copyWith(
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
                color: feedTheme?.primaryColor,
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
          textStyle: TextStyle(color: feedTheme?.primaryColor, fontSize: 12),
        ),
      ),
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
      style: feedTheme?.commentStyle.replyButtonStyle ??
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
              ..commentActionType(LMFeedCommentActionType.replying)
              ..level(0)
              ..user(_postDetailScreenHandler!.users[commentViewData.userId]!)
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
            color: feedTheme?.primaryColor,
          ),
        ),
      ),
      style: feedTheme?.commentStyle.showRepliesButtonStyle,
    );
  }

  Widget defBottomTextField() {
    return SafeArea(
      child: BlocBuilder<LMFeedCommentHandlerBloc, LMFeedCommentHandlerState>(
        bloc: _postDetailScreenHandler!.commentHandlerBloc,
        builder: (context, state) => Container(
          decoration: BoxDecoration(
            color: LikeMindsTheme.whiteColor,
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
                                ? "Editing ${state.commentMetaData.replyId != null ? 'reply' : 'comment'}"
                                : "Replying to",
                            style: const LMFeedTextStyle(
                              textStyle: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: LikeMindsTheme.greyColor,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
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
                    color: feedTheme?.primaryColor.withOpacity(0.04),
                    borderRadius: BorderRadius.circular(24)),
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.all(6.0),
                child: Row(
                  children: [
                    LMFeedProfilePicture(
                      fallbackText: currentUser.name,
                      imageUrl: currentUser.imageUrl,
                      style: LMFeedProfilePictureStyle(
                        backgroundColor: feedTheme?.primaryColor,
                        size: 36,
                      ),
                      onTap: () {
                        if (currentUser.sdkClientInfo != null) {
                          LMFeedCore.instance.lmFeedClient.routeToProfile(
                              currentUser.sdkClientInfo!.userUniqueId);
                        }
                      },
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: LMTaggingAheadTextField(
                        isDown: false,
                        maxLines: 5,
                        onTagSelected: (tag) {
                          userTags.add(tag);
                        },
                        controller: _postDetailScreenHandler!.commentController,
                        decoration:
                            feedTheme?.textFieldStyle.decoration?.copyWith(
                          enabled: right,
                          hintText: right
                              ? 'Write a comment'
                              : "You do not have permission to comment.",
                        ),
                        focusNode: _postDetailScreenHandler!.focusNode,
                        onChange: (String p0) {},
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: !right
                          ? null
                          : state is LMFeedCommentLoadingState
                              ? LMFeedLoader(
                                  color: feedTheme?.primaryColor,
                                )
                              : LMFeedButton(
                                  style: const LMFeedButtonStyle(
                                    height: 18,
                                  ),
                                  text: LMFeedText(
                                    text: "Post",
                                    style: LMFeedTextStyle(
                                      textAlign: TextAlign.center,
                                      textStyle: TextStyle(
                                        fontSize: 13,
                                        color: feedTheme?.primaryColor,
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
                                    );
                                    commentText = commentText.trim();
                                    if (commentText.isEmpty) {
                                      toast("Please write something to post");

                                      return;
                                    }

                                    _postDetailScreenHandler!.users.putIfAbsent(
                                        currentUser.userUniqueId,
                                        () => currentUser);

                                    if (state
                                        is LMFeedCommentActionOngoingState) {
                                      if (state.commentMetaData
                                              .commentActionType ==
                                          LMFeedCommentActionType.edit) {
                                        LMCommentMetaData commentMetaData =
                                            (LMCommentMetaDataBuilder()
                                                  ..commentActionEntity(
                                                      LMFeedCommentType.parent)
                                                  ..level(0)
                                                  ..commentId(state
                                                      .commentMetaData
                                                      .commentId!)
                                                  ..commentActionType(
                                                      LMFeedCommentActionType
                                                          .edit))
                                                .build();
                                        EditCommentRequest editCommentRequest =
                                            (EditCommentRequestBuilder()
                                                  ..postId(widget.postId)
                                                  ..commentId(state
                                                      .commentMetaData
                                                      .commentId!)
                                                  ..text(commentText))
                                                .build();

                                        _postDetailScreenHandler!
                                            .commentHandlerBloc
                                            .add(LMFeedCommentActionEvent(
                                                commentActionRequest:
                                                    editCommentRequest,
                                                commentMetaData:
                                                    commentMetaData));
                                      } else if (state.commentMetaData
                                              .commentActionType ==
                                          LMFeedCommentActionType.replying) {
                                        LMCommentMetaData commentMetaData =
                                            (LMCommentMetaDataBuilder()
                                                  ..commentActionEntity(
                                                      LMFeedCommentType.reply)
                                                  ..level(0)
                                                  ..commentId(state
                                                      .commentMetaData
                                                      .commentId!)
                                                  ..commentActionType(
                                                      LMFeedCommentActionType
                                                          .replying))
                                                .build();
                                        AddCommentReplyRequest addReplyRequest =
                                            (AddCommentReplyRequestBuilder()
                                                  ..postId(widget.postId)
                                                  ..text(commentText)
                                                  ..commentId(state
                                                      .commentMetaData
                                                      .commentId!))
                                                .build();

                                        _postDetailScreenHandler!
                                            .commentHandlerBloc
                                            .add(LMFeedCommentActionEvent(
                                                commentActionRequest:
                                                    addReplyRequest,
                                                commentMetaData:
                                                    commentMetaData));
                                      }
                                    } else {
                                      LMCommentMetaData commentMetaData =
                                          (LMCommentMetaDataBuilder()
                                                ..commentActionEntity(
                                                    LMFeedCommentType.parent)
                                                ..level(0)
                                                ..commentActionType(
                                                    LMFeedCommentActionType
                                                        .add))
                                              .build();
                                      AddCommentRequest addCommentRequest =
                                          (AddCommentRequestBuilder()
                                                ..postId(widget.postId)
                                                ..text(commentText))
                                              .build();

                                      _postDetailScreenHandler!
                                          .commentHandlerBloc
                                          .add(LMFeedCommentActionEvent(
                                              commentActionRequest:
                                                  addCommentRequest,
                                              commentMetaData:
                                                  commentMetaData));
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
}
