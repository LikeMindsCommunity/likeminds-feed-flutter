import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/handler/post_detail_screen_handler.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/comment_reply_widget.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/default_empty_comment_widget.dart';

class LMFeedCommentList extends StatefulWidget {
  const LMFeedCommentList({
    super.key,
    required this.postId,
    required this.postDetailScreenHandler,
    this.commentBuilder,
    this.commentSeparatorBuilder,
  });

  final String postId;
  final LMFeedPostDetailScreenHandler postDetailScreenHandler;

  /// {@macro post_comment_builder}
  final LMFeedPostCommentBuilder? commentBuilder;
  final Widget Function(BuildContext)? commentSeparatorBuilder;

  @override
  State<LMFeedCommentList> createState() => _LMFeedCommentListState();
}

class _LMFeedCommentListState extends State<LMFeedCommentList> {
  ValueNotifier<bool> _rebuildComment = ValueNotifier(false);
  final LMFeedThemeData feedTheme = LMFeedCore.theme;
  final LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.postDetailScreen;
  final LMFeedWidgetUtility _widgetBuilder = LMFeedCore.widgetUtility;
  LMFeedPostDetailScreenHandler? _postDetailScreenHandler;
  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);
  String? commentIdReplyId;
  bool replyShown = false;
  final LMFeedFetchCommentReplyBloc _commentRepliesBloc =
      LMFeedFetchCommentReplyBloc.instance;

  @override
  void initState() {
    super.initState();
    _postDetailScreenHandler = widget.postDetailScreenHandler;
  }

  @override
  void didUpdateWidget(covariant LMFeedCommentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _postDetailScreenHandler = widget.postDetailScreenHandler;
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LMFeedCommentBloc, LMFeedCommentHandlerState>(
      bloc: _postDetailScreenHandler!.commentHandlerBloc,
      listener: (context, state) {
        _postDetailScreenHandler!.handleBlocChanges(context, state);
      },
      child: PagedSliverList.separated(
        pagingController: _postDetailScreenHandler!.commentListPagingController,
        builderDelegate: PagedChildBuilderDelegate<LMCommentViewData>(
          firstPageProgressIndicatorBuilder: (context) {
            return const Padding(
              padding: EdgeInsets.only(top: 150.0),
              child: LMFeedLoader(),
            );
          },
          newPageProgressIndicatorBuilder: (context) {
            return _widgetBuilder.newPageProgressIndicatorBuilderFeed(context);
          },
          noItemsFoundIndicatorBuilder: (context) =>
              const LMFeedEmptyCommentWidget(),
          itemBuilder: (context, commentViewData, index) {
            LMUserViewData userViewData;
            if (!_postDetailScreenHandler!.users
                .containsKey(commentViewData.uuid)) {
              return const SizedBox.shrink();
            }
            userViewData =
                _postDetailScreenHandler!.users[commentViewData.uuid]!;

            LMFeedCommentWidget commentWidget =
                defCommentTile(commentViewData, userViewData, context);

            return ValueListenableBuilder(
                valueListenable: _rebuildComment,
                builder: (context, _, __) {
                  return SizedBox(
                    child: Column(
                      children: [
                        widget.commentBuilder?.call(context, commentWidget,
                                _postDetailScreenHandler!.postData!) ??
                            _widgetBuilder.commentBuilder.call(
                                context,
                                commentWidget,
                                _postDetailScreenHandler!.postData!),
                        (replyShown && commentIdReplyId == commentViewData.id)
                            ? LMFeedCommentReplyWidget(
                                post: _postDetailScreenHandler!.postData!,
                                commentBuilder: widget.commentBuilder ??
                                    LMFeedCore.widgetUtility.commentBuilder,
                                refresh: () {
                                  //  _postDetailScreenHandler _pagingController.refresh();
                                },
                                postId: widget.postId,
                                reply: commentViewData,
                                user: _postDetailScreenHandler!
                                    .users[commentViewData.uuid]!,
                              )
                            : const SizedBox.shrink()
                      ],
                    ),
                  );
                });
          },
        ),
        separatorBuilder: (context, index) =>
            widget.commentSeparatorBuilder?.call(context) ??
            const Divider(
              thickness: 0.2,
              height: 0,
            ),
      ),
    );
  }

  LMFeedCommentWidget defCommentTile(LMCommentViewData commentViewData,
      LMUserViewData userViewData, BuildContext context) {
    return LMFeedCommentWidget(
      user: userViewData,
      comment: commentViewData,
      menu: (menu) => LMFeedMenu(
        menuItems: commentViewData.menuItems,
        removeItemIds: {},
        action: defLMFeedMenuAction(commentViewData),
        onMenuOpen: () {
          LMFeedCommentUtils.handleCommentMenuOpenTap(
              _postDetailScreenHandler!.postData!,
              commentViewData,
              _widgetSource,
              commentViewData.level == 0
                  ? LMFeedAnalyticsKeys.commentMenu
                  : LMFeedAnalyticsKeys.replyMenu);
        },
      ),
      onProfileNameTap: () => LMFeedCommentUtils.handleCommentProfileTap(
          context,
          _postDetailScreenHandler!.postData!,
          commentViewData,
          LMFeedAnalyticsKeys.commentProfileName,
          _widgetSource),
      style: feedTheme.commentStyle,
      lmFeedMenuAction: defLMFeedMenuAction(commentViewData),
      profilePicture: LMFeedProfilePicture(
        style: LMFeedProfilePictureStyle(
          size: 36,
          backgroundColor: feedTheme.primaryColor,
        ),
        fallbackText:
            _postDetailScreenHandler!.users[commentViewData.uuid]!.name,
        onTap: () => LMFeedCommentUtils.handleCommentProfileTap(
            context,
            _postDetailScreenHandler!.postData!,
            commentViewData,
            LMFeedAnalyticsKeys.commentProfilePicture,
            _widgetSource),
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
        style: LMFeedTextStyle(
          textStyle: TextStyle(fontSize: 12, color: feedTheme.inActiveColor),
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
              widgetSource: _widgetSource,
            ),
          ),
        );
      },
      onTap: () async {
        LMPostViewData postViewData = _postDetailScreenHandler!.postData!;

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
        } else {
          LMFeedCommentUtils.handleCommentLikeTapEvent(postViewData,
              _widgetSource, commentViewData, commentViewData.isLiked);
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
      text: LMFeedText(
        text: "Reply",
        style: LMFeedTextStyle(
            textStyle: TextStyle(fontSize: 12, color: feedTheme.inActiveColor)),
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

  LMFeedMenuAction defLMFeedMenuAction(LMCommentViewData commentViewData) =>
      LMFeedMenuAction(
        onCommentReport: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => LMFeedReportScreen(
                entityId: commentViewData.id,
                entityType: commentEntityId,
                entityCreatorId: commentViewData.user.uuid,
              ),
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
              widgetSource: _widgetSource,
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
}
