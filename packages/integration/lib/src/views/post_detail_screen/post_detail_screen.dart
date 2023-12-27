import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/comment/comment_handler/comment_handler_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/comment/comment_replies/comment_replies_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/post_bloc/post_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/model_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/analytics/keys.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/assets_constants.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/post_action_id.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/ui_constants.dart';
import 'package:likeminds_feed_driver_fl/src/utils/post/post_utils.dart';
import 'package:likeminds_feed_driver_fl/src/utils/tagging/tagging_textfield_ta.dart';
import 'package:likeminds_feed_driver_fl/src/views/post_detail_screen/handler/post_detail_screen_handler.dart';
import 'package:likeminds_feed_driver_fl/src/views/post_detail_screen/widgets/comment/comment_reply_widget.dart';
import 'package:likeminds_feed_driver_fl/src/views/post_detail_screen/widgets/comment/default_empty_comment_widget.dart';
import 'package:likeminds_feed_driver_fl/src/views/post_detail_screen/widgets/delete_dialog.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:overlay_support/overlay_support.dart';

/// {@template post_detail_screen}
/// A screen that displays a post in detail
/// with comments and likes
/// {@endtemplate}
class LMPostDetailScreen extends StatefulWidget {
  ///{@macro post_detail_screen}
  const LMPostDetailScreen({
    super.key,
    required this.postId,
    this.postBuilder,
    this.appBarBuilder,
    this.commentBuilder,
    this.bottomTextFieldBuilder,
    this.isFeed = false,
  });
  // Required variables
  final String postId;

  // Optional variables
  // In case the below props are not provided,
  // the default in each case will be used
  /// {@macro post_widget_builder}
  final LMPostWidgetBuilder? postBuilder;

  /// {@macro post_appbar_builder}
  final LMPostAppBarBuilder? appBarBuilder;

  /// {@macro post_comment_builder}
  final LMPostCommentBuilder? commentBuilder;

  final Widget Function(BuildContext, LMPostViewData)? bottomTextFieldBuilder;

  final bool isFeed;

  @override
  State<LMPostDetailScreen> createState() => _LMPostDetailScreenState();
}

class _LMPostDetailScreenState extends State<LMPostDetailScreen> {
  final PagingController<int, LMCommentViewData> _pagingController =
      PagingController(firstPageKey: 1);
  final LMFetchCommentReplyBloc _commentRepliesBloc =
      LMFetchCommentReplyBloc.instance;
  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  PostDetailScreenHandler? _postDetailScreenHandler;
  Future<LMPostViewData?>? getPostData;
  LMUserViewData currentUser = UserViewDataConvertor.fromUser(
      UserLocalPreference.instance.fetchUserData());
  LMPostViewData? postData;

  bool right = true;
  List<LMUserTagViewData> userTags = [];

  @override
  void initState() {
    super.initState();
    _postDetailScreenHandler =
        PostDetailScreenHandler(_pagingController, widget.postId);
    getPostData =
        _postDetailScreenHandler!.fetchCommentListWithPage(1).then((value) {
      postData = value;
      rebuildPostWidget.value = !rebuildPostWidget.value;
      return value;
    });
    right = _postDetailScreenHandler!.checkCommentRights();
  }

  @override
  void didUpdateWidget(covariant LMPostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      _pagingController.itemList?.clear();
      _pagingController.refresh();
      _postDetailScreenHandler =
          PostDetailScreenHandler(_pagingController, widget.postId);
      getPostData =
          _postDetailScreenHandler!.fetchCommentListWithPage(1).then((value) {
        postData = value;
        rebuildPostWidget.value = !rebuildPostWidget.value;
        return value;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: LMThemeData.suraasaTheme,
      child: RefreshIndicator(
        onRefresh: () {
          _pagingController.itemList?.clear();
          _pagingController.refresh();
          _commentRepliesBloc.add(ClearCommentReplies());
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
                            child: BlocBuilder<LMCommentHandlerBloc,
                                LMCommentHandlerState>(
                              bloc:
                                  _postDetailScreenHandler!.commentHandlerBloc,
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
                                    state is LMCommentActionOngoingState
                                        ? Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            child: Row(
                                              children: [
                                                LMTextView(
                                                  text: state.commentMetaData
                                                              .commentActionType ==
                                                          LMCommentActionType
                                                              .edit
                                                      ? "Editing ${state.commentMetaData.replyId != null ? 'reply' : 'comment'}"
                                                      : "Replying to",
                                                  textStyle: const TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.w500,
                                                    color:
                                                        LMThemeData.kGrey1Color,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 8,
                                                ),
                                                state.commentMetaData
                                                            .commentActionType ==
                                                        LMCommentActionType.edit
                                                    ? const SizedBox()
                                                    : LMTextView(
                                                        text: state
                                                            .commentMetaData
                                                            .user!
                                                            .name,
                                                        textStyle:
                                                            const TextStyle(
                                                          fontSize: 14,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          color: LMThemeData
                                                              .kLinkColor,
                                                        ),
                                                      ),
                                                const Spacer(),
                                                LMIconButton(
                                                  onTap: (active) {
                                                    _postDetailScreenHandler!
                                                        .commentHandlerBloc
                                                        .add(
                                                            LMCommentCancelEvent());
                                                  },
                                                  icon: const LMIcon(
                                                    type: LMIconType.icon,
                                                    icon: Icons.close,
                                                    color:
                                                        LMThemeData.kGreyColor,
                                                    size: 24,
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
                                          borderRadius:
                                              BorderRadius.circular(24)),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      padding: const EdgeInsets.all(3.0),
                                      child: Row(
                                        children: [
                                          LMProfilePicture(
                                            fallbackText: currentUser.name,
                                            imageUrl: currentUser.imageUrl,
                                            backgroundColor:
                                                LMThemeData.kPrimaryColor,
                                            onTap: () {
                                              if (currentUser.sdkClientInfo !=
                                                  null) {
                                                LMFeedIntegration
                                                    .instance.lmFeedClient
                                                    .routeToProfile(currentUser
                                                        .sdkClientInfo!
                                                        .userUniqueId);
                                              }
                                            },
                                            size: 36,
                                          ),
                                          Expanded(
                                            child: TaggingAheadTextField(
                                              isDown: false,
                                              maxLines: 5,
                                              onTagSelected: (tag) {
                                                userTags.add(tag);
                                              },
                                              controller:
                                                  _postDetailScreenHandler!
                                                      .commentController,
                                              decoration: InputDecoration(
                                                enabled: right,
                                                border: InputBorder.none,
                                                hintText: right
                                                    ? 'Write a comment'
                                                    : "You do not have permission to comment.",
                                              ),
                                              focusNode:
                                                  _postDetailScreenHandler!
                                                      .focusNode,
                                              onChange: (String p0) {},
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            child: !right
                                                ? null
                                                : state is LMCommentLoadingState
                                                    ? const SizedBox(
                                                        height: 15,
                                                        width: 15,
                                                        child: LMLoader(
                                                          color: LMThemeData
                                                              .kPrimaryColor,
                                                        ),
                                                      )
                                                    : LMTextButton(
                                                        height: 18,
                                                        text: const LMTextView(
                                                          text: "Post",
                                                          textAlign:
                                                              TextAlign.center,
                                                          textStyle: TextStyle(
                                                            fontSize: 12.5,
                                                            color: LMThemeData
                                                                .kPrimaryColor,
                                                          ),
                                                        ),
                                                        onTap: () {
                                                          _postDetailScreenHandler!
                                                              .closeOnScreenKeyboard();
                                                          String commentText =
                                                              TaggingHelper
                                                                  .encodeString(
                                                            _postDetailScreenHandler!
                                                                .commentController
                                                                .text,
                                                            userTags,
                                                          );
                                                          commentText =
                                                              commentText
                                                                  .trim();
                                                          if (commentText
                                                              .isEmpty) {
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
                                                              is LMCommentActionOngoingState) {
                                                            if (state
                                                                    .commentMetaData
                                                                    .commentActionType ==
                                                                LMCommentActionType
                                                                    .edit) {
                                                              LMCommentMetaData
                                                                  commentMetaData =
                                                                  (LMCommentMetaDataBuilder()
                                                                        ..commentActionEntity(
                                                                            LMCommentType.parent)
                                                                        ..level(
                                                                            0)
                                                                        ..commentId(state
                                                                            .commentMetaData
                                                                            .commentId!)
                                                                        ..commentActionType(
                                                                            LMCommentActionType.edit))
                                                                      .build();
                                                              EditCommentRequest
                                                                  editCommentRequest =
                                                                  (EditCommentRequestBuilder()
                                                                        ..postId(
                                                                            widget.postId)
                                                                        ..commentId(state
                                                                            .commentMetaData
                                                                            .commentId!)
                                                                        ..text(
                                                                            commentText))
                                                                      .build();

                                                              _postDetailScreenHandler!
                                                                  .commentHandlerBloc
                                                                  .add(LMCommentActionEvent(
                                                                      commentActionRequest:
                                                                          editCommentRequest,
                                                                      commentMetaData:
                                                                          commentMetaData));
                                                            } else if (state
                                                                    .commentMetaData
                                                                    .commentActionType ==
                                                                LMCommentActionType
                                                                    .replying) {
                                                              LMCommentMetaData
                                                                  commentMetaData =
                                                                  (LMCommentMetaDataBuilder()
                                                                        ..commentActionEntity(
                                                                            LMCommentType.parent)
                                                                        ..level(
                                                                            0)
                                                                        ..commentId(state
                                                                            .commentMetaData
                                                                            .commentId!)
                                                                        ..commentActionType(
                                                                            LMCommentActionType.replying))
                                                                      .build();
                                                              AddCommentReplyRequest
                                                                  addReplyRequest =
                                                                  (AddCommentReplyRequestBuilder()
                                                                        ..postId(
                                                                            widget.postId)
                                                                        ..text(
                                                                            commentText)
                                                                        ..commentId(state
                                                                            .commentMetaData
                                                                            .commentId!))
                                                                      .build();

                                                              _postDetailScreenHandler!
                                                                  .commentHandlerBloc
                                                                  .add(LMCommentActionEvent(
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
                                                                          LMCommentType
                                                                              .parent)
                                                                      ..level(0)
                                                                      ..commentActionType(
                                                                          LMCommentActionType
                                                                              .add))
                                                                    .build();
                                                            AddCommentRequest
                                                                addCommentRequest =
                                                                (AddCommentRequestBuilder()
                                                                      ..postId(
                                                                          widget
                                                                              .postId)
                                                                      ..text(
                                                                          commentText))
                                                                    .build();

                                                            _postDetailScreenHandler!
                                                                .commentHandlerBloc
                                                                .add(LMCommentActionEvent(
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
                        ? AppBar(
                            leading: LMIconButton(
                              icon: LMIcon(
                                type: LMIconType.icon,
                                icon: Platform.isAndroid
                                    ? Icons.arrow_back
                                    : CupertinoIcons.chevron_back,
                                size: 28,
                                color: LMThemeData.appBlack,
                              ),
                              onTap: (active) {
                                Navigator.pop(context);
                              },
                            ),
                            backgroundColor: LMThemeData.kWhiteColor,
                            elevation: 1,
                            title: const LMTextView(
                              text: "Comments",
                              textStyle: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: LMThemeData.kHeadingColor,
                              ),
                            ),
                            centerTitle: Platform.isAndroid ? false : true,
                          )
                        : widget.appBarBuilder!(context, postData!),
                    body: CustomScrollView(
                      slivers: [
                        SliverToBoxAdapter(
                          child: widget.postBuilder == null
                              ? LMPostWidget(
                                  post: postData!,
                                  user: _postDetailScreenHandler!
                                      .users[postData!.userId]!,
                                  onPostTap: (context, post) {},
                                  isFeed: false,
                                  onTagTap: (tag) {},
                                  footerBuilder: (context, post) {
                                    return LMPostFooter(
                                      alignment: LMAlignment.centre,
                                      children: [
                                        LMTextButton(
                                          text: const LMTextView(text: "Like"),
                                          margin: 0,
                                          activeText: const LMTextView(
                                            text: "Like",
                                            textStyle: TextStyle(
                                              color: LMThemeData.primary500,
                                            ),
                                          ),
                                          onTap: () async {
                                            if (postData!.isLiked) {
                                              postData!.likeCount -= 1;
                                              postData!.isLiked = false;
                                            } else {
                                              postData!.likeCount += 1;
                                              postData!.isLiked = true;
                                            }

                                            rebuildPostWidget.value =
                                                !rebuildPostWidget.value;

                                            final response =
                                                await LMFeedIntegration
                                                    .instance.lmFeedClient
                                                    .likePost(
                                                        (LikePostRequestBuilder()
                                                              ..postId(
                                                                  postData!.id))
                                                            .build());

                                            if (!response.success) {
                                              toast(
                                                response.errorMessage ??
                                                    "There was an error liking the post",
                                                duration: Toast.LENGTH_LONG,
                                              );

                                              if (postData!.isLiked) {
                                                postData!.likeCount -= 1;
                                                postData!.isLiked = false;
                                              } else {
                                                postData!.likeCount += 1;
                                                postData!.isLiked = true;
                                              }

                                              rebuildPostWidget.value =
                                                  !rebuildPostWidget.value;
                                            } else {
                                              LMPostBloc.instance.add(
                                                UpdatePost(
                                                  post: postData!,
                                                ),
                                              );
                                            }
                                          },
                                          icon: const LMIcon(
                                            type: LMIconType.icon,
                                            icon:
                                                Icons.thumb_up_off_alt_outlined,
                                            color:
                                                LMThemeData.kSecondaryColor700,
                                            size: 20,
                                            boxPadding: 6,
                                          ),
                                          activeIcon: const LMIcon(
                                            type: LMIconType.icon,
                                            icon: Icons.thumb_up,
                                            size: 20,
                                            boxPadding: 6,
                                            color: LMThemeData.kPrimaryColor,
                                          ),
                                          isActive: postData!.isLiked,
                                        ),
                                        const Spacer(),
                                        LMTextButton(
                                          text:
                                              const LMTextView(text: "Comment"),
                                          margin: 0,
                                          onTap: () {
                                            if (widget.isFeed) {
                                              LMAnalyticsBloc.instance.add(
                                                  FireAnalyticEvent(
                                                      eventName: AnalyticsKeys
                                                          .commentListOpen,
                                                      eventProperties: {
                                                    'postId': postData!.id,
                                                  }));
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      LMPostDetailScreen(
                                                    postId: postData!.id,
                                                  ),
                                                ),
                                              );
                                            }
                                          },
                                          icon: const LMIcon(
                                            type: LMIconType.svg,
                                            assetPath: kAssetCommentIcon,
                                            color:
                                                LMThemeData.kSecondaryColor700,
                                            size: 20,
                                            boxPadding: 6,
                                          ),
                                        ),
                                        const Spacer(),
                                        LMTextButton(
                                          text: const LMTextView(text: "Share"),
                                          margin: 0,
                                          onTap: () {
                                            String? postType =
                                                postData!.attachments == null ||
                                                        postData!.attachments!
                                                            .isEmpty
                                                    ? 'text'
                                                    : getPostType(postData!
                                                            .attachments
                                                            ?.first
                                                            .attachmentType ??
                                                        0);

                                            LMAnalyticsBloc.instance
                                                .add(FireAnalyticEvent(
                                              eventName:
                                                  AnalyticsKeys.postShared,
                                              eventProperties: {
                                                "post_id": postData!.id,
                                                "post_type": postType,
                                                "user_id":
                                                    currentUser.userUniqueId,
                                              },
                                            ));
                                            // TODO: Add Share Post logic
                                            //SharePost().sharePost(postData!.id);
                                          },
                                          icon: const LMIcon(
                                            type: LMIconType.svg,
                                            assetPath: kAssetShareIcon,
                                            color:
                                                LMThemeData.kSecondaryColor700,
                                            size: 20,
                                            boxPadding: 6,
                                          ),
                                        ),
                                      ],
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
                                )
                              : widget.postBuilder!(context, postData!),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 16,
                          ),
                        ),
                        SliverToBoxAdapter(
                          child: Container(
                            decoration: const BoxDecoration(
                              color: LMThemeData.kBackgroundColor,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0x19000000),
                                  blurRadius: 5,
                                  offset: Offset(1, 1),
                                  spreadRadius: 0,
                                )
                              ],
                            ),
                            child: BlocConsumer<LMCommentHandlerBloc,
                                    LMCommentHandlerState>(
                                bloc: _postDetailScreenHandler!
                                    .commentHandlerBloc,
                                listener: (context, state) {
                                  _postDetailScreenHandler!
                                      .handleBlocChanges(state);
                                },
                                builder: (context, state) {
                                  return ValueListenableBuilder(
                                      valueListenable: rebuildPostWidget,
                                      builder: (context, _, __) {
                                        return PagedListView.separated(
                                            pagingController:
                                                _postDetailScreenHandler!
                                                    .commetListPagingController,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            builderDelegate:
                                                PagedChildBuilderDelegate<
                                                        LMCommentViewData>(
                                                    noMoreItemsIndicatorBuilder:
                                                        (context) =>
                                                            const SizedBox(
                                                                height: 75),
                                                    noItemsFoundIndicatorBuilder:
                                                        (context) =>
                                                            const LMEmptyCommentWidget(),
                                                    itemBuilder: (context,
                                                        commentViewData,
                                                        index) {
                                                      LMUserViewData
                                                          userViewData;
                                                      if (!_postDetailScreenHandler!
                                                          .users
                                                          .containsKey(
                                                              commentViewData
                                                                  .userId)) {
                                                        return const SizedBox
                                                            .shrink();
                                                      }
                                                      userViewData =
                                                          _postDetailScreenHandler!
                                                                  .users[
                                                              commentViewData
                                                                  .userId]!;
                                                      bool replyShown = false;
                                                      return Container(
                                                        child: Column(
                                                          children: [
                                                            LMCommentTile(
                                                              user:
                                                                  userViewData,
                                                              comment:
                                                                  commentViewData,
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(
                                                                      16.0),
                                                              profilePicture:
                                                                  LMProfilePicture(
                                                                backgroundColor:
                                                                    LMThemeData
                                                                        .kPrimaryColor,
                                                                fallbackText:
                                                                    _postDetailScreenHandler!
                                                                        .users[commentViewData
                                                                            .userId]!
                                                                        .name,
                                                                onTap: () {
                                                                  if (_postDetailScreenHandler!
                                                                          .users[
                                                                              commentViewData.userId]!
                                                                          .sdkClientInfo !=
                                                                      null) {
                                                                    LMFeedIntegration
                                                                        .instance
                                                                        .lmFeedClient
                                                                        .routeToProfile(_postDetailScreenHandler!
                                                                            .users[commentViewData.userId]!
                                                                            .sdkClientInfo!
                                                                            .userUniqueId);
                                                                  }
                                                                },
                                                                imageUrl: _postDetailScreenHandler!
                                                                    .users[commentViewData
                                                                        .userId]!
                                                                    .imageUrl,
                                                                size: 36,
                                                              ),
                                                              subtitleText:
                                                                  LMTextView(
                                                                text:
                                                                    "@${_postDetailScreenHandler!.users[commentViewData.userId]!.name.toLowerCase().split(' ').join()} · ", //${timeago.format(commentViewData.createdAt)}",
                                                                textStyle:
                                                                    const TextStyle(
                                                                  fontSize: 12,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w400,
                                                                  color: LMThemeData
                                                                      .kSecondaryColor700,
                                                                ),
                                                              ),
                                                              commentActions: [
                                                                LMTextButton(
                                                                  margin: 10,
                                                                  text:
                                                                      LMTextView(
                                                                    text: commentViewData.likesCount ==
                                                                            0
                                                                        ? "Like"
                                                                        : commentViewData.likesCount ==
                                                                                1
                                                                            ? "1 Like"
                                                                            : "${commentViewData.likesCount} Likes",
                                                                    textStyle: const TextStyle(
                                                                        color: LMThemeData
                                                                            .kSecondaryColor700,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                  activeText:
                                                                      LMTextView(
                                                                    text: commentViewData.likesCount ==
                                                                            0
                                                                        ? "Like"
                                                                        : commentViewData.likesCount ==
                                                                                1
                                                                            ? "1 Like"
                                                                            : "${commentViewData.likesCount} Likes",
                                                                    textStyle: const TextStyle(
                                                                        color: LMThemeData
                                                                            .kPrimaryColor,
                                                                        fontSize:
                                                                            12),
                                                                  ),
                                                                  onTap:
                                                                      () async {
                                                                    commentViewData
                                                                        .likesCount = commentViewData
                                                                            .isLiked
                                                                        ? commentViewData.likesCount -
                                                                            1
                                                                        : commentViewData.likesCount +
                                                                            1;
                                                                    commentViewData
                                                                            .isLiked =
                                                                        !commentViewData
                                                                            .isLiked;
                                                                    rebuildPostWidget
                                                                            .value =
                                                                        !rebuildPostWidget
                                                                            .value;

                                                                    ToggleLikeCommentRequest
                                                                        toggleLikeCommentRequest =
                                                                        (ToggleLikeCommentRequestBuilder()
                                                                              ..commentId(commentViewData.id)
                                                                              ..postId(widget.postId))
                                                                            .build();

                                                                    final ToggleLikeCommentResponse
                                                                        response =
                                                                        await LMFeedIntegration
                                                                            .instance
                                                                            .lmFeedClient
                                                                            .likeComment(toggleLikeCommentRequest);

                                                                    if (!response
                                                                        .success) {
                                                                      commentViewData
                                                                          .likesCount = commentViewData
                                                                              .isLiked
                                                                          ? commentViewData.likesCount -
                                                                              1
                                                                          : commentViewData.likesCount +
                                                                              1;
                                                                      commentViewData
                                                                              .isLiked =
                                                                          !commentViewData
                                                                              .isLiked;

                                                                      rebuildPostWidget
                                                                              .value =
                                                                          !rebuildPostWidget
                                                                              .value;
                                                                    }
                                                                  },
                                                                  icon:
                                                                      const LMIcon(
                                                                    type:
                                                                        LMIconType
                                                                            .svg,
                                                                    assetPath:
                                                                        kAssetLikeIcon,
                                                                    size: 20,
                                                                  ),
                                                                  activeIcon:
                                                                      const LMIcon(
                                                                    type:
                                                                        LMIconType
                                                                            .svg,
                                                                    assetPath:
                                                                        kAssetLikeFilledIcon,
                                                                    size: 20,
                                                                  ),
                                                                  isActive:
                                                                      commentViewData
                                                                          .isLiked,
                                                                ),
                                                                const SizedBox(
                                                                    width: 12),
                                                                Row(
                                                                  children: [
                                                                    LMTextButton(
                                                                      margin:
                                                                          10,
                                                                      text: const LMTextView(
                                                                          text: "Reply",
                                                                          textStyle: TextStyle(
                                                                            fontSize:
                                                                                12,
                                                                          )),
                                                                      onTap:
                                                                          () {
                                                                        LMCommentMetaData
                                                                            commentMetaData =
                                                                            (LMCommentMetaDataBuilder()
                                                                                  ..commentActionEntity(LMCommentType.parent)
                                                                                  ..commentActionType(LMCommentActionType.replying)
                                                                                  ..level(0)
                                                                                  ..user(_postDetailScreenHandler!.users[commentViewData.userId]!)
                                                                                  ..commentId(commentViewData.id))
                                                                                .build();

                                                                        _postDetailScreenHandler!
                                                                            .commentHandlerBloc
                                                                            .add(LMCommentOngoingEvent(commentMetaData: commentMetaData));
                                                                      },
                                                                      icon:
                                                                          const LMIcon(
                                                                        type: LMIconType
                                                                            .svg,
                                                                        assetPath:
                                                                            kAssetCommentIcon,
                                                                        size:
                                                                            20,
                                                                      ),
                                                                    ),
                                                                    LMThemeData
                                                                        .kHorizontalPaddingMedium,
                                                                    commentViewData.repliesCount >
                                                                            0
                                                                        ? LMTextButton(
                                                                            onTap:
                                                                                () {
                                                                              if (!replyShown) {
                                                                                _commentRepliesBloc.add(GetCommentReplies(
                                                                                    commentDetailRequest: (GetCommentRequestBuilder()
                                                                                          ..commentId(commentViewData.id)
                                                                                          ..postId(widget.postId)
                                                                                          ..page(1))
                                                                                        .build(),
                                                                                    forLoadMore: true));
                                                                                replyShown = true;
                                                                              } else {
                                                                                _commentRepliesBloc.add(ClearCommentReplies());
                                                                                replyShown = false;
                                                                              }
                                                                            },
                                                                            text:
                                                                                LMTextView(
                                                                              text: "${commentViewData.repliesCount} ${commentViewData.repliesCount > 1 ? 'Replies' : 'Reply'}",
                                                                              textStyle: const TextStyle(
                                                                                color: LMThemeData.kPrimaryColor,
                                                                              ),
                                                                            ),
                                                                          )
                                                                        : const SizedBox(),
                                                                  ],
                                                                ),
                                                              ],
                                                              actionsPadding:
                                                                  const EdgeInsets
                                                                      .only(
                                                                      left: 48),
                                                              onMenuTap: (id) {
                                                                if (id ==
                                                                    commentDeleteId) {
                                                                  // Delete post
                                                                  showDialog(
                                                                      context:
                                                                          context,
                                                                      builder:
                                                                          (childContext) =>
                                                                              LMDeleteConfirmationDialog(
                                                                                title: 'Delete Comment',
                                                                                userId: commentViewData.userId,
                                                                                content: 'Are you sure you want to delete this post. This action can not be reversed.',
                                                                                action: (String reason) async {
                                                                                  Navigator.of(childContext).pop();

                                                                                  LMAnalyticsBloc.instance.add(FireAnalyticEvent(
                                                                                    eventName: AnalyticsKeys.commentDeleted,
                                                                                    eventProperties: {
                                                                                      "post_id": widget.postId,
                                                                                      "comment_id": commentViewData.id,
                                                                                    },
                                                                                  ));

                                                                                  DeleteCommentRequest deleteCommentRequest = (DeleteCommentRequestBuilder()
                                                                                        ..postId(widget.postId)
                                                                                        ..commentId(commentViewData.id)
                                                                                        ..reason(reason.isEmpty ? "Reason for deletion" : reason))
                                                                                      .build();

                                                                                  LMCommentMetaData commentMetaData = (LMCommentMetaDataBuilder()
                                                                                        ..commentActionEntity(LMCommentType.parent)
                                                                                        ..commentActionType(LMCommentActionType.delete)
                                                                                        ..level(0)
                                                                                        ..commentId(commentViewData.id))
                                                                                      .build();

                                                                                  _postDetailScreenHandler!.commentHandlerBloc.add(LMCommentActionEvent(commentActionRequest: deleteCommentRequest, commentMetaData: commentMetaData));
                                                                                },
                                                                                actionText: 'Delete',
                                                                              ));
                                                                } else if (id ==
                                                                    commentEditId) {
                                                                  debugPrint(
                                                                      'Editing functionality');
                                                                  LMCommentMetaData
                                                                      commentMetaData =
                                                                      (LMCommentMetaDataBuilder()
                                                                            ..commentActionEntity(LMCommentType.parent)
                                                                            ..commentActionType(LMCommentActionType.edit)
                                                                            ..level(0)
                                                                            ..commentId(commentViewData.id))
                                                                          .build();

                                                                  _postDetailScreenHandler!
                                                                      .commentHandlerBloc
                                                                      .add(LMCommentOngoingEvent(
                                                                          commentMetaData:
                                                                              commentMetaData));
                                                                }
                                                              },
                                                              onTagTap: (String
                                                                  userId) {
                                                                LMFeedIntegration
                                                                    .instance
                                                                    .lmFeedClient
                                                                    .routeToProfile(
                                                                        userId);
                                                              },
                                                            ),
                                                            LMCommentReplyWidget(
                                                              refresh: () {
                                                                _pagingController
                                                                    .refresh();
                                                              },
                                                              postId:
                                                                  widget.postId,
                                                              reply:
                                                                  commentViewData,
                                                              user: _postDetailScreenHandler!
                                                                      .users[
                                                                  commentViewData
                                                                      .userId]!,
                                                            ),
                                                          ],
                                                        ),
                                                      );
                                                    }),
                                            padding: EdgeInsets.zero,
                                            separatorBuilder: (context,
                                                    index) =>
                                                const Divider(
                                                    thickness: 0.2, height: 0));
                                      });
                                }),
                          ),
                        ),
                        const SliverToBoxAdapter(
                          child: SizedBox(
                            height: 100,
                          ),
                        ),
                      ],
                    ));
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
            }),
      ),
    );
  }
}
