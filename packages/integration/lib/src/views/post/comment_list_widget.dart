import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/bloc/lm_comment_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/default_empty_comment_widget.dart';
import 'package:likeminds_feed_flutter_core/src/widgets/post/comment/tmp_comment_reply_widget.dart';

class LMFeedCommentList extends StatefulWidget {
  const LMFeedCommentList({
    super.key,
    required this.postId,
    this.commentBuilder,
    this.commentSeparatorBuilder,
  });

  final String postId;

  /// {@macro post_comment_builder}
  final LMFeedPostCommentBuilder? commentBuilder;
  final Widget Function(BuildContext)? commentSeparatorBuilder;

  @override
  State<LMFeedCommentList> createState() => _LMFeedCommentListState();
}

class _LMFeedCommentListState extends State<LMFeedCommentList> {
  ValueNotifier<bool> _rebuildComment = ValueNotifier(false);
  ValueNotifier<bool> _rebuildCommentList = ValueNotifier(false);
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
  final LMCommentBloc _commentBloc = LMCommentBloc.instance();
  final LMFeedPostBloc _postBloc = LMFeedPostBloc.instance;
  final PagingController<int, LMCommentViewData> _commentListPagingController =
      PagingController(firstPageKey: 1);
  LMPostViewData? _postViewData;
  final _pageSize = 10;

  @override
  void initState() {
    super.initState();
    _addPaginationListener();
  }

  @override
  void didUpdateWidget(covariant LMFeedCommentList oldWidget) {
    super.didUpdateWidget(oldWidget);
    _addPaginationListener();
  }

  void _addPaginationListener() {
    _commentListPagingController.addPageRequestListener(
      (pageKey) {
        _commentBloc.add(
          LMGetCommentsEvent(
            postId: widget.postId,
            page: pageKey,
            commentListPageSize: _pageSize,
          ),
        );
      },
    );
  }

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(LMCommentState state) {
    if (state is LMGetCommentSuccess) {
      _postViewData = state.post;
      final isLastPage = state.comments.length < _pageSize;
      if (isLastPage) {
        _commentListPagingController.appendLastPage(state.comments);
      } else {
        _commentListPagingController.appendPage(state.comments, state.page + 1);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LMCommentBloc, LMCommentState>(
        bloc: _commentBloc,
        listener: _handleBlocListeners,
        buildWhen: (previous, current) {
          if (current is LMAddCommentSuccess ||
              current is LMEditCommentSuccess ||
              current is LMDeleteCommentSuccess ||
              current is LMReplyCommentSuccess ||
              current is LMDeleteReplySuccess ||
              current is LMGetCommentSuccess ||
              current is LMGetReplyCommentLoading ||
              current is LMCloseReplyState) {
            return true;
          }
          return false;
        },
        builder: (context, state) {
          return ValueListenableBuilder(
              valueListenable: _rebuildCommentList,
              builder: (context, _, __) {
                return PagedSliverList.separated(
                  pagingController: _commentListPagingController,
                  builderDelegate: PagedChildBuilderDelegate<LMCommentViewData>(
                    firstPageProgressIndicatorBuilder: (context) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 150.0),
                        child: LMFeedLoader(),
                      );
                    },
                    newPageProgressIndicatorBuilder: (context) {
                      return _widgetBuilder
                          .newPageProgressIndicatorBuilderFeed(context);
                    },
                    noItemsFoundIndicatorBuilder: (context) =>
                        const LMFeedEmptyCommentWidget(),
                    itemBuilder: (context, commentViewData, index) {
                      LMUserViewData userViewData;
                      userViewData = commentViewData.user;

                      LMFeedCommentWidget commentWidget = defCommentTile(
                          commentViewData, userViewData, context);

                      return ValueListenableBuilder(
                          valueListenable: _rebuildComment,
                          builder: (context, _, __) {
                            return SizedBox(
                              child: Column(
                                children: [
                                  widget.commentBuilder?.call(context,
                                          commentWidget, _postViewData!) ??
                                      _widgetBuilder.commentBuilder.call(
                                          context,
                                          commentWidget,
                                          _postViewData!),
                                  // if (replyShown &&
                                  //     commentIdReplyId == commentViewData.id)
                                  TempLMFeedCommentReplyWidget(
                                    // key: ValueKey(commentViewData.id),
                                    commentBuilder: widget.commentBuilder ??
                                        LMFeedCore.widgetUtility.commentBuilder,
                                    refresh: () {
                                      //  _postDetailScreenHandler _pagingController.refresh();
                                    },
                                    post: _postViewData!,
                                    postId: widget.postId,
                                    comment: commentViewData,
                                    user: userViewData,
                                  )
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
                );
              });
        });
  }

  void _handleBlocListeners(context, state) {
    if (state is LMReplyCommentSuccess) {
      int? index = _commentListPagingController.value.itemList?.indexWhere(
          (element) => element.id == state.reply.parentComment?.id);
      if (index != null && index != -1) {
        int replyCount =
            _commentListPagingController.itemList?[index].repliesCount ?? 0;
        _commentListPagingController.itemList?[index].repliesCount =
            replyCount + 1;
      }
    } else if (state is LMDeleteReplySuccess) {
      int? index = _commentListPagingController.value.itemList
          ?.indexWhere((element) => element.id == state.commentId);
      if (index != null && index != -1) {
        int replyCount =
            _commentListPagingController.itemList?[index].repliesCount ?? 0;
        _commentListPagingController.itemList?[index].repliesCount =
            replyCount - 1;
        _rebuildCommentList.value = !_rebuildCommentList.value;
      }
      LMFeedCore.showSnackBar(
        context,
        '$commentTitleSmallCapSingular Deleted',
        _widgetSource,
      );
    } else if (state is LMGetCommentSuccess) {
      updatePagingControllers(state);
    } else if (state is LMAddCommentSuccess) {
      final LMCommentViewData commentViewData = state.comment;
      if (commentViewData.tempId == commentViewData.id) {
        _commentListPagingController.value.itemList?.insert(0, state.comment);
        _postBloc.add(LMFeedUpdatePostEvent(
          postId: widget.postId,
          source: LMFeedWidgetSource.postDetailScreen,
          actionType: LMFeedPostActionType.commentAdded,
        ));
        _rebuildCommentList.value = !_rebuildCommentList.value;
      } else {
        final int? index = _commentListPagingController.value.itemList
            ?.indexWhere((element) => element.id == commentViewData.tempId);
        if (index != null && index != -1) {
          _commentListPagingController.value.itemList![index] = commentViewData;
          _rebuildCommentList.value = !_rebuildCommentList.value;
        }
      }
    } else if (state is LMEditCommentSuccess) {
      final int? index = _commentListPagingController.value.itemList
          ?.indexWhere((comment) => comment.id == state.commentViewData.id);
      if (index != null && index != -1) {
        _commentListPagingController.value.itemList![index] =
            state.commentViewData;
        _rebuildCommentList.value = !_rebuildCommentList.value;
      }
    } else if (state is LMDeleteCommentSuccess) {
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
      _rebuildCommentList.value = !_rebuildCommentList.value;
    } else if (state is LMReplyCommentSuccess) {
      final LMCommentViewData commentViewData = state.reply;
      if (commentViewData.tempId == commentViewData.id) {
        _commentListPagingController.value.itemList?.insert(0, state.reply);
        _rebuildCommentList.value = !_rebuildCommentList.value;
      } else {
        final int? index = _commentListPagingController.value.itemList
            ?.indexWhere((element) => element.id == commentViewData.tempId);
        if (index != null && index != -1) {
          _commentListPagingController.value.itemList![index] = commentViewData;
          _rebuildCommentList.value = !_rebuildCommentList.value;
        }
      }
    } else if (state is LMGetReplyCommentLoading) {
      showReplyCommentIds.add(state.commentId);
    } else if (state is LMCloseReplyState) {
      showReplyCommentIds.remove(state.commentId);
    }
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
      lmFeedMenuAction: defLMFeedMenuAction(commentViewData),
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
        // VideoController? videoController = LMFeedVideoProvider.instance
        //     .getVideoController(_postDetailScreenHandler!.postData!.id);

        // videoController?.player.pause();

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
        // _postDetailScreenHandler!.rebuildPostWidget.value =
        //     !_postDetailScreenHandler!.rebuildPostWidget.value;

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

          // _postDetailScreenHandler!.rebuildPostWidget.value =
          //     !_postDetailScreenHandler!.rebuildPostWidget.value;
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
        // LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
        //       ..commentActionEntity(LMFeedCommentType.parent)
        //       ..postId(widget.postId)
        //       ..commentActionType(LMFeedCommentActionType.replying)
        //       ..level(0)
        //       ..user(commentViewData.user)
        //       ..commentId(commentViewData.id))
        //     .build();
        _commentBloc.add(
          LMReplyingCommentEvent(
            postId: widget.postId,
            commentId: commentViewData.id,
            userName: commentViewData.user.name,
          ),
        );
        // _postDetailScreenHandler!.commentHandlerBloc
        //     .add(LMFeedCommentOngoingEvent(
        //   commentMetaData: commentMetaData,
        // ));
      },
    );
  }

  LMFeedButton defCommentShowRepliesButton(LMCommentViewData commentViewData) {
    return LMFeedButton(
      onTap: () {
        bool isReplyShown = showReplyCommentIds.contains(commentViewData.id);
        isReplyShown
            ? _commentBloc.add(LMCloseReplyEvent(commentId: commentViewData.id))
            : _commentBloc.add(
                LMGetReplyEvent(
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
          _commentBloc.add(
            LMEditingCommentEvent(
                postId: widget.postId,
                commentId: commentViewData.id,
                replyText: commentViewData.text),
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
                _commentBloc.add(LMDeleteComment(
                  postId: widget.postId,
                  commentId: commentViewData.id,
                  reason: reason.isEmpty ? "Reason for deletion" : reason,
                ));
                // DeleteCommentRequest deleteCommentRequest =
                //     (DeleteCommentRequestBuilder()
                //           ..postId(widget.postId)
                //           ..commentId(commentViewData.id)
                //           ..reason(
                //               reason.isEmpty ? "Reason for deletion" : reason))
                //         .build();

                // LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
                //       ..commentActionEntity(LMFeedCommentType.parent)
                //       ..postId(_postViewData!.id)
                //       ..commentActionType(LMFeedCommentActionType.delete)
                //       ..level(0)
                //       ..commentId(commentViewData.id))
                //     .build();
                // _postDetailScreenHandler!
                //     .deleteCommentFromController(commentViewData.id);
                // _postDetailScreenHandler!.rebuildPostWidget.value =
                //     !_postDetailScreenHandler!.rebuildPostWidget.value;

                // _postDetailScreenHandler!.commentHandlerBloc.add(
                //     LMFeedCommentActionEvent(
                //         commentActionRequest: deleteCommentRequest,
                //         commentMetaData: commentMetaData));

                // LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
                //   postId: _postViewData!.id,
                //   commentId: commentViewData.id,
                //   actionType: LMFeedPostActionType.commentDeleted,
                //   source: LMFeedWidgetSource.postDetailScreen,
                // ));
              },
              actionText: 'Delete',
            ),
          );
        },
      );
}
