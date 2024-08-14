import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedCommentList extends StatefulWidget {
  const LMFeedCommentList({
    super.key,
    required this.postId,
    this.commentBuilder,
    this.commentSeparatorBuilder,
    this.widgetSource = LMFeedWidgetSource.postDetailScreen,
    this.noItemsFoundIndicatorBuilder,
    this.firstPageProgressIndicatorBuilder,
    this.newPageProgressIndicatorBuilder,
    this.noMoreItemsIndicatorBuilder,
    this.newPageErrorIndicatorBuilder,
    this.firstPageErrorIndicatorBuilder,
  });

  final String postId;

  /// {@macro post_comment_builder}
  final LMFeedPostCommentBuilder? commentBuilder;

  /// Builder for comment separator
  final Widget Function(BuildContext)? commentSeparatorBuilder;
  final LMFeedWidgetSource widgetSource;

  /// Builder for empty feed view
  final LMFeedContextWidgetBuilder? noItemsFoundIndicatorBuilder;

  /// Builder for first page loader when no post are there
  final LMFeedContextWidgetBuilder? firstPageProgressIndicatorBuilder;

  /// Builder for pagination loader when more post are there
  final LMFeedContextWidgetBuilder? newPageProgressIndicatorBuilder;

  /// Builder for widget when no more post are there
  final LMFeedContextWidgetBuilder? noMoreItemsIndicatorBuilder;

  /// Builder for error view while loading a new page
  final LMFeedContextWidgetBuilder? newPageErrorIndicatorBuilder;
  // Builder for error view while loading the first page
  final LMFeedContextWidgetBuilder? firstPageErrorIndicatorBuilder;

  @override
  State<LMFeedCommentList> createState() => _LMFeedCommentListState();
}

class _LMFeedCommentListState extends State<LMFeedCommentList> {
  final LMFeedThemeData feedTheme = LMFeedCore.theme;
  final LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.postDetailScreen;
  final LMFeedWidgetUtility _widgetBuilder = LMFeedCore.widgetUtility;
  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);
  List<String> showReplyCommentIds = [];
  final LMFeedCommentBloc _commentBloc = LMFeedCommentBloc.instance();
  final LMFeedPostBloc _postBloc = LMFeedPostBloc.instance;
  final PagingController<int, LMCommentViewData> _commentListPagingController =
      PagingController(firstPageKey: 1);
  LMPostViewData? _postViewData;
  final _pageSize = 10;

  @override
  void initState() {
    super.initState();

    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.commentListOpen,
        widgetSource: LMFeedWidgetSource.postDetailScreen,
        eventProperties: {
          'postId': widget.postId,
        },
      ),
    );
    _addPaginationListener();
  }

  void _addPaginationListener() {
    _commentListPagingController.addPageRequestListener(
      (pageKey) {
        _commentBloc.add(
          LMFeedGetCommentsEvent(
            postId: widget.postId,
            page: pageKey,
            pageSize: _pageSize,
          ),
        );
      },
    );
  }

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(LMFeedGetCommentSuccessState state) {
    _postViewData = state.post;
    final isLastPage = state.comments.length < _pageSize;
    if (isLastPage) {
      _commentListPagingController.appendLastPage(state.comments);
    } else {
      _commentListPagingController.appendPage(state.comments, state.page + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LMFeedCommentBloc, LMFeedCommentState>(
        bloc: _commentBloc,
        listener: _handleBlocListeners,
        buildWhen: _handleBuildWhen,
        builder: (context, state) {
          return PagedSliverList.separated(
            pagingController: _commentListPagingController,
            builderDelegate: PagedChildBuilderDelegate<LMCommentViewData>(
              firstPageProgressIndicatorBuilder:
                  widget.firstPageProgressIndicatorBuilder ??
                      (context) {
                        return const Padding(
                          padding: EdgeInsets.only(top: 150.0),
                          child: LMFeedLoader(),
                        );
                      },
              newPageProgressIndicatorBuilder:
                  widget.newPageProgressIndicatorBuilder ??
                      (context) {
                        return _widgetBuilder
                            .newPageProgressIndicatorBuilderFeed(context);
                      },
              noItemsFoundIndicatorBuilder:
                  widget.noItemsFoundIndicatorBuilder ??
                      (context) => const LMFeedEmptyCommentWidget(),
              noMoreItemsIndicatorBuilder: widget.noMoreItemsIndicatorBuilder ??
                  (context) => SizedBox.shrink(),
              newPageErrorIndicatorBuilder: widget
                      .newPageErrorIndicatorBuilder ??
                  (context) =>
                      _widgetBuilder.newPageErrorIndicatorBuilderFeed(context),
              firstPageErrorIndicatorBuilder:
                  widget.firstPageErrorIndicatorBuilder ??
                      (context) => _widgetBuilder
                          .firstPageErrorIndicatorBuilderFeed(context),
              itemBuilder: (context, commentViewData, index) {
                LMUserViewData userViewData;
                userViewData = commentViewData.user;

                LMFeedCommentWidget commentWidget = defCommentTile(
                    commentViewData, index, userViewData, context);

                return SizedBox(
                  child: Column(
                    children: [
                      widget.commentBuilder
                              ?.call(context, commentWidget, _postViewData!) ??
                          _widgetBuilder.commentBuilder
                              .call(context, commentWidget, _postViewData!),
                      LMFeedCommentReplyWidget(
                        commentBuilder: widget.commentBuilder ??
                            LMFeedCore.widgetUtility.commentBuilder,
                        post: _postViewData!,
                        postId: widget.postId,
                        comment: commentViewData,
                        user: userViewData,
                      )
                    ],
                  ),
                );
              },
            ),
            separatorBuilder: (context, index) =>
                widget.commentSeparatorBuilder?.call(context) ??
                const Divider(
                  thickness: 0.2,
                  height: 0,
                ),
          );
        });
  }

  bool _handleBuildWhen(previous, current) {
    if (current is LMFeedAddCommentSuccessState ||
        current is LMFeedAddCommentErrorState ||
        current is LMFeedEditCommentSuccessState ||
        current is LMFeedEditCommentErrorState ||
        current is LMFeedDeleteCommentSuccessState ||
        current is LMFeedDeleteCommentErrorState ||
        current is LMFeedReplyCommentSuccessState ||
        current is LMFeedDeleteReplySuccessState ||
        current is LMFeedGetCommentSuccessState ||
        current is LMFeedGetReplyCommentLoadingState ||
        current is LMFeedCloseReplyState) {
      return true;
    }
    return false;
  }

  void _handleBlocListeners(context, state) {
    debugPrint('CommentListBlocListener: $state');
    if (state is LMFeedCommentRefreshState) {
      showReplyCommentIds.clear();
      _commentListPagingController.value.itemList?.clear();
      _commentListPagingController.refresh();
    }
    if (state is LMFeedReplyCommentSuccessState) {
      if (state.reply.tempId != state.reply.id) {
        return;
      }
      int? index = _commentListPagingController.value.itemList?.indexWhere(
          (element) => element.id == state.reply.parentComment?.id);
      if (index != null && index != -1) {
        int replyCount =
            _commentListPagingController.itemList?[index].repliesCount ?? 0;
        _commentListPagingController.itemList?[index].repliesCount =
            replyCount + 1;
        showReplyCommentIds.add(state.reply.parentComment!.id);
      }
    } else if (state is LMFeedReplyCommentErrorState) {
      final int? index = _commentListPagingController.value.itemList
          ?.indexWhere((element) => element.id == state.commentId);
      if (index != null && index != -1) {
        int replyCount =
            _commentListPagingController.itemList?[index].repliesCount ?? 0;
        _commentListPagingController.itemList?[index].repliesCount =
            replyCount - 1;
      }
    } else if (state is LMFeedDeleteReplySuccessState) {
      int? index = _commentListPagingController.value.itemList
          ?.indexWhere((element) => element.id == state.commentId);
      if (index != null && index != -1) {
        int replyCount =
            _commentListPagingController.itemList?[index].repliesCount ?? 0;
        _commentListPagingController.itemList?[index].repliesCount =
            replyCount - 1;
      }
      LMFeedCore.showSnackBar(
        context,
        '$commentTitleSmallCapSingular Deleted',
        _widgetSource,
      );
    } else if (state is LMFeedDeleteCommentErrorState) {
      _commentListPagingController.value.itemList
          ?.insert(state.index, state.oldComment);
      LMFeedCore.showSnackBar(
        context,
        state.error,
        _widgetSource,
      );
    } else if (state is LMFeedGetCommentSuccessState) {
      updatePagingControllers(state);
    } else if (state is LMFeedAddCommentSuccessState) {
      final LMCommentViewData commentViewData = state.comment;
      if (commentViewData.tempId == commentViewData.id) {
        _commentListPagingController.value.itemList?.insert(0, state.comment);
        _postBloc.add(LMFeedUpdatePostEvent(
          postId: widget.postId,
          source: LMFeedWidgetSource.postDetailScreen,
          actionType: LMFeedPostActionType.commentAdded,
        ));
      } else {
        final int? index = _commentListPagingController.value.itemList
            ?.indexWhere((element) => element.id == commentViewData.tempId);
        if (index != null && index != -1) {
          _commentListPagingController.value.itemList![index] = commentViewData;
        }
      }
    } else if (state is LMFeedAddCommentErrorState) {
      final int? index = _commentListPagingController.value.itemList
          ?.indexWhere((element) => element.id == state.commentId);
      if (index != null && index != -1) {
        _commentListPagingController.value.itemList!.removeAt(index);
      }
      LMFeedCore.showSnackBar(
        context,
        state.error,
        widget.widgetSource,
      );
    } else if (state is LMFeedEditCommentSuccessState) {
      final int? index = _commentListPagingController.value.itemList
          ?.indexWhere((comment) => comment.id == state.commentViewData.id);
      if (index != null && index != -1) {
        _commentListPagingController.value.itemList![index] =
            state.commentViewData;
      }
    } else if (state is LMFeedEditCommentErrorState) {
      final int? index = _commentListPagingController.value.itemList
          ?.indexWhere((comment) => comment.id == state.oldComment.id);
      if (index != null && index != -1) {
        _commentListPagingController.value.itemList![index] = state.oldComment;
      }
    } else if (state is LMFeedDeleteCommentSuccessState) {
      _commentListPagingController.value.itemList
          ?.removeWhere((element) => element.id == state.commentId);
      _postBloc.add(LMFeedUpdatePostEvent(
        postId: widget.postId,
        source: LMFeedWidgetSource.postDetailScreen,
        actionType: LMFeedPostActionType.commentDeleted,
      ));
      LMFeedCore.showSnackBar(
        context,
        '$commentTitleSmallCapSingular Deleted',
        _widgetSource,
      );
    } else if (state is LMFeedGetReplyCommentLoadingState) {
      showReplyCommentIds.add(state.commentId);
    } else if (state is LMFeedCloseReplyState) {
      showReplyCommentIds.remove(state.commentId);
    }
  }

  LMFeedCommentWidget defCommentTile(LMCommentViewData commentViewData,
      int index, LMUserViewData userViewData, BuildContext context) {
    return LMFeedCommentWidget(
      user: userViewData,
      comment: commentViewData,
      menu: (menu) => LMFeedMenu(
        menuItems: commentViewData.menuItems,
        removeItemIds: {},
        action: defLMFeedMenuAction(commentViewData, index),
        onMenuOpen: () {
          LMFeedCommentUtils.handleCommentMenuOpenTap(
              _postViewData!,
              commentViewData,
              _widgetSource,
              commentViewData.level == 0
                  ? LMFeedAnalyticsKeys.commentMenu
                  : LMFeedAnalyticsKeys.replyMenu);
        },
      ),
      onProfileNameTap: () => LMFeedCommentUtils.handleCommentProfileTap(
          context,
          _postViewData!,
          commentViewData,
          LMFeedAnalyticsKeys.commentProfileName,
          _widgetSource),
      style: feedTheme.commentStyle,
      lmFeedMenuAction: defLMFeedMenuAction(commentViewData, index),
      profilePicture: LMFeedProfilePicture(
        style: LMFeedProfilePictureStyle(
          size: 36,
          backgroundColor: feedTheme.primaryColor,
        ),
        fallbackText: userViewData.name,
        onTap: () => LMFeedCommentUtils.handleCommentProfileTap(
            context,
            _postViewData!,
            commentViewData,
            LMFeedAnalyticsKeys.commentProfilePicture,
            _widgetSource),
        imageUrl: userViewData.imageUrl,
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
        LMFeedVideoProvider.instance.pauseCurrentVideo();
        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedLikesScreen(
              postId: _postViewData!.id,
              commentId: commentViewData.id,
              widgetSource: _widgetSource,
            ),
          ),
        );
      },
      onTap: () async {
        LMPostViewData postViewData = _postViewData!;

        commentViewData.likesCount = commentViewData.isLiked
            ? commentViewData.likesCount - 1
            : commentViewData.likesCount + 1;
        commentViewData.isLiked = !commentViewData.isLiked;
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
        _commentBloc.add(
          LMFeedReplyingCommentEvent(
            postId: widget.postId,
            parentComment: commentViewData,
            userName: commentViewData.user.name,
          ),
        );
      },
    );
  }

  LMFeedButton defCommentShowRepliesButton(LMCommentViewData commentViewData) {
    return LMFeedButton(
      onTap: () {
        bool isReplyShown = showReplyCommentIds.contains(commentViewData.id);
        isReplyShown
            ? _commentBloc
                .add(LMFeedCloseReplyEvent(commentId: commentViewData.id))
            : _commentBloc.add(
                LMFeedGetReplyEvent(
                  postId: widget.postId,
                  commentId: commentViewData.id,
                  page: 1,
                  pageSize: 10,
                ),
              );
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

  LMFeedMenuAction defLMFeedMenuAction(
          LMCommentViewData commentViewData, int index) =>
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
          _commentBloc.add(
            LMFeedEditingCommentEvent(
              postId: widget.postId,
              oldComment: commentViewData,
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
                _commentBloc.add(LMFeedDeleteCommentEvent(
                  postId: widget.postId,
                  oldComment: commentViewData,
                  reason: reason.isEmpty ? "Reason for deletion" : reason,
                  index: index,
                ));
              },
              actionText: 'Delete',
            ),
          );
        },
      );
}