import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/user_created_comment/user_created_comment_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/views/poll/handler/poll_handler.dart';

class LMFeedUserCreatedCommentListView extends StatefulWidget {
  const LMFeedUserCreatedCommentListView({
    Key? key,
    required this.uuid,
    this.postBuilder,
    this.emptyFeedViewBuilder,
    this.firstPageLoaderBuilder,
    this.paginationLoaderBuilder,
    this.feedErrorViewBuilder,
    this.noNewPageWidgetBuilder,
  }) : super(key: key);

  // The user id for which the user feed is to be shown
  final String uuid;
  // Builder for post item
  // {@macro post_widget_builder}
  final LMFeedPostWidgetBuilder? postBuilder;
  // {@macro context_widget_builder}
  // Builder for empty feed view
  final LMFeedContextWidgetBuilder? emptyFeedViewBuilder;
  // Builder for first page loader when no post are there
  final LMFeedContextWidgetBuilder? firstPageLoaderBuilder;
  // Builder for pagination loader when more post are there
  final LMFeedContextWidgetBuilder? paginationLoaderBuilder;
  // Builder for error view when error occurs
  final LMFeedContextWidgetBuilder? feedErrorViewBuilder;
  // Builder for widget when no more post are there
  final LMFeedContextWidgetBuilder? noNewPageWidgetBuilder;

  @override
  State<LMFeedUserCreatedCommentListView> createState() =>
      _LMFeedUserCreatedCommentListViewState();
}

class _LMFeedUserCreatedCommentListViewState
    extends State<LMFeedUserCreatedCommentListView> {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);
  String postTitleSmallCap =
      LMFeedPostUtils.getPostTitle(LMFeedPluralizeWordAction.allSmallSingular);

  String commentTitleSmallPlural = LMFeedPostUtils.getCommentTitle(
      LMFeedPluralizeWordAction.allSmallSingular);

  bool isCm = LMFeedUserUtils.checkIfCurrentUserIsCM();

  ValueNotifier<bool> rebuildPostWidget = ValueNotifier(false);
  static const int pageSize = 10;
  final PagingController<int, LMCommentViewData> _pagingController =
      PagingController(firstPageKey: 1);
  LMUserViewData? userViewData = LMFeedLocalPreference.instance.fetchUserData();
  bool userPostingRights = LMFeedUserUtils.checkPostCreationRights();
  LMFeedThemeData feedThemeData = LMFeedCore.theme;
  final ValueNotifier<bool> postUploading = ValueNotifier(false);
  final LMFeedUserCreatedCommentBloc _userCreatedCommentBloc =
      LMFeedUserCreatedCommentBloc();
  final Map<String, LMPostViewData> _posts = {};
  LMFeedPostBloc lmFeedPostBloc = LMFeedPostBloc.instance;
  LMFeedWidgetSource _widgetSource =
      LMFeedWidgetSource.userCreatedCommentScreen;
  LMUserViewData currentUser = LMFeedLocalPreference.instance.fetchUserData()!;

  @override
  void initState() {
    super.initState();
    addPageRequestListener();
  }

  void addPageRequestListener() {
    _pagingController.addPageRequestListener(
      (pageKey) {
        _userCreatedCommentBloc.add(
          LMFeedGetUserCreatedCommentEvent(
            uuid: widget.uuid,
            page: pageKey,
            pageSize: pageSize,
          ),
        );
      },
    );
  }

  void refresh() => _pagingController.refresh();

  // This function updates the paging controller based on the state changes
  void updatePagingControllers(LMFeedUserCreatedCommentLoadedState state) {
    if (state.comments.length < 10) {
      _pagingController.appendLastPage(state.comments);
      _posts.addAll(state.posts);
    } else {
      _pagingController.appendPage(state.comments, state.page + 1);
      _posts.addAll(state.posts);
    }
  }

  // This function clears the paging controller
  // whenever user uses pull to refresh on feedroom screen
  void clearPagingController() {
    /* Clearing paging controller while changing the
     event to prevent duplication of list */
    if (_pagingController.itemList != null) _pagingController.itemList?.clear();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LMFeedPostBloc, LMFeedPostState>(
        bloc: lmFeedPostBloc,
        listener: (context, state) {
          if (state is LMFeedEditPostUploadedState) {
            _posts[state.postData.id] = state.postData.copyWith();

            rebuildPostWidget.value = !rebuildPostWidget.value;
          }
          if (state is LMFeedPostUpdateState) {
            LMPostViewData? post = _posts[state.postId];

            if (post != null) {
              post = LMFeedPostUtils.updatePostData(
                  postViewData: post, actionType: state.actionType);
              _posts[state.postId] = post;
              rebuildPostWidget.value = !rebuildPostWidget.value;
            }
          }
        },
        child: ValueListenableBuilder(
            valueListenable: rebuildPostWidget,
            builder: (context, _, __) {
              return BlocListener<LMFeedUserCreatedCommentBloc,
                  LMFeedUserCreatedCommentState>(
                bloc: _userCreatedCommentBloc,
                listener: (context, state) {
                  if (state is LMFeedUserCreatedCommentLoadedState) {
                    updatePagingControllers(state);
                  }
                },
                child: PagedSliverList(
                  pagingController: _pagingController,
                  builderDelegate: PagedChildBuilderDelegate<LMCommentViewData>(
                    noItemsFoundIndicatorBuilder: (context) {
                      return widget.emptyFeedViewBuilder?.call(context) ??
                          noPostInFeedWidget();
                    },
                    itemBuilder: (context, item, index) {
                      _posts[item.postId]?.topComments = [item];

                      LMFeedPostWidget postWidget =
                          LMFeedDefaultWidgets.instance
                              .defPostWidget(
                        context,
                        feedThemeData,
                        _posts[item.postId]!,
                        _widgetSource,
                        postUploading,
                      )
                              .copyWith(
                        contentBuilder: (p0, p1, p2) {
                          return LMFeedPostCustomContent(
                            comment: item,
                            post: _posts[item.postId]!,
                            feedThemeData: feedThemeData,
                          );
                        },
                      );
                      return Column(
                        children: [
                          const SizedBox(height: 2),
                          widget.postBuilder?.call(
                                  context, postWidget, _posts[item.postId]!) ??
                              LMFeedCore.config.widgetBuilderDelegate
                                  .postWidgetBuilder
                                  .call(
                                      context, postWidget, _posts[item.postId]!,
                                      source: _widgetSource),
                          const Divider(),
                        ],
                      );
                    },
                    firstPageProgressIndicatorBuilder: (context) {
                      return widget.firstPageLoaderBuilder?.call(context) ??
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: LMFeedLoader()),
                          );
                    },
                    newPageProgressIndicatorBuilder: (context) {
                      return widget.paginationLoaderBuilder?.call(context) ??
                          const Padding(
                            padding: EdgeInsets.all(16.0),
                            child: Center(child: LMFeedLoader()),
                          );
                    },
                  ),
                ),
              );
            }));
  }

  Widget getLoaderThumbnail(LMAttachmentViewData? media) {
    if (media != null) {
      if (media.attachmentType == LMMediaType.image) {
        return Container(
          height: 50,
          width: 50,
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(6.0),
          ),
          child: LMFeedImage(
            image: media,
            style: const LMFeedPostImageStyle(
              boxFit: BoxFit.contain,
            ),
          ),
        );
      } else if (media.attachmentType == LMMediaType.document) {
        return LMFeedIcon(
          type: LMFeedIconType.svg,
          assetPath: kAssetNoPostsIcon,
          style: LMFeedIconStyle(
            color: Colors.red,
            size: 35,
            boxPadding: 0,
          ),
        );
      } else {
        return const SizedBox.shrink();
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget noPostInFeedWidget() => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const LMFeedIcon(
              type: LMFeedIconType.icon,
              icon: Icons.post_add,
              style: LMFeedIconStyle(
                size: 48,
              ),
            ),
            const SizedBox(height: 12),
            LMFeedText(
              text: 'No $commentTitleSmallPlural to show',
              style: LMFeedTextStyle(
                textStyle: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
}

class LMFeedPostCustomContent extends LMFeedPostContent {
  LMFeedPostCustomContent({
    required this.comment,
    required this.post,
    this.feedThemeData,
  });
  final LMCommentViewData comment;
  final LMPostViewData post;
  final LMFeedThemeData? feedThemeData;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        LMFeedPostContent(
          onTagTap: (String? uuid) {},
          style: feedThemeData?.contentStyle,
          text: post.text,
          heading: post.heading,
        ),
        _defCommentBuilder(context),
      ],
    );
  }

  Widget _defCommentBuilder(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 50,
        ),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: feedThemeData?.backgroundColor,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.zero,
                topRight: Radius.circular(10.0),
                bottomLeft: Radius.circular(10.0),
                bottomRight: Radius.circular(10.0),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                LMFeedText(
                  text: comment.user.name,
                  style: const LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontWeight: FontWeight.w600,
                      // color: textSecondary,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                LMFeedExpandableText(
                  LMFeedTaggingHelper.convertRouteToTag(comment.text),
                  expandText: "Read More",
                  prefixStyle: const TextStyle(
                    // color: textSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    height: 1.66,
                  ),
                  expandOnTextTap: true,
                  onTagTap: (String uuid) {
                    LMFeedProfileBloc.instance.add(
                      LMFeedRouteToUserProfileEvent(
                        uuid: uuid,
                        context: context,
                      ),
                    );
                  },
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    // color: textSecondary,
                    height: 1.66,
                  ),
                  maxLines: 4,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
