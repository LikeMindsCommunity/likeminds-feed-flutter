import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/post_action_id.dart';
import 'package:likeminds_feed_flutter_core/src/views/post/widgets/delete_dialog.dart';

class LMFeedCommentReplyWidget extends StatefulWidget {
  final String postId;
  final LMCommentViewData reply;
  final LMUserViewData user;
  final Function() refresh;
  final LMFeedCommentStyle? style;

  final LMFeedPostCommentBuilder? commentBuilder;

  final LMPostViewData post;

  const LMFeedCommentReplyWidget({
    Key? key,
    required this.reply,
    required this.user,
    required this.postId,
    this.style,
    required this.refresh,
    this.commentBuilder,
    required this.post,
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
    Function()? refresh,
  }) {
    return LMFeedCommentReplyWidget(
      postId: postId ?? this.postId,
      reply: reply ?? this.reply,
      user: user ?? this.user,
      refresh: refresh ?? this.refresh,
      style: style ?? this.style,
      commentBuilder: commentBuilder ?? this.commentBuilder,
      post: post ?? this.post,
    );
  }
}

class _CommentReplyWidgetState extends State<LMFeedCommentReplyWidget> {
  LMFeedFetchCommentReplyBloc? _commentRepliesBloc;
  LMFeedCommentHandlerBloc? _commentHandlerBloc;
  ValueNotifier<bool> rebuildLikeButton = ValueNotifier(false);
  ValueNotifier<bool> rebuildReplyList = ValueNotifier(false);
  List<LMCommentViewData> replies = [];
  Map<String, LMUserViewData> users = {};
  LMFeedThemeData? feedTheme;
  LMFeedCommentStyle? replyStyle;

  LMCommentViewData? reply;
  late final LMUserViewData user;
  late final String postId;
  Function()? refresh;
  int? likeCount;
  bool isLiked = false;
  int replyCount = 0;

  void initialiseReply() {
    reply = widget.reply;
    isLiked = reply!.isLiked;
    likeCount = reply!.likesCount;
    replyCount = reply!.repliesCount;
    refresh = widget.refresh;
    _commentHandlerBloc = LMFeedCommentHandlerBloc.instance;
    _commentRepliesBloc = LMFeedFetchCommentReplyBloc.instance;
  }

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    user = widget.user;
    initialiseReply();
  }

  @override
  void didUpdateWidget(covariant LMFeedCommentReplyWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reply != widget.reply) {
      initialiseReply();
    }
  }

  int page = 1;

  @override
  Widget build(BuildContext context) {
    feedTheme = LMFeedCore.theme;
    replyStyle = widget.style ?? feedTheme?.replyStyle;
    return BlocConsumer(
      bloc: _commentRepliesBloc,
      buildWhen: (previous, current) {
        if (current is LMFeedCommentRepliesLoadedState &&
            current.commentId != reply!.id) {
          return false;
        }
        if (current is LMFeedPaginatedCommentRepliesLoadingState &&
            current.commentId != reply!.id) {
          return false;
        }
        if (current is LMFeedCommentRepliesLoadingState &&
            current.commentId != widget.reply.id) {
          return false;
        }
        return true;
      },
      builder: ((context, state) {
        if (state is LMFeedAddLocalReplyState) {
          if (replies.isEmpty) {
            replies.add(state.comment);
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: replies.length,
                itemBuilder: (context, index) {
                  LMCommentViewData commentViewData = replies[index];
                  return StatefulBuilder(
                    builder: (context, setReplyState) {
                      return widget.commentBuilder?.call(
                              context,
                              _defCommetWidget(commentViewData, setReplyState),
                              widget.post) ??
                          _defCommetWidget(commentViewData, setReplyState);
                    },
                  );
                },
              ),
              if (replies.length != reply!.repliesCount)
                Container(
                  color: feedTheme?.container,
                  padding: replyStyle?.padding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LMFeedButton(
                        onTap: () {
                          _commentRepliesBloc!.add(LMFeedGetCommentRepliesEvent(
                              commentDetailRequest: (GetCommentRequestBuilder()
                                    ..commentId(reply!.id)
                                    ..page(page)
                                    ..postId(postId))
                                  .build(),
                              forLoadMore: true));
                          page++;
                        },
                        text: LMFeedText(
                          text: 'View more replies',
                          style: LMFeedTextStyle(
                            textStyle: TextStyle(
                              color: feedTheme?.primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      LMFeedText(
                        text: ' ${replies.length} of ${reply!.repliesCount}',
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
              // replies.add();
            ],
          );
        }
        if (state is LMFeedClearedCommentRepliesState) {
          replies = [];
          users = {};
          return const SizedBox();
        }
        if (state is LMFeedCommentRepliesLoadingState) {
          if (state.commentId == widget.reply.id) {
            return Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: SizedBox(
                height: 20,
                width: 20,
                child: LMFeedLoader(
                  style: feedTheme!.loaderStyle,
                ),
              ),
            );
          }
        }
        if (state is LMFeedCommentRepliesLoadedState ||
            state is LMFeedPaginatedCommentRepliesLoadingState) {
          if ((state is LMFeedCommentRepliesLoadedState &&
                  state.commentId != reply!.id) ||
              (state is LMFeedPaginatedCommentRepliesLoadingState &&
                  state.commentId != reply!.id)) {
            return const SizedBox();
          }
        }
        return BlocConsumer<LMFeedCommentHandlerBloc,
            LMFeedCommentHandlerState>(
          bloc: _commentHandlerBloc,
          listener: (context, state) {
            switch (state.runtimeType) {
              case const (LMFeedCommentSuccessState<AddCommentReplyResponse>):
                {
                  if ((state as LMFeedCommentSuccessState<
                                  AddCommentReplyResponse>)
                              .commentMetaData
                              .commentActionType ==
                          LMFeedCommentActionType.replying &&
                      state.commentMetaData.commentActionEntity ==
                          LMFeedCommentType.reply) {
                    AddCommentReplyResponse response =
                        state.commentActionResponse;
                    if (response.reply!.parentComment!.tempId ==
                        widget.reply.tempId) {
                      replies.replaceRange(0, 1, [
                        LMCommentViewDataConvertor.fromComment(
                            response.reply!, users)
                      ]);
                    }
                  }
                  break;
                }
              case const (LMFeedCommentSuccessState<EditCommentReplyResponse>):
                {
                  if ((state as LMFeedCommentSuccessState<
                                  EditCommentReplyResponse>)
                              .commentMetaData
                              .commentActionType ==
                          LMFeedCommentActionType.edit &&
                      state.commentMetaData.commentActionEntity ==
                          LMFeedCommentType.reply) {
                    EditCommentReplyResponse response =
                        state.commentActionResponse;

                    int index = replies.indexWhere(
                        (element) => element.id == response.reply!.id);
                    if (index != -1) {
                      replies[index] = LMCommentViewDataConvertor.fromComment(
                          response.reply!, users);
                    }
                  }
                  break;
                }
              case const (LMFeedCommentSuccessState<DeleteCommentResponse>):
                {
                  if ((state as LMFeedCommentSuccessState<
                                  DeleteCommentResponse>)
                              .commentMetaData
                              .commentActionType ==
                          LMFeedCommentActionType.delete &&
                      state.commentMetaData.commentActionEntity ==
                          LMFeedCommentType.reply) {
                    replies.removeWhere((element) =>
                        element.id == state.commentMetaData.replyId);
                    reply!.repliesCount -= 1;
                    replyCount = reply!.repliesCount;
                  }
                  break;
                }
            }
          },
          buildWhen: (previous, current) {
            switch (current.runtimeType) {
              case const (LMFeedCommentSuccessState<AddCommentReplyResponse>):
                return true;
              case const (LMFeedCommentSuccessState<EditCommentReplyResponse>):
                return true;
              case const (LMFeedCommentSuccessState<DeleteCommentResponse>):
                return true;
              default:
                return false;
            }
          },
          builder: (context, state) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: EdgeInsets.zero,
                itemCount: replies.length,
                itemBuilder: (context, index) {
                  LMCommentViewData commentViewData = replies[index];
                  return StatefulBuilder(
                    builder: (context, setReplyState) {
                      return widget.commentBuilder?.call(
                              context,
                              _defCommetWidget(commentViewData, setReplyState),
                              widget.post) ??
                          _defCommetWidget(commentViewData, setReplyState);
                    },
                  );
                },
              ),
              if (replies.isNotEmpty &&
                  replies.length % 10 == 0 &&
                  replies.length != reply!.repliesCount)
                Container(
                  color: feedTheme?.container,
                  padding: replyStyle?.padding,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      LMFeedButton(
                        onTap: () {
                          page++;
                          _commentRepliesBloc!.add(LMFeedGetCommentRepliesEvent(
                              commentDetailRequest: (GetCommentRequestBuilder()
                                    ..commentId(reply!.id)
                                    ..page(page)
                                    ..postId(postId))
                                  .build(),
                              forLoadMore: true));
                        },
                        text: LMFeedText(
                          text: 'View more replies',
                          style: LMFeedTextStyle(
                            textStyle: TextStyle(
                              color: feedTheme?.primaryColor,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      LMFeedText(
                        text: ' ${replies.length} of ${reply!.repliesCount}',
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
              // replies.add();
            ],
          ),
        );
      }),
      listener: (context, state) {
        if (state is LMFeedCommentRepliesLoadedState) {
          users = state.commentDetails.users!.map((key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value)));
          users.putIfAbsent(user.userUniqueId, () => user);
          replies = state.commentDetails.postReplies!.replies
                  ?.map((e) => LMCommentViewDataConvertor.fromComment(e, users))
                  .toList() ??
              [];
        } else if (state is LMFeedPaginatedCommentRepliesLoadingState) {
          users = state.prevCommentDetails.users!.map((key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value)));
          users.putIfAbsent(user.userUniqueId, () => user);
          replies = state.prevCommentDetails.postReplies!.replies
                  ?.map((e) => LMCommentViewDataConvertor.fromComment(e, users))
                  .toList() ??
              [];
        } else if (state is LMFeedAddLocalReplyState) {
          replies.insert(0, state.comment);
        }
        replyCount = replies.length;
      },
    );
  }

  LMFeedCommentWidget _defCommetWidget(
    LMCommentViewData commentViewData,
    StateSetter setReplyState,
  ) {
    return LMFeedCommentWidget(
      style: replyStyle,
      comment: commentViewData,
      onTagTap: (String userId) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(userId);
      },
      user: commentViewData.user,
      profilePicture: LMFeedProfilePicture(
        imageUrl: commentViewData.user.imageUrl,
        style: LMFeedProfilePictureStyle(
          size: 32,
          backgroundColor: feedTheme!.primaryColor,
        ),
        fallbackText: commentViewData.user.name,
        onTap: () {
          if (commentViewData.user.sdkClientInfo != null) {
            LMFeedCore.instance.lmFeedClient.routeToProfile(
                commentViewData.user.sdkClientInfo!.userUniqueId);
          }
        },
      ),
      lmFeedMenuAction: defLMFeedMenuAction(
        commentViewData,
      ),
      likeButton: defLikeButton(
        commentViewData,
        setReplyState,
      ),
      menu: (menu) {
        return menu.copyWith(
          removeItemIds: {},
        );
      },
    );
  }

  LMFeedMenuAction defLMFeedMenuAction(LMCommentViewData commentViewData) {
    return LMFeedMenuAction(
      onCommentEdit: () {
        _commentHandlerBloc!.add(LMFeedCommentCancelEvent());
        LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
              ..commentId(widget.reply.id)
              ..commentActionEntity(LMFeedCommentType.reply)
              ..commentActionType(LMFeedCommentActionType.edit)
              ..level(1)
              ..postId(widget.post.id)
              ..replyId(commentViewData.id)
              ..commentText(
                  LMFeedTaggingHelper.convertRouteToTag(commentViewData.text)))
            .build();
        _commentHandlerBloc!
            .add(LMFeedCommentOngoingEvent(commentMetaData: commentMetaData));
      },
      onCommentDelete: () {
        _commentHandlerBloc!.add(LMFeedCommentCancelEvent());

        showDialog(
            context: context,
            builder: (childContext) => LMFeedDeleteConfirmationDialog(
                title: 'Delete Comment',
                userId: commentViewData.userId,
                content:
                    'Are you sure you want to delete this comment. This action can not be reversed.',
                action: (String reason) async {
                  Navigator.of(childContext).pop();
                  //Implement delete post analytics tracking
                  DeleteCommentRequest request = (DeleteCommentRequestBuilder()
                        ..postId(postId)
                        ..commentId(commentViewData.id)
                        ..reason(
                            reason.isEmpty ? "Reason for deletion" : reason))
                      .build();

                  LMCommentMetaData commentMetaData =
                      (LMCommentMetaDataBuilder()
                            ..commentId(widget.reply.id)
                            ..postId(widget.post.id)
                            ..commentActionEntity(LMFeedCommentType.reply)
                            ..commentActionType(LMFeedCommentActionType.delete)
                            ..level(1)
                            ..replyId(commentViewData.id))
                          .build();

                  _commentHandlerBloc!.add(LMFeedCommentActionEvent(
                      commentActionRequest: request,
                      commentMetaData: commentMetaData));
                },
                actionText: 'Delete'));
      },
    );
  }

  LMFeedButton defLikeButton(
          LMCommentViewData commentViewData, StateSetter setReplyState) =>
      LMFeedButton(
        style: feedTheme?.replyStyle.likeButtonStyle?.copyWith(
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
                  color: feedTheme!.primaryColor,
                ),
                assetPath: kAssetLikeFilledIcon,
              ),
            ),
        text: LMFeedText(
          text: commentViewData.likesCount == 0
              ? "Like"
              : commentViewData.likesCount == 1
                  ? "1 Like"
                  : "${commentViewData.likesCount} Likes",
          style: const LMFeedTextStyle(
            textStyle: TextStyle(fontSize: 12),
          ),
        ),
        activeText: LMFeedText(
          text: commentViewData.likesCount == 0
              ? "Like"
              : commentViewData.likesCount == 1
                  ? "1 Like"
                  : "${commentViewData.likesCount} Likes",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              color: feedTheme?.primaryColor,
              fontSize: 12,
            ),
          ),
        ),
        onTextTap: () {
          Navigator.of(context, rootNavigator: true).push(
            MaterialPageRoute(
              builder: (context) => LMFeedLikesScreen(
                postId: widget.postId,
                commentId: commentViewData.id,
              ),
            ),
          );
        },
        onTap: () async {
          LMCommentViewData commentFromList =
              replies.firstWhere((element) => element.id == commentViewData.id);
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
          }
        },
        isActive: commentViewData.isLiked,
      );
}
