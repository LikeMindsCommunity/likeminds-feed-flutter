import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/likes/widgets/widgets.dart';

class LMFeedLikeListView extends StatefulWidget {
  const LMFeedLikeListView({
    super.key,
    required this.postId,
    this.commentId,
    this.isCommentLikes = false,
    this.widgetSource,
    this.handler,
  });
  final String postId;
  final String? commentId;
  final bool isCommentLikes;
  final LMFeedWidgetSource? widgetSource;
  final LMLikesScreenHandler? handler;
  @override
  State<LMFeedLikeListView> createState() => _LMFeedLikeListViewState();
}

class _LMFeedLikeListViewState extends State<LMFeedLikeListView> {
  LMLikesScreenHandler? _localHandler;
  LMFeedLikeScreenBuilderDelegate _widgetBuilder =
      LMFeedCore.config.likeScreenConfig.builder;
  @override
  void initState() {
    super.initState();
    _localHandler = widget.handler ?? LMLikesScreenHandler.instance;
    if (widget.handler == null) {
      _localHandler?.initialise(
          postId: widget.postId, commentId: widget.commentId);
    }

    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.likeListOpen,
        widgetSource: widget.widgetSource,
        eventProperties: {
          'post_id': widget.postId,
          'comment_id': widget.commentId,
        },
      ),
    );
  }

  @override
  void didUpdateWidget(oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.postId != oldWidget.postId ||
        widget.commentId != oldWidget.commentId) {
      if (widget.handler == null) {
        _localHandler?.initialise(
            postId: widget.postId, commentId: widget.commentId);
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
    if (widget.handler == null) {
      _localHandler?.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: PagedListView<int, LMLikeViewData>(
        padding: EdgeInsets.zero,
        pagingController: _localHandler!.pagingController,
        builderDelegate: PagedChildBuilderDelegate<LMLikeViewData>(
          noMoreItemsIndicatorBuilder: (context) =>
              _widgetBuilder.noMoreItemsIndicatorBuilder(
            context,
            child: const SizedBox(
              height: 20,
            ),
          ),
          noItemsFoundIndicatorBuilder: (context) =>
              _widgetBuilder.noItemsFoundIndicatorBuilder(
            context,
            child: Scaffold(
              backgroundColor: LikeMindsTheme.whiteColor,
              body: noItemLikesView(),
            ),
          ),
          itemBuilder: (context, item, index) => _widgetBuilder.likeTileBuilder(
            context,
            index,
            _localHandler!.userData[item.uuid]!,
            LMFeedLikeTile(user: _localHandler!.userData[item.uuid]),
          ),
          firstPageProgressIndicatorBuilder: (context) =>
              _widgetBuilder.firstPageProgressIndicatorBuilder(
            context,
            child: Padding(
              padding: const EdgeInsets.only(top: 50.0),
              child: Column(
                children: List.generate(5, (index) => LMFeedUserTileShimmer()),
              ),
            ),
          ),
          newPageProgressIndicatorBuilder: (context) =>
              _widgetBuilder.newPageProgressIndicatorBuilder(
            context,
            child: newPageProgressLikesView(),
          ),
        ),
      ),
    );
  }
}
