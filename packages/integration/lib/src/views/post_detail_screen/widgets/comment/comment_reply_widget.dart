import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/comment/comment_handler/comment_handler_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/comment/comment_replies/comment_replies_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/comment/comment_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/user/user_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/post_action_id.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_driver_fl/src/views/post_detail_screen/widgets/delete_dialog.dart';
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
  ValueNotifier<bool> rebuildReplyButton = ValueNotifier(false);
  List<LMCommentViewData> replies = [];
  Map<String, LMUserViewData> users = {};
  List<Widget> repliesW = [];

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
  }

  @override
  void initState() {
    super.initState();
    postId = widget.postId;
    user = widget.user;
    initialiseReply();
  }

  int page = 1;

  List<Widget> mapRepliesToWidget(
      List<LMCommentViewData> replies, Map<String, LMUserViewData> users) {
    replies = replies.map((e) {
      e.menuItems.removeWhere((element) =>
          element.id == commentReportId || element.id == commentEditId);
      return e;
    }).toList();
    repliesW = replies.mapIndexed((index, element) {
      LMUserViewData user = users[element.userId]!;
      return StatefulBuilder(builder: (context, setReplyState) {
        return LMReplyTile(
            comment: element,
            onTagTap: (String userId) {
              LMFeedIntegration.instance.lmFeedClient.routeToProfile(userId);
            },
            user: user,
            profilePicture: LMProfilePicture(
              imageUrl: user.imageUrl,
              backgroundColor: LMThemeData.kPrimaryColor,
              fallbackText: user.name,
              onTap: () {
                if (user.sdkClientInfo != null) {
                  LMFeedIntegration.instance.lmFeedClient
                      .routeToProfile(user.sdkClientInfo!.userUniqueId);
                }
              },
              size: 32,
            ),
            subtitleText: LMTextView(
              text:
                  "@${user.name.toLowerCase().split(' ').join()} · ${timeago.format(element.createdAt)}",
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: LMThemeData.kGreyColor,
              ),
            ),
            onMenuTap: (value) async {
              if (value == commentDeleteId) {
                _commentHandlerBloc!.add(LMCommentCancelEvent());

                showDialog(
                    context: context,
                    builder: (childContext) => LMDeleteConfirmationDialog(
                        title: 'Delete Comment',
                        userId: element.userId,
                        content:
                            'Are you sure you want to delete this comment. This action can not be reversed.',
                        action: (String reason) async {
                          Navigator.of(childContext).pop();
                          //Implement delete post analytics tracking
                          DeleteCommentRequest request =
                              (DeleteCommentRequestBuilder()
                                    ..postId(postId)
                                    ..commentId(element.id)
                                    ..reason(reason.isEmpty
                                        ? "Reason for deletion"
                                        : reason))
                                  .build();

                          LMCommentMetaData commentMetaData =
                              (LMCommentMetaDataBuilder()
                                    ..commentId(widget.reply.id)
                                    ..commentActionEntity(LMCommentType.reply)
                                    ..commentActionType(
                                        LMCommentActionType.delete)
                                    ..level(1)
                                    ..replyId(element.id))
                                  .build();

                          _commentHandlerBloc!.add(LMCommentActionEvent(
                              commentActionRequest: request,
                              commentMetaData: commentMetaData));
                        },
                        actionText: 'Delete'));
              } else if (value == commentEditId) {
                _commentHandlerBloc!.add(LMCommentCancelEvent());
                LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
                      ..commentId(widget.reply.parentComment!.id)
                      ..commentActionEntity(LMCommentType.reply)
                      ..commentActionType(LMCommentActionType.edit)
                      ..level(1)
                      ..replyId(element.id))
                    .build();

                _commentHandlerBloc!.add(
                    LMCommentOngoingEvent(commentMetaData: commentMetaData));
              }
            },
            commentActions: [
              LMTextButton(
                text: LMTextView(
                  text: element.likesCount == 0
                      ? "Like"
                      : element.likesCount == 1
                          ? "1 Like"
                          : "${element.likesCount} Likes",
                  textStyle: const TextStyle(fontSize: 12),
                ),
                activeText: LMTextView(
                  text: element.likesCount == 0
                      ? "Like"
                      : element.likesCount == 1
                          ? "1 Like"
                          : "${element.likesCount} Likes",
                  textStyle: TextStyle(
                    color: LMThemeData.suraasaTheme.colorScheme.primary,
                    fontSize: 12,
                  ),
                ),
                onTap: () async {
                  setReplyState(() {
                    if (element.isLiked) {
                      element.likesCount -= 1;
                    } else {
                      element.likesCount += 1;
                    }
                    element.isLiked = !element.isLiked;
                  });

                  ToggleLikeCommentRequest request =
                      (ToggleLikeCommentRequestBuilder()
                            ..commentId(element.id)
                            ..postId(widget.postId))
                          .build();

                  ToggleLikeCommentResponse response = await LMFeedIntegration
                      .instance.lmFeedClient
                      .toggleLikeComment(request);

                  if (!response.success) {
                    setReplyState(() {
                      if (element.isLiked) {
                        element.likesCount -= 1;
                      } else {
                        element.likesCount += 1;
                      }
                      element.isLiked = !element.isLiked;
                    });
                  }
                },
                icon: const LMIcon(
                  type: LMIconType.svg,
                  assetPath: kAssetLikeIcon,
                  size: 20,
                ),
                activeIcon: const LMIcon(
                  type: LMIconType.svg,
                  assetPath: kAssetLikeFilledIcon,
                  size: 20,
                ),
                isActive: element.isLiked,
              ),
              const SizedBox(width: 8),
            ]);
      });
    }).toList();
    if (replies.isNotEmpty &&
        replies.length % 10 == 0 &&
        replies.length != reply!.repliesCount) {
      repliesW = [
        ...repliesW,
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            TextButton(
              onPressed: () {
                page++;
                _commentRepliesBloc!.add(GetCommentReplies(
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
        )
      ];
      // replies.add();
    }
    return repliesW;
  }

  @override
  Widget build(BuildContext context) {
    _commentHandlerBloc = LMCommentHandlerBloc.instance;
    _commentRepliesBloc = LMFetchCommentReplyBloc.instance;
    initialiseReply();
    return ValueListenableBuilder(
      valueListenable: rebuildReplyList,
      builder: (context, _, __) {
        return BlocConsumer(
          bloc: _commentRepliesBloc,
          buildWhen: (previous, current) {
            if (current is CommentRepliesLoaded &&
                current.commentId != reply!.id) {
              return false;
            }
            if (current is PaginatedCommentRepliesLoading &&
                current.commentId != reply!.id) {
              return false;
            }
            if (current is CommentRepliesLoading &&
                current.commentId != widget.reply.id) {
              return false;
            }
            return true;
          },
          builder: ((context, state) {
            if (state is ClearedCommentReplies) {
              replies = [];
              users = {};
              repliesW = [];
              return const SizedBox();
            }
            if (state is CommentRepliesLoading) {
              if (state.commentId == widget.reply.id) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
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
            if (state is CommentRepliesLoaded ||
                state is PaginatedCommentRepliesLoading) {
              // replies.addAll(state.commentDetails.postReplies.replies);
              if (state is CommentRepliesLoaded &&
                  state.commentId != reply!.id) {
                return const SizedBox();
              }
              if (state is PaginatedCommentRepliesLoading &&
                  state.commentId != reply!.id) {
                return const SizedBox();
              }

              if (state is CommentRepliesLoaded) {
                replies = state.commentDetails.postReplies!.replies
                        ?.map((e) => CommentViewDataConvertor.fromComment(e))
                        .toList() ??
                    [];
                users = state.commentDetails.users!.map((key, value) =>
                    MapEntry(key, UserViewDataConvertor.fromUser(value)));
                users.putIfAbsent(user.userUniqueId, () => user);
              } else if (state is PaginatedCommentRepliesLoading) {
                replies = state.prevCommentDetails.postReplies!.replies
                        ?.map((e) => CommentViewDataConvertor.fromComment(e))
                        .toList() ??
                    [];
                users = state.prevCommentDetails.users!.map((key, value) =>
                    MapEntry(key, UserViewDataConvertor.fromUser(value)));
                users.putIfAbsent(user.userUniqueId, () => user);
              }

              repliesW = mapRepliesToWidget(replies, users);
            }
            return BlocConsumer<LMCommentHandlerBloc, LMCommentHandlerState>(
              bloc: _commentHandlerBloc,
              listener: (context, state) {
                if (state.runtimeType ==
                    LMCommentSuccessState<AddCommentReplyResponse>) {
                  if ((state as LMCommentSuccessState<AddCommentReplyResponse>)
                              .commentMetaData
                              .commentActionType ==
                          LMCommentActionType.add &&
                      state.commentMetaData.commentActionEntity ==
                          LMCommentType.reply) {
                    AddCommentReplyResponse response =
                        state.commentActionResponse;
                    if (response.reply!.parentComment!.id == reply!.id) {
                      replies.insert(
                          0,
                          CommentViewDataConvertor.fromComment(
                              response.reply!));

                      repliesW = mapRepliesToWidget(replies, users);
                      rebuildReplyList.value = !rebuildReplyList.value;
                    }
                  }
                }
                if (state.runtimeType ==
                    LMCommentSuccessState<EditCommentReplyResponse>) {
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
                      replies[index] =
                          CommentViewDataConvertor.fromComment(response.reply!);

                      repliesW = mapRepliesToWidget(replies, users);

                      rebuildReplyList.value = !rebuildReplyList.value;
                    }
                  }
                }
                if (state.runtimeType ==
                    LMCommentSuccessState<DeleteCommentResponse>) {
                  if ((state as LMCommentSuccessState<DeleteCommentResponse>)
                              .commentMetaData
                              .commentActionType ==
                          LMCommentActionType.delete &&
                      state.commentMetaData.commentActionEntity ==
                          LMCommentType.reply) {
                    DeleteCommentResponse response =
                        state.commentActionResponse;
                    int index = replies.indexWhere((element) =>
                        element.id == state.commentMetaData.replyId);
                    if (index != -1) {
                      replies.removeAt(index);
                      reply!.repliesCount -= 1;
                      replyCount = reply!.repliesCount;
                      rebuildReplyButton.value = !rebuildReplyButton.value;

                      repliesW = mapRepliesToWidget(replies, users);
                      rebuildReplyList.value = !rebuildReplyList.value;
                    }
                  }
                }
              },
              builder: (context, state) {
                return Container(
                  padding: const EdgeInsets.only(
                    left: 48,
                    bottom: 0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: repliesW,
                  ),
                );
              },
            );
          }),
          listener: (context, state) {
            List<LMCommentViewData> replies = [];
            if (state is CommentRepliesLoaded) {
              replies = state.commentDetails.postReplies!.replies
                      ?.map((e) => CommentViewDataConvertor.fromComment(e))
                      .toList() ??
                  [];
            } else if (state is PaginatedCommentRepliesLoading) {
              replies = state.prevCommentDetails.postReplies!.replies
                      ?.map((e) => CommentViewDataConvertor.fromComment(e))
                      .toList() ??
                  [];
            }
            replyCount = replies.length;
            rebuildReplyButton.value = !rebuildReplyButton.value;
          },
        );
      },
    );
  }
}
