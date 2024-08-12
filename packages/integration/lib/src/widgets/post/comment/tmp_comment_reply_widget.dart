import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/bloc/lm_comment_bloc.dart';

class TempLMFeedCommentReplyWidget extends StatefulWidget {
  final String postId;
  final LMCommentViewData comment;
  final LMUserViewData user;
  final Function() refresh;
  final LMFeedCommentStyle? style;

  final LMFeedPostCommentBuilder? commentBuilder;

  final LMPostViewData post;

  const TempLMFeedCommentReplyWidget({
    Key? key,
    required this.comment,
    required this.user,
    required this.postId,
    this.style,
    required this.refresh,
    this.commentBuilder,
    required this.post,
  }) : super(key: key);

  @override
  State<TempLMFeedCommentReplyWidget> createState() =>
      _CommentReplyWidgetState();

  TempLMFeedCommentReplyWidget copyWith({
    String? postId,
    LMCommentViewData? reply,
    LMUserViewData? user,
    LMFeedCommentStyle? style,
    LMFeedPostCommentBuilder? commentBuilder,
    LMPostViewData? post,
    Function()? refresh,
  }) {
    return TempLMFeedCommentReplyWidget(
      postId: postId ?? this.postId,
      comment: reply ?? this.comment,
      user: user ?? this.user,
      refresh: refresh ?? this.refresh,
      style: style ?? this.style,
      commentBuilder: commentBuilder ?? this.commentBuilder,
      post: post ?? this.post,
    );
  }
}

class _CommentReplyWidgetState extends State<TempLMFeedCommentReplyWidget> {
  // final LMFeedFetchCommentReplyBloc _commentRepliesBloc =
  //     LMFeedFetchCommentReplyBloc.instance;
  final LMCommentBloc _commentBloc = LMCommentBloc.instance();
  // final LMFeedCommentBloc _commentHandlerBloc = LMFeedCommentBloc.instance;
  ValueNotifier<bool> rebuildLikeButton = ValueNotifier(false);
  ValueNotifier<bool> rebuildReplyList = ValueNotifier(false);
  // List<LMCommentViewData> replies = [];
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
    refresh = widget.refresh;
  }

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    user = widget.user;
    initializeReply();
  }

  int page = 1;

  @override
  Widget build(BuildContext context) {
    replyStyle = widget.style ?? feedTheme.replyStyle;
    return BlocConsumer(
      bloc: _commentBloc,
      buildWhen: (previous, current) {
        if (current is LMGetReplyCommentSuccess ||
            current is LMGetReplyCommentLoading ||
            current is LMGetReplyCommentPaginationLoading ||
            current is LMEditReplySuccess ||
            current is LMDeleteReplySuccess) {
          return true;
        }
        return false;
      },
      builder: ((context, state) {
        if (state is LMGetReplyCommentLoading) {
          if (state.commentId == widget.comment.id) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: LMFeedLoader(
                  style: feedTheme.loaderStyle,
                ),
              ),
            );
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
            if (state is LMGetReplyCommentPaginationLoading)
              if (state.commentId == widget.comment.id)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 30.0),
                    child: SizedBox(
                      height: 20,
                      width: 20,
                      child: LMFeedLoader(
                        style: feedTheme.loaderStyle,
                      ),
                    ),
                  ),
                ),
            if ((comment?.replies?.isNotEmpty ?? false) &&
                comment?.replies?.length != comment!.repliesCount)
              Container(
                color: feedTheme.container,
                padding: replyStyle?.padding,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    LMFeedButton(
                      onTap: () {
                        page++;
                        _commentBloc.add(LMGetReplyEvent(
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
      listener: (context, state) {
        if (state is LMGetReplyCommentSuccess) {
          if (state.commentId != widget.comment.id) {
            return;
          }
          if (state.page == 1) {
            comment?.replies = state.replies;
          } else {
            page = state.page;
            comment?.replies?.addAll(state.replies);
          }
        } else if (state is LMEditReplySuccess) {
          if (state.commentId != widget.comment.id) {
            return;
          }
          int? index = comment?.replies
              ?.indexWhere((element) => element.id == state.replyId);
          if (index != null && index != -1) {
            comment?.replies?[index] = state.reply;
          }
        } else if (state is LMDeleteReplySuccess) {
          if (state.commentId != widget.comment.id) {
            return;
          }
          comment?.replies
              ?.removeWhere((element) => element.id == state.replyId);
        } else if (state is LMReplyCommentSuccess) {
          if (state.reply.parentComment?.id != widget.comment.id) {
            return;
          }
          page = 0;
          comment?.replies?.insert(0, state.reply);
        } else if (state is LMCloseReplyState) {
          if (state.commentId != widget.comment.id) {
            return;
          }
          comment?.replies?.clear();
        }
      },
    );
  }

  LMFeedCommentWidget _defCommentWidget(
    LMCommentViewData commentViewData,
    StateSetter setReplyState,
  ) {
    return LMFeedCommentWidget(
      style: replyStyle,
      comment: commentViewData,
      menu: (menu) => menu.copyWith(
        removeItemIds: {},
        onMenuOpen: () {
          LMFeedCommentUtils.handleCommentMenuOpenTap(widget.post,
              commentViewData, widgetSource, LMFeedAnalyticsKeys.replyMenu);
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
          LMReplyingCommentEvent(
            postId: widget.postId,
            commentId: commentViewData.id,
            userName: commentViewData.user.name,
          ),
        );
      },
    );
  }

  LMFeedMenuAction defLMFeedMenuAction(LMCommentViewData commentViewData) {
    return LMFeedMenuAction(
      onCommentEdit: () {
        _commentBloc.add(LMEditingReplyEvent(
          postId: widget.post.id,
          commentId: widget.comment.id,
          replyText: commentViewData.text,
          replyId: commentViewData.id,
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
                    replyId: commentViewData.id,
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
          LMCommentViewData commentViewData, StateSetter setReplyState) =>
      LMFeedButton(
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
          text: commentViewData.likesCount == 0
              ? "Like"
              : commentViewData.likesCount == 1
                  ? "1 Like"
                  : "${commentViewData.likesCount} Likes",
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
}
