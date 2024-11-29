import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/configurations/builder.dart';

/// {@template lm_feed_comment_list}
/// A widget that displays a list of comments for a specific post.
///
/// The `LMFeedCommentList` widget is responsible for rendering comments associated
/// with a particular post. It provides various customization options through
/// builder functions to tailor the appearance and behavior of the comment list.
///
/// {@endtemplate}
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
    this.replyWidgetBuilder,
  });

  /// The ID of the post for which the comments are being displayed.
  final String postId;

  /// {@macro post_comment_builder}
  final LMFeedPostCommentBuilder? commentBuilder;

  /// Builder for comment separator
  final Widget Function(BuildContext)? commentSeparatorBuilder;

  /// Defines the source of caller of this class
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

  /// Builder for error view while loading the first page
  final LMFeedContextWidgetBuilder? firstPageErrorIndicatorBuilder;

  /// Builder for reply widget
  final LMFeedReplyWidgetBuilder? replyWidgetBuilder;

  /// {@template comment_list_widget_copy_with}
  /// Creates a copy of this `LMFeedCommentList` instance with the given fields
  /// replaced with new values.
  ///
  /// If a field is not provided, the current value of that field in the
  /// instance will be used.
  ///
  /// Returns:
  /// A new `LMFeedCommentList` instance with the updated values.
  /// {@endtemplate}
  LMFeedCommentList copyWith({
    String? postId,
    LMFeedPostCommentBuilder? commentBuilder,
    Widget Function(BuildContext)? commentSeparatorBuilder,
    LMFeedWidgetSource? widgetSource,
    LMFeedContextWidgetBuilder? noItemsFoundIndicatorBuilder,
    LMFeedContextWidgetBuilder? firstPageProgressIndicatorBuilder,
    LMFeedContextWidgetBuilder? newPageProgressIndicatorBuilder,
    LMFeedContextWidgetBuilder? noMoreItemsIndicatorBuilder,
    LMFeedContextWidgetBuilder? newPageErrorIndicatorBuilder,
    LMFeedContextWidgetBuilder? firstPageErrorIndicatorBuilder,
    LMFeedReplyWidgetBuilder? replyWidgetBuilder,
  }) {
    return LMFeedCommentList(
      postId: postId ?? this.postId,
      commentBuilder: commentBuilder ?? this.commentBuilder,
      commentSeparatorBuilder:
          commentSeparatorBuilder ?? this.commentSeparatorBuilder,
      widgetSource: widgetSource ?? this.widgetSource,
      noItemsFoundIndicatorBuilder:
          noItemsFoundIndicatorBuilder ?? this.noItemsFoundIndicatorBuilder,
      firstPageProgressIndicatorBuilder: firstPageProgressIndicatorBuilder ??
          this.firstPageProgressIndicatorBuilder,
      newPageProgressIndicatorBuilder: newPageProgressIndicatorBuilder ??
          this.newPageProgressIndicatorBuilder,
      noMoreItemsIndicatorBuilder:
          noMoreItemsIndicatorBuilder ?? this.noMoreItemsIndicatorBuilder,
      newPageErrorIndicatorBuilder:
          newPageErrorIndicatorBuilder ?? this.newPageErrorIndicatorBuilder,
      firstPageErrorIndicatorBuilder:
          firstPageErrorIndicatorBuilder ?? this.firstPageErrorIndicatorBuilder,
      replyWidgetBuilder: replyWidgetBuilder ?? this.replyWidgetBuilder,
    );
  }

  @override
  State<LMFeedCommentList> createState() => _LMFeedCommentListState();
}

class _LMFeedCommentListState extends State<LMFeedCommentList> {
  final LMFeedThemeData feedTheme = LMFeedCore.theme;
  final LMFeedWidgetSource _widgetSource = LMFeedWidgetSource.postDetailScreen;
  final LMFeedPostDetailScreenBuilderDelegate _widgetBuilder = LMFeedCore.config.postDetailScreenConfig.builder;
  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);
  Set<String> showReplyCommentIds = {};
  final LMFeedCommentBloc _commentBloc = LMFeedCommentBloc.instance;
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
                return SizedBox(
                  child: Column(
                    children: [
                      StatefulBuilder(
                        builder: (context, setReplyState) {
                          return widget.commentBuilder?.call(
                                  context,
                                  defCommentTile(
                                    commentViewData,
                                    index,
                                    userViewData,
                                    context,
                                    setReplyState,
                                  ),
                                  _postViewData!) ??
                              _widgetBuilder.commentBuilder.call(
                                  context,
                                  defCommentTile(
                                    commentViewData,
                                    index,
                                    userViewData,
                                    context,
                                    setReplyState,
                                  ),
                                  _postViewData!);
                        },
                      ),
                      widget.replyWidgetBuilder?.call(
                              context,
                              _defCommentReplyWidget(
                                  commentViewData, userViewData)) ??
                          _defCommentReplyWidget(commentViewData, userViewData)
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

  LMFeedCommentReplyWidget _defCommentReplyWidget(
      LMCommentViewData commentViewData, LMUserViewData userViewData) {
    return LMFeedCommentReplyWidget(
      commentBuilder:
          widget.commentBuilder ?? LMFeedCore.config.widgetBuilderDelegate.commentBuilder,
      post: _postViewData!,
      postId: widget.postId,
      comment: commentViewData,
      user: userViewData,
    );
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

  LMFeedCommentWidget defCommentTile(
    LMCommentViewData commentViewData,
    int index,
    LMUserViewData userViewData,
    BuildContext context,
    StateSetter setReplyState,
  ) {
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
      likeButton: defCommentLikeButton(commentViewData, setReplyState),
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

  LMFeedButton defCommentLikeButton(
    LMCommentViewData commentViewData,
    StateSetter setReplyState,
  ) {
    bool showText = commentViewData.likesCount == 0 ? false : true;
    final LMFeedButton likeButton = LMFeedButton(
      style: feedTheme.commentStyle.likeButtonStyle?.copyWith(
            showText: showText,
            gap: showText ? feedTheme.commentStyle.likeButtonStyle?.gap : 0,
          ) ??
          LMFeedButtonStyle(
            gap: showText ? 4 : 0,
            showText: showText,
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
      isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
      text: LMFeedText(
        text: LMFeedPostUtils.getLikeCountTextWithCount(
            commentViewData.likesCount),
        style: LMFeedTextStyle(
          textStyle: TextStyle(fontSize: 12, color: feedTheme.inActiveColor),
        ),
      ),
      onTextTap: () {
        if (commentViewData.likesCount == 0) {
          return;
        }
        // check if the user is a guest user
        if (LMFeedUserUtils.isGuestUser()) {
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
          return;
        }
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
        // check if the user is a guest user
        if (LMFeedUserUtils.isGuestUser()) {
          LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
          return;
        }
        LMPostViewData postViewData = _postViewData!;

        commentViewData.likesCount = commentViewData.isLiked
            ? commentViewData.likesCount - 1
            : commentViewData.likesCount + 1;
        setReplyState(() {});
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
          setReplyState(() {});
        } else {
          LMFeedCommentUtils.handleCommentLikeTapEvent(postViewData,
              _widgetSource, commentViewData, commentViewData.isLiked);
        }
      },
      isActive: commentViewData.isLiked,
    );

    return LMFeedCore.config.feedThemeType == LMFeedThemeType.qna
        ? likeButton.copyWith(
            style: likeButton.style?.copyWith(
              gap: likeButton.style?.showText == true ? 4 : 0,
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmUpvoteSvg,
                style: LMFeedIconStyle.basic().copyWith(
                  size: 24,
                ),
              ),
              activeIcon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmUpvoteFilledSvg,
                style: LMFeedIconStyle.basic().copyWith(
                  size: 24,
                ),
              ),
            ),
          )
        : likeButton;
  }

  LMFeedButton defCommentReplyButton(LMCommentViewData commentViewData) {
    return LMFeedButton(
      style: feedTheme.commentStyle.replyButtonStyle ??
          const LMFeedButtonStyle(
            gap: 10,
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
    bool isReplyShown = showReplyCommentIds.contains(commentViewData.id);
    return LMFeedButton(
      onTap: () {
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
      isActive: isReplyShown,
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
          // check if the user is a guest user
          if (LMFeedUserUtils.isGuestUser()) {
            LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call(context);
            return;
          }
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
