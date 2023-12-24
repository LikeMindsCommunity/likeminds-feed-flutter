import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/comment/comment_handler/comment_handler_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/analytics/keys.dart';
import 'package:likeminds_feed_driver_fl/src/utils/constants/post_action_id.dart';
import 'package:likeminds_feed_driver_fl/src/views/post_detail_screen/handler/post_detail_screen_handler.dart';
import 'package:likeminds_feed_driver_fl/src/views/post_detail_screen/widgets/delete_dialog.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

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

  @override
  State<LMPostDetailScreen> createState() => _LMPostDetailScreenState();
}

class _LMPostDetailScreenState extends State<LMPostDetailScreen> {
  final PagingController<int, CommentViewData> _pagingController =
      PagingController(firstPageKey: 1);
  PostDetailScreenHandler? _postDetailScreenHandler;
  Future<PostViewData?>? getPostData;

  @override
  void initState() {
    super.initState();
    _postDetailScreenHandler =
        PostDetailScreenHandler(_pagingController, widget.postId);
    getPostData = _postDetailScreenHandler!.fetchCommentListWithPage(1);
  }

  @override
  void didUpdateWidget(covariant LMPostDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.postId != widget.postId) {
      _pagingController.itemList?.clear();
      _pagingController.refresh();
      _postDetailScreenHandler =
          PostDetailScreenHandler(_pagingController, widget.postId);
      getPostData = _postDetailScreenHandler!.fetchCommentListWithPage(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PostViewData?>(
        future: getPostData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done &&
              snapshot.hasData) {
            PostViewData postData = snapshot.data!;
            return Scaffold(
                resizeToAvoidBottomInset: true,
                appBar: widget.appBarBuilder == null
                    ? AppBar()
                    : widget.appBarBuilder!(context, postData),
                body: CustomScrollView(
                  slivers: [
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 20,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: widget.postBuilder == null
                          ? LMPostWidget(
                              post: postData,
                              user: _postDetailScreenHandler!
                                  .users[postData.userId]!,
                              onPostTap: (context, post) {},
                              isFeed: false,
                              onTagTap: (tag) {},
                            )
                          : widget.postBuilder!(context, postData),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 20,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'Comments',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 20,
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: BlocConsumer<LMCommentHandlerBloc,
                              LMCommentHandlerState>(
                          bloc: _postDetailScreenHandler!.commentHandlerBloc,
                          listener: (context, state) {
                            _postDetailScreenHandler!.handleBlocChanges(state);
                          },
                          builder: (context, state) {
                            return PagedListView.separated(
                                pagingController: _postDetailScreenHandler!
                                    .commetListPagingController,
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                builderDelegate:
                                    PagedChildBuilderDelegate<CommentViewData>(
                                        itemBuilder:
                                            (context, commentViewData, index) {
                                  UserViewData userViewData;
                                  if (!_postDetailScreenHandler!.users
                                      .containsKey(commentViewData.userId)) {
                                    return const SizedBox.shrink();
                                  }
                                  userViewData = _postDetailScreenHandler!
                                      .users[commentViewData.userId]!;
                                  return LMCommentTile(
                                    user: userViewData,
                                    comment: commentViewData,
                                    onMenuTap: (id) {
                                      if (id == commentDeleteId) {
                                        // Delete post
                                        showDialog(
                                            context: context,
                                            builder: (childContext) =>
                                                LMDeleteConfirmationDialog(
                                                  title: 'Delete Comment',
                                                  userId:
                                                      commentViewData.userId,
                                                  content:
                                                      'Are you sure you want to delete this post. This action can not be reversed.',
                                                  action:
                                                      (String reason) async {
                                                    Navigator.of(childContext)
                                                        .pop();

                                                    LMAnalyticsBloc.instance
                                                        .add(FireAnalyticEvent(
                                                      eventName: AnalyticsKeys
                                                          .commentDeleted,
                                                      eventProperties: {
                                                        "post_id":
                                                            widget.postId,
                                                        "comment_id":
                                                            commentViewData.id,
                                                      },
                                                    ));

                                                    DeleteCommentRequest
                                                        deleteCommentRequest =
                                                        (DeleteCommentRequestBuilder()
                                                              ..postId(
                                                                  widget.postId)
                                                              ..commentId(
                                                                  commentViewData
                                                                      .id)
                                                              ..reason(reason
                                                                      .isEmpty
                                                                  ? "Reason for deletion"
                                                                  : reason))
                                                            .build();

                                                    LMCommentMetaData
                                                        commentMetaData =
                                                        (LMCommentMetaDataBuilder()
                                                              ..commentActionEntity(
                                                                  LMCommentType
                                                                      .parent)
                                                              ..commentActionType(
                                                                  LMCommentActionType
                                                                      .delete)
                                                              ..level(0)
                                                              ..commentId(
                                                                  commentViewData
                                                                      .id))
                                                            .build();

                                                    _postDetailScreenHandler!
                                                        .commentHandlerBloc
                                                        .add(LMCommentActionEvent(
                                                            commentActionRequest:
                                                                deleteCommentRequest,
                                                            commentMetaData:
                                                                commentMetaData));
                                                  },
                                                  actionText: 'Delete',
                                                ));
                                      } else if (id == commentEditId) {
                                        debugPrint('Editing functionality');
                                        LMCommentMetaData commentMetaData =
                                            (LMCommentMetaDataBuilder()
                                                  ..commentActionEntity(
                                                      LMCommentType.parent)
                                                  ..commentActionType(
                                                      LMCommentActionType.edit)
                                                  ..level(0)
                                                  ..commentId(
                                                      commentViewData.id))
                                                .build();

                                        _postDetailScreenHandler!
                                            .commentHandlerBloc
                                            .add(LMCommentOngoingEvent(
                                                commentMetaData:
                                                    commentMetaData));
                                      }
                                    },
                                    onTagTap: (String userId) {
                                      LMFeedIntegration.instance.lmFeedClient
                                          .routeToProfile(userId);
                                    },
                                  );
                                }),
                                separatorBuilder: (context, index) =>
                                    const Divider());
                          }),
                    ),
                    const SliverToBoxAdapter(
                      child: SizedBox(
                        height: 20,
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
                  'Error loading post',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            );
          } else {
            return const SizedBox.shrink();
          }
        });
  }
}
