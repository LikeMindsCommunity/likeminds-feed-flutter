import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedCommentReplyWidget extends StatefulWidget {
  final String postId;
  final LMCommentViewData comment;
  final LMUserViewData user;
  final LMFeedCommentStyle? style;

  final LMFeedPostCommentBuilder? commentBuilder;

  final LMFeedLoaderBuilder? loaderBuilder;

  final LMPostViewData post;

  const LMFeedCommentReplyWidget({
    Key? key,
    required this.comment,
    required this.user,
    required this.postId,
    this.style,
    this.commentBuilder,
    required this.post,
    this.loaderBuilder,
  }) : super(key: key);

  @override
  State<LMFeedCommentReplyWidget> createState() => _CommentReplyWidgetState();

  LMFeedCommentReplyWidget copyWith({
    String? postId,
    LMCommentViewData? reply,
    LMUserViewData? user,
    LMFeedCommentStyle? style,
    LMFeedPostCommentBuilder? commentBuilder,
    LMPostViewData? post,
    LMFeedLoaderBuilder? loaderBuilder,
  }) {
    return LMFeedCommentReplyWidget(
      postId: postId ?? this.postId,
      comment: reply ?? this.comment,
      user: user ?? this.user,
      style: style ?? this.style,
      commentBuilder: commentBuilder ?? this.commentBuilder,
      post: post ?? this.post,
      loaderBuilder: loaderBuilder ?? this.loaderBuilder,
    );
  }
}

class _CommentReplyWidgetState extends State<LMFeedCommentReplyWidget> {
  final LMFeedCommentBloc _commentBloc = LMFeedCommentBloc.instance;
  ValueNotifier<bool> rebuildLikeButton = ValueNotifier(false);
  ValueNotifier<bool> rebuildReplyList = ValueNotifier(false);
  Map<String, LMUserViewData> users = {};
  final LMFeedThemeData feedTheme = LMFeedCore.theme;
  LMFeedCommentStyle? replyStyle;
  LMFeedWidgetSource widgetSource = LMFeedWidgetSource.postDetailScreen;

  String commentTitleFirstCapPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural);
  String commentTitleSmallCapPlural =
      LMFeedPostUtils.getCommentTitle(LMFeedPluralizeWordAction.allSmallPlural);
  String commentTitleFirstCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  LMCommentViewData? comment;
  late final LMUserViewData user;
  late final String postId;
  Function()? refresh;
  bool isLiked = false;
  int replyCount = 0;

  void initializeReply() {
    comment = widget.comment;
    isLiked = comment!.isLiked;
    replyCount = comment!.repliesCount;
  }

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    user = widget.user;
    initializeReply();
  }

  @override
  void didUpdateWidget(LMFeedCommentReplyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.comment != widget.comment) {
      initializeReply();
    }
  }

  int page = 1;

  @override
  Widget build(BuildContext context) {
    replyStyle = widget.style ?? feedTheme.replyStyle;
    return BlocConsumer(
      bloc: _commentBloc,
      buildWhen: _handleBuildWhen,
      builder: ((context, state) {
        if (state is LMFeedGetReplyCommentLoadingState) {
          if (state.commentId == widget.comment.id) {
            return widget.loaderBuilder?.call(context) ?? _defLoaderWidget();
          }
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              itemCount: comment?.replies?.length ?? 0,
              itemBuilder: (context, index) {
                LMCommentViewData? commentViewData = comment?.replies?[index];
                return commentViewData != null
                    ? StatefulBuilder(
                        builder: (context, setReplyState) {
                          return widget.commentBuilder?.call(
                                  context,
                                  _defCommentWidget(
                                      commentViewData, setReplyState),
                                  widget.post) ??
                              _defCommentWidget(commentViewData, setReplyState);
                        },
                      )
                    : SizedBox();
              },
            ),
            if (state is LMFeedGetReplyCommentPaginationLoadingState)
              if (state.commentId == widget.comment.id)
                widget.loaderBuilder?.call(context) ?? _defLoaderWidget(),
            if ((comment?.replies?.isNotEmpty ?? false) &&
                (comment?.replies?.length ?? 0) < comment!.repliesCount)
              Container(
                color: feedTheme.container,
                padding: replyStyle?.padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LMFeedButton(
                      onTap: () {
                        page++;
                        _commentBloc.add(LMFeedGetReplyEvent(
                          commentId: comment!.id,
                          postId: postId,
                          page: page,
                          pageSize: 10,
                        ));
                      },
                      text: LMFeedText(
                        text: 'View more replies',
                        style: LMFeedTextStyle(
                          textStyle: TextStyle(
                            color: feedTheme.primaryColor,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    LMFeedText(
                      text:
                          ' ${comment?.replies?.length} of ${comment!.repliesCount}',
                      style: const LMFeedTextStyle(
                        textStyle: TextStyle(
                          fontSize: 11,
                          color: LikeMindsTheme.greyColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      }),
      listener: _handleListener,
    );
  }

  LMFeedLoader _defLoaderWidget() {
    return LMFeedLoader(
      style: feedTheme.loaderStyle.copyWith(
        height: 24,
        width: 24,
        padding: EdgeInsets.symmetric(vertical: 16),
      ),
    );
  }

  bool _handleBuildWhen(previous, current) {
    if (current is LMFeedGetReplyCommentSuccessState ||
        current is LMFeedGetReplyCommentLoadingState ||
        current is LMFeedGetReplyCommentPaginationLoadingState ||
        current is LMFeedEditReplySuccessState ||
        current is LMFeedDeleteReplySuccessState ||
        current is LMFeedReplyCommentErrorState) {
      return true;
    }
    return false;
  }

  void _handleListener(context, state) {
    switch (state.runtimeType) {
      case LMFeedGetReplyCommentSuccessState:
        _handleGetReplyCommentSuccessState(
            state as LMFeedGetReplyCommentSuccessState);
        break;

      case LMFeedEditReplySuccessState:
        _handleEditReplySuccessState(state as LMFeedEditReplySuccessState);
        break;

      case LMFeedEditReplyErrorState:
        _handleEditReplyErrorState(state as LMFeedEditReplyErrorState);
        break;

      case LMFeedDeleteReplySuccessState:
        _handleDeleteReplySuccessState(state as LMFeedDeleteReplySuccessState);
        break;

      case LMFeedDeleteReplyErrorState:
        _handleDeleteReplyErrorState(state as LMFeedDeleteReplyErrorState);
        break;

      case LMFeedReplyCommentSuccessState:
        _handleReplyCommentSuccessState(
            state as LMFeedReplyCommentSuccessState);
        break;

      case LMFeedReplyCommentErrorState:
        _handleReplyCommentErrorState(state as LMFeedReplyCommentErrorState);
        break;

      case LMFeedCloseReplyState:
        _handleCloseReplyState(state as LMFeedCloseReplyState);
        break;

      default:
        // Handle unexpected states or do nothing
        break;
    }
  }

  void _handleGetReplyCommentSuccessState(
      LMFeedGetReplyCommentSuccessState state) {
    if (state.commentId != widget.comment.id) return;
    if (state.page == 1) {
      comment?.replies = state.replies;
    } else {
      page = state.page;
      comment?.replies?.addAll(state.replies);
    }
  }

  void _handleEditReplySuccessState(LMFeedEditReplySuccessState state) {
    if (state.commentId != widget.comment.id) return;
    int? index =
        comment?.replies?.indexWhere((element) => element.id == state.replyId);
    if (index != null && index != -1) {
      comment?.replies?[index] = state.reply;
    }
  }

  void _handleEditReplyErrorState(LMFeedEditReplyErrorState state) {
    if (state.commentId != widget.comment.id) return;
    int? index = comment?.replies
        ?.indexWhere((element) => element.id == state.oldReply.id);
    if (index != null && index != -1) {
      comment?.replies?[index] = state.oldReply;
    }
    LMFeedCore.showSnackBar(
      context,
      state.error,
      widgetSource,
    );
  }

  void _handleDeleteReplySuccessState(LMFeedDeleteReplySuccessState state) {
    if (state.commentId != widget.comment.id) return;
    comment?.replies?.removeWhere((element) => element.id == state.replyId);
  }

  void _handleDeleteReplyErrorState(LMFeedDeleteReplyErrorState state) {
    LMFeedCore.showSnackBar(
      context,
      state.error,
      widgetSource,
    );
  }

  void _handleReplyCommentSuccessState(LMFeedReplyCommentSuccessState state) {
    if (state.reply.parentComment?.id != widget.comment.id) return;
    if (comment?.replies?.isEmpty ?? true) {
      page = 0;
    }
    if (state.reply.tempId == state.reply.id) {
      comment?.replies?.insert(0, state.reply);
    } else {
      int? index = comment?.replies
          ?.indexWhere((element) => element.tempId == state.reply.tempId);
      if (index != null && index != -1) {
        comment?.replies?[index] = state.reply;
      }
    }
  }

  void _handleReplyCommentErrorState(LMFeedReplyCommentErrorState state) {
    if (state.commentId != widget.comment.id) return;
    comment?.replies?.removeWhere((element) => element.tempId == state.replyId);
    LMFeedCore.showSnackBar(
      context,
      state.error,
      widgetSource,
    );
  }

  void _handleCloseReplyState(LMFeedCloseReplyState state) {
    if (state.commentId != widget.comment.id) return;
    page = 1;
    comment?.replies?.clear();
  }

  LMFeedCommentWidget _defCommentWidget(
    LMCommentViewData commentViewData,
    StateSetter setReplyState,
  ) {
    return LMFeedCommentWidget(
      style: replyStyle,
      comment: commentViewData,
      menu: (menu) => LMFeedMenu(
        menuItems: commentViewData.menuItems,
        removeItemIds: {},
        action: defLMFeedMenuAction(commentViewData),
        onMenuOpen: () {
          LMFeedCommentUtils.handleCommentMenuOpenTap(
            widget.post,
            commentViewData,
            widgetSource,
            commentViewData.level == 0
                ? LMFeedAnalyticsKeys.commentMenu
                : LMFeedAnalyticsKeys.replyMenu,
          );
        },
      ),
      onTagTap: (String uuid) {
        LMFeedProfileBloc.instance.add(
          LMFeedRouteToUserProfileEvent(
            uuid: commentViewData.user.sdkClientInfo.uuid,
            context: context,
          ),
        );

        LMFeedCore.instance.lmFeedClient.routeToProfile(uuid);
      },
      user: commentViewData.user,
      profilePicture: LMFeedProfilePicture(
        imageUrl: commentViewData.user.imageUrl,
        style: LMFeedProfilePictureStyle(
          size: 32,
          backgroundColor: feedTheme.primaryColor,
        ),
        fallbackText: commentViewData.user.name,
        onTap: () => LMFeedCommentUtils.handleCommentProfileTap(
            context,
            widget.post,
            commentViewData,
            LMFeedAnalyticsKeys.replyProfilePicture,
            widgetSource),
      ),
      onProfileNameTap: () => LMFeedCommentUtils.handleCommentProfileTap(
          context,
          widget.post,
          commentViewData,
          LMFeedAnalyticsKeys.replyProfileName,
          widgetSource),
      lmFeedMenuAction: defLMFeedMenuAction(
        commentViewData,
      ),
      likeButton: defLikeButton(
        commentViewData,
        setReplyState,
      ),
      replyButton: defCommentReplyButton(commentViewData),
    );
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
        if (comment == null) return;
        _commentBloc.add(
          LMFeedReplyingCommentEvent(
            postId: widget.postId,
            parentComment: comment!,
            userName: commentViewData.user.name,
          ),
        );
      },
    );
  }

  LMFeedMenuAction defLMFeedMenuAction(LMCommentViewData commentViewData) {
    return LMFeedMenuAction(
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
        _commentBloc.add(LMFeedEditingReplyEvent(
          postId: widget.post.id,
          commentId: widget.comment.id,
          replyText: commentViewData.text,
          oldReply: commentViewData,
        ));
      },
      onCommentDelete: () {
        // _commentHandlerBloc!.add(LMFeedCommentCancelEvent());
        String commentCreatorUUID = commentViewData.user.sdkClientInfo.uuid;

        showDialog(
            context: context,
            builder: (childContext) => LMFeedDeleteConfirmationDialog(
                title: 'Delete $commentTitleFirstCapSingular',
                widgetSource: widgetSource,
                uuid: commentCreatorUUID,
                content:
                    'Are you sure you want to delete this $commentTitleSmallCapSingular. This action can not be reversed.',
                action: (String reason) async {
                  Navigator.of(childContext).pop();
                  _commentBloc.add(LMDeleteReplyEvent(
                    postId: postId,
                    oldReply: commentViewData,
                    reason: reason.isEmpty ? "Reason for deletion" : reason,
                    commentId: widget.comment.id,
                  ));
                  LMFeedPostBloc.instance.add(LMFeedUpdatePostEvent(
                    postId: widget.post.id,
                    commentId: widget.comment.id,
                    actionType: LMFeedPostActionType.replyDeleted,
                  ));
                },
                actionText: 'Delete'));
      },
    );
  }

  LMFeedButton defLikeButton(
      LMCommentViewData commentViewData, StateSetter setReplyState) {
    LMFeedButton likeButton = LMFeedButton(
      isToggleEnabled: !LMFeedUserUtils.isGuestUser(),
      style: feedTheme.replyStyle.likeButtonStyle?.copyWith(
            showText: commentViewData.likesCount == 0 ? false : true,
          ) ??
          LMFeedButtonStyle(
            showText: commentViewData.likesCount == 0 ? false : true,
            icon: const LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.thumb_up_alt_outlined,
              style: LMFeedIconStyle(
                color: LikeMindsTheme.blackColor,
                size: 20,
              ),
            ),
            activeIcon: LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.thumb_up_alt_rounded,
              style: LMFeedIconStyle(
                size: 20,
                color: feedTheme.primaryColor,
              ),
            ),
          ),
      text: LMFeedText(
        text: LMFeedPostUtils.getLikeCountTextWithCount(
          commentViewData.likesCount,
        ),
        style: const LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            color: LikeMindsTheme.greyColor,
          ),
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

        Navigator.of(context, rootNavigator: true).push(
          MaterialPageRoute(
            builder: (context) => LMFeedLikesScreen(
              postId: widget.postId,
              commentId: commentViewData.id,
              widgetSource: widgetSource,
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
        LMCommentViewData? commentFromList = comment?.replies
            ?.firstWhere((element) => element.id == commentViewData.id);
        if (commentFromList == null) return;
        setReplyState(() {
          if (commentFromList.isLiked) {
            commentFromList.likesCount -= 1;
          } else {
            commentFromList.likesCount += 1;
          }
          commentFromList.isLiked = !commentFromList.isLiked;
        });

        ToggleLikeCommentRequest request = (ToggleLikeCommentRequestBuilder()
              ..commentId(commentViewData.id)
              ..postId(widget.postId))
            .build();

        ToggleLikeCommentResponse response =
            await LMFeedCore.instance.lmFeedClient.toggleLikeComment(request);

        if (!response.success) {
          setReplyState(
            () {
              if (commentFromList.isLiked) {
                commentFromList.likesCount -= 1;
              } else {
                commentFromList.likesCount += 1;
              }
              commentFromList.isLiked = !commentFromList.isLiked;
            },
          );
        } else {
          LMFeedCommentUtils.handleCommentLikeTapEvent(widget.post,
              widgetSource, commentViewData, commentViewData.isLiked);
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
}
