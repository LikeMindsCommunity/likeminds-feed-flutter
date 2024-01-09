import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/model_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_driver_fl/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_driver_fl/src/views/post/widgets/comment/comment_reply_widget.dart';
import 'package:likeminds_feed_driver_fl/src/views/post/widgets/comment/default_empty_comment_widget.dart';
import 'package:likeminds_feed_driver_fl/src/views/post/handler/post_detail_screen_handler.dart';
import 'package:likeminds_feed_driver_fl/src/views/post/widgets/delete_dialog.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

/// {@template post_detail_screen}
/// A screen that displays a post in detail
/// with comments and likes
/// {@endtemplate}
class LMFeedPostDetailScreen extends StatefulWidget {
  ///{@macro post_detail_screen}
  const LMFeedPostDetailScreen({
    super.key,
    required this.postId,
    this.postBuilder,
    this.appBarBuilder,
    this.commentBuilder,
    this.bottomTextFieldBuilder,
    this.isFeed = false,
    this.onPostTap,
    this.onLikeClick,
    this.onCommentClick,
    this.postWidget,
  });
  // Required variables
  final String postId;

  final Function()? onPostTap;
  final Function()? onLikeClick;
  final Function()? onCommentClick;

  // Optional variables
  // In case the below props are not provided,
  // the default in each case will be used
  /// {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;

  final LMFeedPostWidget? postWidget;

  /// {@macro post_appbar_builder}
  final LMFeedPostAppBarBuilder? appBarBuilder;

  /// {@macro post_comment_builder}
  final LMFeedPostCommentBuilder? commentBuilder;

  final Widget Function(BuildContext, LMPostViewData)? bottomTextFieldBuilder;

  final bool isFeed;

  @override
  State<LMFeedPostDetailScreen> createState() => _LMFeedPostDetailScreenState();
}

class _LMFeedPostDetailScreenState extends State<LMFeedPostDetailScreen> {
  final PagingController<int, LMCommentViewData> _pagingController =
      PagingController(firstPageKey: 1);
  final LMFeedFetchCommentReplyBloc _commentRepliesBloc =
      LMFeedFetchCommentReplyBloc.instance;
  LMFeedPostDetailScreenHandler? _postDetailScreenHandler;
  Future<LMPostViewData?>? getPostData;
  LMUserViewData currentUser = LMUserViewDataConvertor.fromUser(
      LMFeedUserLocalPreference.instance.fetchUserData());
  LMPostViewData? postData;
  String? commentIdReplyId;
  bool replyShown = false;

  bool right = true;
  List<LMUserTagViewData> userTags = [];

  @override
  void initState() {
    super.initState();
    _postDetailScreenHandler =
        LMFeedPostDetailScreenHandler(_pagingController, widget.postId);
    getPostData =
        _postDetailScreenHandler!.fetchCommentListWithPage(1).then((value) {
      postData = value;
      _postDetailScreenHandler!.rebuildPostWidget.value =
          !_postDetailScreenHandler!.rebuildPostWidget.value;
      return value;
    });
    right = _postDetailScreenHandler!.checkCommentRights();
  }

  @override
  void didUpdateWidget(covariant LMFeedPostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      _pagingController.itemList?.clear();
      _pagingController.refresh();
      _postDetailScreenHandler =
          LMFeedPostDetailScreenHandler(_pagingController, widget.postId);
      getPostData =
          _postDetailScreenHandler!.fetchCommentListWithPage(1).then((value) {
        postData = value;
        _postDetailScreenHandler!.rebuildPostWidget.value =
            !_postDetailScreenHandler!.rebuildPostWidget.value;
        return value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LMThemeData.theme,
      child: RefreshIndicator(
        onRefresh: () {
          _pagingController.itemList?.clear();
          _pagingController.refresh();
          _commentRepliesBloc.add(LMFeedClearCommentRepliesEvent());
          return Future.value();
        },
        child: FutureBuilder<LMPostViewData?>(
          future: getPostData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                snapshot.hasData) {
              return Scaffold(
                resizeToAvoidBottomInset: true,
                backgroundColor: LMThemeData.kWhiteColor,
                bottomSheet: widget.bottomTextFieldBuilder != null
                    ? widget.bottomTextFieldBuilder!(context, postData!)
                    : SafeArea(
                        child: BlocBuilder<LMFeedCommentHandlerBloc,
                            LMFeedCommentHandlerState>(
                          bloc: _postDetailScreenHandler!.commentHandlerBloc,
                          builder: (context, state) => Container(
                            decoration: BoxDecoration(
                              color: LMThemeData.kWhiteColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  offset: const Offset(0, -5),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                LMThemeData.kVerticalPaddingMedium,
                                state is LMFeedCommentActionOngoingState
                                    ? Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 16, vertical: 8),
                                        child: Row(
                                          children: [
                                            LMFeedText(
                                              text: state.commentMetaData
                                                          .commentActionType ==
                                                      LMFeedCommentActionType
                                                          .edit
                                                  ? "Editing ${state.commentMetaData.replyId != null ? 'reply' : 'comment'}"
                                                  : "Replying to",
                                              style: const LMFeedTextStyle(
                                                textStyle: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                  color:
                                                      LMThemeData.kGrey1Color,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            state.commentMetaData
                                                        .commentActionType ==
                                                    LMFeedCommentActionType.edit
                                                ? const SizedBox()
                                                : LMFeedText(
                                                    text: state.commentMetaData
                                                        .user!.name,
                                                    style:
                                                        const LMFeedTextStyle(
                                                      textStyle: TextStyle(
                                                        fontSize: 14,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        color: LMThemeData
                                                            .kLinkColor,
                                                      ),
                                                    ),
                                                  ),
                                            const Spacer(),
                                            LMFeedButton(
                                              onTap: () {
                                                _postDetailScreenHandler!
                                                    .commentHandlerBloc
                                                    .add(
                                                        LMFeedCommentCancelEvent());
                                              },
                                              icon: const LMFeedIcon(
                                                type: LMFeedIconType.icon,
                                                icon: Icons.close,
                                                style: LMFeedIconStyle(
                                                  color: LMThemeData.kGreyColor,
                                                  size: 24,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                Container(
                                  decoration: BoxDecoration(
                                      color: LMThemeData.kPrimaryColor
                                          .withOpacity(0.04),
                                      borderRadius: BorderRadius.circular(24)),
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  padding: const EdgeInsets.all(3.0),
                                  child: Row(
                                    children: [
                                      LMFeedProfilePicture(
                                        fallbackText: currentUser.name,
                                        imageUrl: currentUser.imageUrl,
                                        backgroundColor:
                                            LMThemeData.kPrimaryColor,
                                        onTap: () {
                                          if (currentUser.sdkClientInfo !=
                                              null) {
                                            LMFeedCore.instance.lmFeedClient
                                                .routeToProfile(currentUser
                                                    .sdkClientInfo!
                                                    .userUniqueId);
                                          }
                                        },
                                        size: 36,
                                      ),
                                      Expanded(
                                        child: LMTaggingAheadTextField(
                                          isDown: false,
                                          maxLines: 5,
                                          onTagSelected: (tag) {
                                            userTags.add(tag);
                                          },
                                          controller: _postDetailScreenHandler!
                                              .commentController,
                                          decoration: InputDecoration(
                                            enabled: right,
                                            border: InputBorder.none,
                                            hintText: right
                                                ? 'Write a comment'
                                                : "You do not have permission to comment.",
                                          ),
                                          focusNode: _postDetailScreenHandler!
                                              .focusNode,
                                          onChange: (String p0) {},
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8.0),
                                        child: !right
                                            ? null
                                            : state is LMFeedCommentLoadingState
                                                ? const SizedBox(
                                                    height: 15,
                                                    width: 15,
                                                    child: LMFeedLoader(
                                                      color: LMThemeData
                                                          .kPrimaryColor,
                                                    ),
                                                  )
                                                : LMFeedButton(
                                                    style:
                                                        const LMFeedButtonStyle(
                                                      height: 18,
                                                    ),
                                                    text: const LMFeedText(
                                                      text: "Post",
                                                      style: LMFeedTextStyle(
                                                        textAlign:
                                                            TextAlign.center,
                                                        textStyle: TextStyle(
                                                          fontSize: 12.5,
                                                          color: LMThemeData
                                                              .kPrimaryColor,
                                                        ),
                                                      ),
                                                    ),
                                                    onTap: () {
                                                      _postDetailScreenHandler!
                                                          .closeOnScreenKeyboard();
                                                      String commentText =
                                                          LMFeedTaggingHelper
                                                              .encodeString(
                                                        _postDetailScreenHandler!
                                                            .commentController
                                                            .text,
                                                        userTags,
                                                      );
                                                      commentText =
                                                          commentText.trim();
                                                      if (commentText.isEmpty) {
                                                        toast(
                                                            "Please write something to post");

                                                        return;
                                                      }

                                                      _postDetailScreenHandler!
                                                          .users
                                                          .putIfAbsent(
                                                              currentUser
                                                                  .userUniqueId,
                                                              () =>
                                                                  currentUser);

                                                      if (state
                                                          is LMFeedCommentActionOngoingState) {
                                                        if (state
                                                                .commentMetaData
                                                                .commentActionType ==
                                                            LMFeedCommentActionType
                                                                .edit) {
                                                          LMCommentMetaData
                                                              commentMetaData =
                                                              (LMCommentMetaDataBuilder()
                                                                    ..commentActionEntity(
                                                                        LMFeedCommentType
                                                                            .parent)
                                                                    ..level(0)
                                                                    ..commentId(state
                                                                        .commentMetaData
                                                                        .commentId!)
                                                                    ..commentActionType(
                                                                        LMFeedCommentActionType
                                                                            .edit))
                                                                  .build();
                                                          EditCommentRequest
                                                              editCommentRequest =
                                                              (EditCommentRequestBuilder()
                                                                    ..postId(widget
                                                                        .postId)
                                                                    ..commentId(state
                                                                        .commentMetaData
                                                                        .commentId!)
                                                                    ..text(
                                                                        commentText))
                                                                  .build();

                                                          _postDetailScreenHandler!
                                                              .commentHandlerBloc
                                                              .add(LMFeedCommentActionEvent(
                                                                  commentActionRequest:
                                                                      editCommentRequest,
                                                                  commentMetaData:
                                                                      commentMetaData));
                                                        } else if (state
                                                                .commentMetaData
                                                                .commentActionType ==
                                                            LMFeedCommentActionType
                                                                .replying) {
                                                          LMCommentMetaData
                                                              commentMetaData =
                                                              (LMCommentMetaDataBuilder()
                                                                    ..commentActionEntity(
                                                                        LMFeedCommentType
                                                                            .reply)
                                                                    ..level(0)
                                                                    ..commentId(state
                                                                        .commentMetaData
                                                                        .commentId!)
                                                                    ..commentActionType(
                                                                        LMFeedCommentActionType
                                                                            .replying))
                                                                  .build();
                                                          AddCommentReplyRequest
                                                              addReplyRequest =
                                                              (AddCommentReplyRequestBuilder()
                                                                    ..postId(widget
                                                                        .postId)
                                                                    ..text(
                                                                        commentText)
                                                                    ..commentId(state
                                                                        .commentMetaData
                                                                        .commentId!))
                                                                  .build();

                                                          _postDetailScreenHandler!
                                                              .commentHandlerBloc
                                                              .add(LMFeedCommentActionEvent(
                                                                  commentActionRequest:
                                                                      addReplyRequest,
                                                                  commentMetaData:
                                                                      commentMetaData));
                                                        }
                                                      } else {
                                                        LMCommentMetaData
                                                            commentMetaData =
                                                            (LMCommentMetaDataBuilder()
                                                                  ..commentActionEntity(
                                                                      LMFeedCommentType
                                                                          .parent)
                                                                  ..level(0)
                                                                  ..commentActionType(
                                                                      LMFeedCommentActionType
                                                                          .add))
                                                                .build();
                                                        AddCommentRequest
                                                            addCommentRequest =
                                                            (AddCommentRequestBuilder()
                                                                  ..postId(widget
                                                                      .postId)
                                                                  ..text(
                                                                      commentText))
                                                                .build();

                                                        _postDetailScreenHandler!
                                                            .commentHandlerBloc
                                                            .add(LMFeedCommentActionEvent(
                                                                commentActionRequest:
                                                                    addCommentRequest,
                                                                commentMetaData:
                                                                    commentMetaData));
                                                      }

                                                      _postDetailScreenHandler!
                                                          .closeOnScreenKeyboard();
                                                      _postDetailScreenHandler!
                                                          .commentController
                                                          .clear();
                                                    },
                                                  ),
                                      ),
                                    ],
                                  ),
                                ),
                                LMThemeData.kVerticalPaddingLarge,
                              ],
                            ),
                          ),
                        ),
                      ),
                appBar: widget.appBarBuilder == null
                    ? defAppBar()
                    : widget.appBarBuilder!(context, defAppBar()),
                body: CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: ValueListenableBuilder(
                        valueListenable:
                            _postDetailScreenHandler!.rebuildPostWidget,
                        builder: (context, _, __) {
                          return widget.postBuilder
                                  ?.call(context, defPostWidget(), postData!) ??
                              defPostWidget();
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 16,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: BlocConsumer<LMFeedCommentHandlerBloc,
                          LMFeedCommentHandlerState>(
                        bloc: _postDetailScreenHandler!.commentHandlerBloc,
                        listener: (context, state) {
                          _postDetailScreenHandler!.handleBlocChanges(state);
                        },
                        builder: (context, state) {
                          return ValueListenableBuilder(
                            valueListenable:
                                _postDetailScreenHandler!.rebuildPostWidget,
                            builder: (context, _, __) {
                              return PagedListView.separated(
                                pagingController: _postDetailScreenHandler!
                                    .commetListPagingController,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                builderDelegate: PagedChildBuilderDelegate<
                                    LMCommentViewData>(
                                  firstPageProgressIndicatorBuilder: (context) {
                                    return Container(
                                      color: LMThemeData.kWhiteColor,
                                      padding: const EdgeInsets.all(20.0),
                                      child: const Center(
                                        child: CircularProgressIndicator
                                            .adaptive(),
                                      ),
                                    );
                                  },
                                  noItemsFoundIndicatorBuilder: (context) =>
                                      const LMFeedEmptyCommentWidget(),
                                  itemBuilder:
                                      (context, commentViewData, index) {
                                    LMUserViewData userViewData;
                                    if (!_postDetailScreenHandler!.users
                                        .containsKey(commentViewData.userId)) {
                                      return const SizedBox.shrink();
                                    }
                                    userViewData = _postDetailScreenHandler!
                                        .users[commentViewData.userId]!;

                                    return SizedBox(
                                      child: Column(
                                        children: [
                                          widget.commentBuilder?.call(
                                                  context,
                                                  defCommentTile(
                                                      commentViewData,
                                                      userViewData),
                                                  postData!) ??
                                              defCommentTile(commentViewData,
                                                  userViewData),
                                          (replyShown &&
                                                  commentIdReplyId ==
                                                      commentViewData.id)
                                              ? LMFeedCommentReplyWidget(
                                                  refresh: () {
                                                    _pagingController.refresh();
                                                  },
                                                  postId: widget.postId,
                                                  reply: commentViewData,
                                                  user:
                                                      _postDetailScreenHandler!
                                                              .users[
                                                          commentViewData
                                                              .userId]!,
                                                )
                                              : const SizedBox.shrink()
                                        ],
                                      ),
                                    );
                                  },
                                ),
                                padding: EdgeInsets.zero,
                                separatorBuilder: (context, index) =>
                                    const Divider(
                                  thickness: 0.2,
                                  height: 0,
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 100,
                      ),
                    ),
                  ],
                ),
              );
            } else if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator.adaptive(),
                ),
              );
            } else if (snapshot.hasError) {
              return Scaffold(
                body: Center(
                  child: Text(
                    '${snapshot.error}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  LMFeedMenuAction defLMFeedMenuAction(LMCommentViewData commentViewData) =>
      LMFeedMenuAction(
        onCommentEdit: () {
          debugPrint('Editing functionality');
          LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
                ..commentActionEntity(LMFeedCommentType.parent)
                ..commentActionType(LMFeedCommentActionType.edit)
                ..level(0)
                ..commentId(commentViewData.id))
              .build();

          _postDetailScreenHandler!.commentHandlerBloc.add(
            LMFeedCommentOngoingEvent(commentMetaData: commentMetaData),
          );
        },
        onCommentDelete: () {
          showDialog(
            context: context,
            builder: (childContext) => LMFeedDeleteConfirmationDialog(
              title: 'Delete Comment',
              userId: commentViewData.userId,
              content:
                  'Are you sure you want to delete this post. This action can not be reversed.',
              action: (String reason) async {
                Navigator.of(childContext).pop();

                LMFeedAnalyticsBloc.instance.add(
                  LMFeedFireAnalyticsEvent(
                    eventName: LMFeedAnalyticsKeys.commentDeleted,
                    eventProperties: {
                      "post_id": widget.postId,
                      "comment_id": commentViewData.id,
                    },
                  ),
                );

                DeleteCommentRequest deleteCommentRequest =
                    (DeleteCommentRequestBuilder()
                          ..postId(widget.postId)
                          ..commentId(commentViewData.id)
                          ..reason(
                              reason.isEmpty ? "Reason for deletion" : reason))
                        .build();

                LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
                      ..commentActionEntity(LMFeedCommentType.parent)
                      ..commentActionType(LMFeedCommentActionType.delete)
                      ..level(0)
                      ..commentId(commentViewData.id))
                    .build();

                _postDetailScreenHandler!.commentHandlerBloc.add(
                    LMFeedCommentActionEvent(
                        commentActionRequest: deleteCommentRequest,
                        commentMetaData: commentMetaData));
              },
              actionText: 'Delete',
            ),
          );
        },
      );

  LMFeedAppBar defAppBar() {
    return LMFeedAppBar(
      leading: LMFeedButton(
        icon: LMFeedIcon(
          type: LMFeedIconType.icon,
          icon: Platform.isAndroid
              ? Icons.arrow_back
              : CupertinoIcons.chevron_back,
          style: const LMFeedIconStyle(
            size: 28,
            color: LMThemeData.appBlack,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
      backgroundColor: LMThemeData.kWhiteColor,
      title: const LMFeedText(
          text: "Comments",
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: LMThemeData.kHeadingColor,
            ),
          )),
      mainAxisAlignment: Platform.isAndroid
          ? MainAxisAlignment.start
          : MainAxisAlignment.spaceBetween,
    );
  }

  LMFeedPostWidget defPostWidget() {
    return widget.postWidget ??
        LMFeedPostWidget(
          post: postData!,
          user: _postDetailScreenHandler!.users[postData!.userId]!,
          topics: _postDetailScreenHandler!.topics,
          onPostTap: (context, post) {
            debugPrint("Post in detail screen tapped");
            widget.onPostTap?.call();
          },
          isFeed: false,
          onTagTap: (tag) {},
          footerBuilder: (context, post, postViewData) {
            return LMFeedPostFooter(
                // alignment: LMFeedAlignment.centre,
                // children: [
                //   LMTextButton(
                //     text: const LMFeedText(
                //         text: "Like"),
                //     margin: 0,
                //     activeText: const LMFeedText(
                //       text: "Like",
                //       textStyle: TextStyle(
                //         color: LMThemeData.primary500,
                //       ),
                //     ),
                //     onTap: () async {
                //       if (postData!.isLiked) {
                //         postData!.likeCount -= 1;
                //         postData!.isLiked = false;
                //       } else {
                //         postData!.likeCount += 1;
                //         postData!.isLiked = true;
                //       }

                //       _postDetailScreenHandler!
                //               .rebuildPostWidget
                //               .value =
                //           !_postDetailScreenHandler!
                //               .rebuildPostWidget
                //               .value;

                //       final response = await LMFeedCore
                //           .instance.lmFeedClient
                //           .likePost(
                //               (LikePostRequestBuilder()
                //                     ..postId(
                //                         postData!.id))
                //                   .build());

                //       if (!response.success) {
                //         toast(
                //           response.errorMessage ??
                //               "There was an error liking the post",
                //           duration: Toast.LENGTH_LONG,
                //         );

                //         if (postData!.isLiked) {
                //           postData!.likeCount -= 1;
                //           postData!.isLiked = false;
                //         } else {
                //           postData!.likeCount += 1;
                //           postData!.isLiked = true;
                //         }

                //         _postDetailScreenHandler!
                //                 .rebuildPostWidget
                //                 .value =
                //             !_postDetailScreenHandler!
                //                 .rebuildPostWidget
                //                 .value;
                //       } else {
                //         LMPostBloc.instance.add(
                //           LMUpdatePost(
                //             post: postData!,
                //           ),
                //         );
                //       }
                //       widget.onLikeClick?.call();
                //     },
                //     icon: const LMFeedIcon(
                //       type: LMFeedIconType.icon,
                //       icon: Icons
                //           .thumb_up_off_alt_outlined,
                //       color: LMThemeData
                //           .kSecondaryColor700,
                //       size: 20,
                //       boxPadding: 6,
                //     ),
                //     activeIcon: const LMFeedIcon(
                //       type: LMFeedIconType.icon,
                //       icon: Icons.thumb_up,
                //       size: 20,
                //       boxPadding: 6,
                //       color:
                //           LMThemeData.kPrimaryColor,
                //     ),
                //     isActive: postData!.isLiked,
                //   ),
                //   const Spacer(),
                //   LMTextButton(
                //     text: const LMFeedText(
                //         text: "Comment"),
                //     margin: 0,
                //     onTap: () {
                //       if (widget.isFeed) {
                //         LMFeedAnalyticsBloc.instance.add(
                //             LMFeedFireAnalyticsEvent(
                //                 eventName:
                //                     LMAnalyticsKeys
                //                         .commentListOpen,
                //                 eventProperties: {
                //               'postId': postData!.id,
                //             }));
                //         Navigator.push(
                //           context,
                //           MaterialPageRoute(
                //             builder: (context) =>
                //                 LMPostDetailScreen(
                //               postId: postData!.id,
                //             ),
                //           ),
                //         );
                //       } else {
                //         _postDetailScreenHandler!
                //             .openOnScreenKeyboard();
                //       }
                //     },
                //     icon: const LMFeedIcon(
                //       type: LMFeedIconType.icon,
                //       icon: Icons.comment_outlined,
                //       color: LMThemeData
                //           .kSecondaryColor700,
                //       size: 20,
                //       boxPadding: 6,
                //     ),
                //   ),
                //   const Spacer(),
                //   LMFeedButton(
                //     text: const LMFeedText(
                //         text: "Share"),
                //     margin: 0,
                //     onTap: () {
                //       String? postType = postData!
                //                       .attachments ==
                //                   null ||
                //               postData!.attachments!
                //                   .isEmpty
                //           ? 'text'
                //           : getPostType(postData!
                //                   .attachments
                //                   ?.first
                //                   .attachmentType ??
                //               0);

                //       LMFeedAnalyticsBloc.instance
                //           .add(LMFeedFireAnalyticsEvent(
                //         eventName: LMAnalyticsKeys
                //             .postShared,
                //         eventProperties: {
                //           "post_id": postData!.id,
                //           "post_type": postType,
                //           "user_id": currentUser
                //               .userUniqueId,
                //         },
                //       ));
                //       // TODO: Add Share Post logic
                //       //SharePost().sharePost(postData!.id);
                //     },
                //     icon: const LMFeedIcon(
                //       type: LMFeedIconType.icon,
                //       icon: Icons.share,
                //       color: LMThemeData
                //           .kSecondaryColor700,
                //       size: 20,
                //       boxPadding: 6,
                //     ),
                //   ),
                // ],
                // children: [

                // ],
                );
          },
          boxShadow: const [
            BoxShadow(
              color: Color(0x19000000),
              blurRadius: 5,
              offset: Offset(1, 1),
              spreadRadius: 0,
            )
          ],
        );
  }

  LMFeedCommentTile defCommentTile(
      LMCommentViewData commentViewData, LMUserViewData userViewData) {
    return LMFeedCommentTile(
      user: userViewData,
      comment: commentViewData,
      padding: const EdgeInsets.all(16.0),
      lmFeedMenuAction: defLMFeedMenuAction(commentViewData),
      profilePicture: LMFeedProfilePicture(
        backgroundColor: LMThemeData.kPrimaryColor,
        fallbackText:
            _postDetailScreenHandler!.users[commentViewData.userId]!.name,
        onTap: () {
          if (_postDetailScreenHandler!
                  .users[commentViewData.userId]!.sdkClientInfo !=
              null) {
            LMFeedCore.instance.lmFeedClient.routeToProfile(
                _postDetailScreenHandler!.users[commentViewData.userId]!
                    .sdkClientInfo!.userUniqueId);
          }
        },
        imageUrl:
            _postDetailScreenHandler!.users[commentViewData.userId]!.imageUrl,
        size: 36,
      ),
      subtitleText: LMFeedText(
        text:
            "@${_postDetailScreenHandler!.users[commentViewData.userId]!.name.toLowerCase().split(' ').join()} · ", //${timeago.format(commentViewData.createdAt)}",

        style: const LMFeedTextStyle(
          textStyle: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: LMThemeData.kSecondaryColor700,
          ),
        ),
      ),
      likeButton: defCommentLikeButton(commentViewData),
      replyButton: defCommentReplyButton(commentViewData),
      showRepliesButton: defCommentShowRepliesButton(commentViewData),
      actionsPadding: const EdgeInsets.only(left: 48),
      onTagTap: (String userId) {
        LMFeedCore.instance.lmFeedClient.routeToProfile(userId);
      },
    );
  }

  LMFeedButton defCommentLikeButton(LMCommentViewData commentViewData) {
    return LMFeedButton(
      style: const LMFeedButtonStyle(
        margin: 10,
      ),
      text: LMFeedText(
        text: commentViewData.likesCount == 0
            ? "Like"
            : commentViewData.likesCount == 1
                ? "1 Like"
                : "${commentViewData.likesCount} Likes",
        style: const LMFeedTextStyle(
          textStyle:
              TextStyle(color: LMThemeData.kSecondaryColor700, fontSize: 12),
        ),
      ),
      activeText: LMFeedText(
        text: commentViewData.likesCount == 0
            ? "Like"
            : commentViewData.likesCount == 1
                ? "1 Like"
                : "${commentViewData.likesCount} Likes",
        style: const LMFeedTextStyle(
          textStyle: TextStyle(color: LMThemeData.kPrimaryColor, fontSize: 12),
        ),
      ),
      onTap: () async {
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
        }
      },
      icon: const LMFeedIcon(
        type: LMFeedIconType.icon,
        icon: Icons.thumb_up_alt_outlined,
        style: LMFeedIconStyle(
          size: 20,
        ),
      ),
      activeIcon: const LMFeedIcon(
        type: LMFeedIconType.icon,
        style: LMFeedIconStyle(
          color: LMThemeData.kPrimaryColor,
          size: 20,
        ),
        icon: Icons.thumb_up_alt_rounded,
      ),
      isActive: commentViewData.isLiked,
    );
  }

  LMFeedButton defCommentReplyButton(LMCommentViewData commentViewData) {
    return LMFeedButton(
      style: const LMFeedButtonStyle(
        margin: 10,
      ),
      text: const LMFeedText(
        text: "Reply",
        style: LMFeedTextStyle(
            textStyle: TextStyle(
          fontSize: 12,
        )),
      ),
      onTap: () {
        LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
              ..commentActionEntity(LMFeedCommentType.parent)
              ..commentActionType(LMFeedCommentActionType.replying)
              ..level(0)
              ..user(_postDetailScreenHandler!.users[commentViewData.userId]!)
              ..commentId(commentViewData.id))
            .build();

        _postDetailScreenHandler!.commentHandlerBloc
            .add(LMFeedCommentOngoingEvent(commentMetaData: commentMetaData));

        _postDetailScreenHandler!.openOnScreenKeyboard();
      },
      icon: const LMFeedIcon(
        type: LMFeedIconType.icon,
        icon: Icons.comment_outlined,
        style: LMFeedIconStyle(
          size: 20,
        ),
      ),
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
        style: const LMFeedTextStyle(
          textStyle: TextStyle(
            color: LMThemeData.kPrimaryColor,
          ),
        ),
      ),
    );
  }
}
