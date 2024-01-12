import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/comment/comment_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/user/user_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_driver_fl/src/views/post/widgets/delete_dialog.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:timeago/timeago.dart' as timeago;

class LMFeedCommentReplyWidget extends StatefulWidget {
  final String postId;
  final LMCommentViewData reply;
  final LMUserViewData user;
  final Function() refresh;

  const LMFeedCommentReplyWidget({
    Key? key,
    required this.reply,
    required this.user,
    required this.postId,
    // required this.onReply,
    required this.refresh,
  }) : super(key: key);

  @override
  State<LMFeedCommentReplyWidget> createState() => _CommentReplyWidgetState();

  LMFeedCommentReplyWidget copyWith(
      {String? postId,
      LMCommentViewData? reply,
      LMUserViewData? user,
      Function()? refresh}) {
    return LMFeedCommentReplyWidget(
      postId: postId ?? this.postId,
      reply: reply ?? this.reply,
      user: user ?? this.user,
      refresh: refresh ?? this.refresh,
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
    feedTheme = LMFeedTheme.of(context);
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
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: LMFeedLoader(
                    color: feedTheme!.primaryColor,
                  ),
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
                    if (response.reply!.parentComment!.id == widget.reply.id) {
                      replies.insert(
                          0,
                          LMCommentViewDataConvertor.fromComment(
                              response.reply!));
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
                          response.reply!);
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
          builder: (context, state) => Container(
            padding: const EdgeInsets.only(
              left: 48,
              bottom: 0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: replies.length,
                    itemBuilder: (context, index) {
                      LMCommentViewData commentViewData = replies[index];
                      LMUserViewData user = users[commentViewData.userId]!;
                      return StatefulBuilder(builder: (context, setReplyState) {
                        return LMFeedReplyTile(
                            comment: commentViewData,
                            onTagTap: (String userId) {
                              LMFeedCore.instance.lmFeedClient
                                  .routeToProfile(userId);
                            },
                            user: user,
                            profilePicture: LMFeedProfilePicture(
                              imageUrl: user.imageUrl,
                              style: LMFeedProfilePictureStyle(
                                size: 32,
                                backgroundColor: feedTheme!.primaryColor,
                              ),
                              fallbackText: user.name,
                              onTap: () {
                                if (user.sdkClientInfo != null) {
                                  LMFeedCore.instance.lmFeedClient
                                      .routeToProfile(
                                          user.sdkClientInfo!.userUniqueId);
                                }
                              },
                            ),
                            subtitleText: LMFeedText(
                              text:
                                  "@${user.name.toLowerCase().split(' ').join()} · ${timeago.format(commentViewData.createdAt)}",
                              style: const LMFeedTextStyle(
                                textStyle: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: LMThemeData.kGreyColor,
                                ),
                              ),
                            ),
                            lmFeedMenuAction:
                                defLMFeedMenuAction(commentViewData),
                            commentActions: [
                              const SizedBox(width: 48),
                              LMFeedButton(
                                style: LMFeedButtonStyle(
                                  icon: const LMFeedIcon(
                                    type: LMFeedIconType.icon,
                                    icon: Icons.thumb_up_alt_outlined,
                                    style: LMFeedIconStyle(
                                      color: LMThemeData.appBlack,
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
                                      color:
                                          LMThemeData.theme.colorScheme.primary,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                                onTap: () async {
                                  LMCommentViewData commentFromList =
                                      replies.firstWhere((element) =>
                                          element.id == commentViewData.id);
                                  setReplyState(() {
                                    if (commentFromList.isLiked) {
                                      commentFromList.likesCount -= 1;
                                    } else {
                                      commentFromList.likesCount += 1;
                                    }
                                    commentFromList.isLiked =
                                        !commentFromList.isLiked;
                                  });

                                  ToggleLikeCommentRequest request =
                                      (ToggleLikeCommentRequestBuilder()
                                            ..commentId(commentViewData.id)
                                            ..postId(widget.postId))
                                          .build();

                                  ToggleLikeCommentResponse response =
                                      await LMFeedCore.instance.lmFeedClient
                                          .toggleLikeComment(request);

                                  if (!response.success) {
                                    setReplyState(() {
                                      if (commentFromList.isLiked) {
                                        commentFromList.likesCount -= 1;
                                      } else {
                                        commentFromList.likesCount += 1;
                                      }
                                      commentFromList.isLiked =
                                          !commentFromList.isLiked;
                                    });
                                  }
                                },
                                isActive: commentViewData.isLiked,
                              ),
                              const SizedBox(width: 8),
                            ]);
                      });
                    }),
                if (replies.isNotEmpty &&
                    replies.length % 10 == 0 &&
                    replies.length != reply!.repliesCount)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          page++;
                          _commentRepliesBloc!.add(LMFeedGetCommentRepliesEvent(
                              commentDetailRequest: (GetCommentRequestBuilder()
                                    ..commentId(reply!.id)
                                    ..page(page)
                                    ..postId(postId))
                                  .build(),
                              forLoadMore: true));
                        },
                        child: const Text(
                          'View more replies',
                          style: TextStyle(
                            color: LMThemeData.kBlueGreyColor,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Text(
                        ' ${replies.length} of ${reply!.repliesCount}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: LMThemeData.kGrey3Color,
                        ),
                      )
                    ],
                  ),
                // replies.add();
              ],
            ),
          ),
        );
      }),
      listener: (context, state) {
        if (state is LMFeedCommentRepliesLoadedState) {
          replies = state.commentDetails.postReplies!.replies
                  ?.map((e) => LMCommentViewDataConvertor.fromComment(e))
                  .toList() ??
              [];
          users = state.commentDetails.users!.map((key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value)));
          users.putIfAbsent(user.userUniqueId, () => user);
        } else if (state is LMFeedPaginatedCommentRepliesLoadingState) {
          replies = state.prevCommentDetails.postReplies!.replies
                  ?.map((e) => LMCommentViewDataConvertor.fromComment(e))
                  .toList() ??
              [];
          users = state.prevCommentDetails.users!.map((key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value)));
          users.putIfAbsent(user.userUniqueId, () => user);
        }
        replyCount = replies.length;
      },
    );
  }

  LMFeedMenuAction defLMFeedMenuAction(LMCommentViewData commentViewData) {
    return LMFeedMenuAction(
      onCommentEdit: () {
        _commentHandlerBloc!.add(LMFeedCommentCancelEvent());
        LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
              ..commentId(widget.reply.parentComment!.id)
              ..commentActionEntity(LMFeedCommentType.reply)
              ..commentActionType(LMFeedCommentActionType.edit)
              ..level(1)
              ..replyId(commentViewData.id))
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
}
