import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/comment/comment_handler/comment_handler_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/comment/comment_replies/comment_replies_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/comment/comment_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/user/user_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/post_action_id.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_driver_fl/src/views/post/widgets/delete_dialog.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:timeago/timeago.dart' as timeago;

class LMCommentReplyWidget extends StatefulWidget {
  final String postId;
  final LMCommentViewData reply;
  final LMUserViewData user;
  final Function() refresh;

  //final Function(String commentId, String username, String userId) onReply;

  const LMCommentReplyWidget({
    Key? key,
    required this.reply,
    required this.user,
    required this.postId,
    // required this.onReply,
    required this.refresh,
  }) : super(key: key);

  @override
  State<LMCommentReplyWidget> createState() => _CommentReplyWidgetState();
}

class _CommentReplyWidgetState extends State<LMCommentReplyWidget> {
  LMFetchCommentReplyBloc? _commentRepliesBloc;
  LMCommentHandlerBloc? _commentHandlerBloc;
  ValueNotifier<bool> rebuildLikeButton = ValueNotifier(false);
  ValueNotifier<bool> rebuildReplyList = ValueNotifier(false);
  List<LMCommentViewData> replies = [];
  Map<String, LMUserViewData> users = {};

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
    _commentHandlerBloc = LMCommentHandlerBloc.instance;
    _commentRepliesBloc = LMFetchCommentReplyBloc.instance;
  }

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    user = widget.user;
    initialiseReply();
  }

  @override
  void didUpdateWidget(covariant LMCommentReplyWidget oldWidget) {
    // TODO: implement didUpdateWidget
    super.didUpdateWidget(oldWidget);
    if (oldWidget.reply != widget.reply) {
      initialiseReply();
    }
  }

  int page = 1;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer(
      bloc: _commentRepliesBloc,
      buildWhen: (previous, current) {
        if (current is LMCommentRepliesLoaded &&
            current.commentId != reply!.id) {
          return false;
        }
        if (current is LMPaginatedCommentRepliesLoading &&
            current.commentId != reply!.id) {
          return false;
        }
        if (current is LMCommentRepliesLoading &&
            current.commentId != widget.reply.id) {
          return false;
        }
        return true;
      },
      builder: ((context, state) {
        if (state is LMClearedCommentReplies) {
          replies = [];
          users = {};
          return const SizedBox();
        }
        if (state is LMCommentRepliesLoading) {
          if (state.commentId == widget.reply.id) {
            return const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 30.0),
              child: Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: LMLoader(
                    color: LMThemeData.kPrimaryColor,
                  ),
                ),
              ),
            );
          }
        }
        if (state is LMCommentRepliesLoaded ||
            state is LMPaginatedCommentRepliesLoading) {
          if ((state is LMCommentRepliesLoaded &&
                  state.commentId != reply!.id) ||
              (state is LMPaginatedCommentRepliesLoading &&
                  state.commentId != reply!.id)) {
            return const SizedBox();
          }
        }
        return BlocConsumer<LMCommentHandlerBloc, LMCommentHandlerState>(
          bloc: _commentHandlerBloc,
          listener: (context, state) {
            switch (state.runtimeType) {
              case const (LMCommentSuccessState<AddCommentReplyResponse>):
                {
                  if ((state as LMCommentSuccessState<AddCommentReplyResponse>)
                              .commentMetaData
                              .commentActionType ==
                          LMCommentActionType.replying &&
                      state.commentMetaData.commentActionEntity ==
                          LMCommentType.reply) {
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
              case const (LMCommentSuccessState<EditCommentReplyResponse>):
                {
                  if ((state as LMCommentSuccessState<EditCommentReplyResponse>)
                              .commentMetaData
                              .commentActionType ==
                          LMCommentActionType.edit &&
                      state.commentMetaData.commentActionEntity ==
                          LMCommentType.reply) {
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
              case const (LMCommentSuccessState<DeleteCommentResponse>):
                {
                  if ((state as LMCommentSuccessState<DeleteCommentResponse>)
                              .commentMetaData
                              .commentActionType ==
                          LMCommentActionType.delete &&
                      state.commentMetaData.commentActionEntity ==
                          LMCommentType.reply) {
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
              case const (LMCommentSuccessState<AddCommentReplyResponse>):
                return true;
              case const (LMCommentSuccessState<EditCommentReplyResponse>):
                return true;
              case const (LMCommentSuccessState<DeleteCommentResponse>):
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
                        return LMReplyTile(
                            comment: commentViewData,
                            onTagTap: (String userId) {
                              LMFeedCore.instance.lmFeedClient
                                  .routeToProfile(userId);
                            },
                            user: user,
                            profilePicture: LMProfilePicture(
                              imageUrl: user.imageUrl,
                              backgroundColor: LMThemeData.kPrimaryColor,
                              fallbackText: user.name,
                              onTap: () {
                                if (user.sdkClientInfo != null) {
                                  LMFeedCore.instance.lmFeedClient
                                      .routeToProfile(
                                          user.sdkClientInfo!.userUniqueId);
                                }
                              },
                              size: 32,
                            ),
                            subtitleText: LMTextView(
                              text:
                                  "@${user.name.toLowerCase().split(' ').join()} · ${timeago.format(commentViewData.createdAt)}",
                              textStyle: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                                color: LMThemeData.kGreyColor,
                              ),
                            ),
                            onMenuTap: (value) async {
                              if (value == commentDeleteId) {
                                _commentHandlerBloc!
                                    .add(LMCommentCancelEvent());

                                showDialog(
                                    context: context,
                                    builder: (childContext) =>
                                        LMDeleteConfirmationDialog(
                                            title: 'Delete Comment',
                                            userId: commentViewData.userId,
                                            content:
                                                'Are you sure you want to delete this comment. This action can not be reversed.',
                                            action: (String reason) async {
                                              Navigator.of(childContext).pop();
                                              //Implement delete post analytics tracking
                                              DeleteCommentRequest request =
                                                  (DeleteCommentRequestBuilder()
                                                        ..postId(postId)
                                                        ..commentId(
                                                            commentViewData.id)
                                                        ..reason(reason.isEmpty
                                                            ? "Reason for deletion"
                                                            : reason))
                                                      .build();

                                              LMCommentMetaData
                                                  commentMetaData =
                                                  (LMCommentMetaDataBuilder()
                                                        ..commentId(
                                                            widget.reply.id)
                                                        ..commentActionEntity(
                                                            LMCommentType.reply)
                                                        ..commentActionType(
                                                            LMCommentActionType
                                                                .delete)
                                                        ..level(1)
                                                        ..replyId(
                                                            commentViewData.id))
                                                      .build();

                                              _commentHandlerBloc!.add(
                                                  LMCommentActionEvent(
                                                      commentActionRequest:
                                                          request,
                                                      commentMetaData:
                                                          commentMetaData));
                                            },
                                            actionText: 'Delete'));
                              } else if (value == commentEditId) {
                                _commentHandlerBloc!
                                    .add(LMCommentCancelEvent());
                                LMCommentMetaData commentMetaData =
                                    (LMCommentMetaDataBuilder()
                                          ..commentId(
                                              widget.reply.parentComment!.id)
                                          ..commentActionEntity(
                                              LMCommentType.reply)
                                          ..commentActionType(
                                              LMCommentActionType.edit)
                                          ..level(1)
                                          ..replyId(commentViewData.id))
                                        .build();

                                _commentHandlerBloc!.add(LMCommentOngoingEvent(
                                    commentMetaData: commentMetaData));
                              }
                            },
                            commentActions: [
                              const SizedBox(width: 48),
                              LMButton(
                                text: LMTextView(
                                  text: commentViewData.likesCount == 0
                                      ? "Like"
                                      : commentViewData.likesCount == 1
                                          ? "1 Like"
                                          : "${commentViewData.likesCount} Likes",
                                  textStyle: const TextStyle(fontSize: 12),
                                ),
                                activeText: LMTextView(
                                  text: commentViewData.likesCount == 0
                                      ? "Like"
                                      : commentViewData.likesCount == 1
                                          ? "1 Like"
                                          : "${commentViewData.likesCount} Likes",
                                  textStyle: TextStyle(
                                    color:
                                        LMThemeData.theme.colorScheme.primary,
                                    fontSize: 12,
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
                                icon: const LMIcon(
                                  type: LMIconType.icon,
                                  icon: Icons.thumb_up_alt_outlined,
                                  iconStyle: LMIconStyle(
                                    color: LMThemeData.appBlack,
                                    size: 20,
                                  ),
                                ),
                                activeIcon: const LMIcon(
                                  type: LMIconType.icon,
                                  icon: Icons.thumb_up_alt_rounded,
                                  iconStyle: LMIconStyle(
                                    size: 20,
                                    color: LMThemeData.kPrimaryColor,
                                  ),
                                  assetPath: kAssetLikeFilledIcon,
                                ),
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
                          _commentRepliesBloc!.add(LMGetCommentReplies(
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
        if (state is LMCommentRepliesLoaded) {
          replies = state.commentDetails.postReplies!.replies
                  ?.map((e) => LMCommentViewDataConvertor.fromComment(e))
                  .toList() ??
              [];
          users = state.commentDetails.users!.map((key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value)));
          users.putIfAbsent(user.userUniqueId, () => user);
        } else if (state is LMPaginatedCommentRepliesLoading) {
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
}
