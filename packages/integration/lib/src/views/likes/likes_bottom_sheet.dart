import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/utils.dart';
import 'package:likeminds_feed_flutter_core/src/views/likes/widgets/widgets.dart';

class LMFeedLikesBottomSheet extends StatefulWidget {
  final String postId;
  final String? commentId;
  final LMFeedBottomSheetStyle? style;
  final LMFeedTileBuilder? likeTileBuilder;

  final LMFeedContextWidgetBuilder? noNewItemBuilder;
  final LMFeedContextWidgetBuilder? noItemBuilder;
  final LMFeedContextWidgetBuilder? newPageProgressBuilder;
  final LMFeedContextWidgetBuilder? firstPageProgressBuilder;

  const LMFeedLikesBottomSheet({
    super.key,
    required this.postId,
    this.commentId,
    this.style,
    this.likeTileBuilder,
    this.noNewItemBuilder,
    this.noItemBuilder,
    this.newPageProgressBuilder,
    this.firstPageProgressBuilder,
  });

  @override
  State<LMFeedLikesBottomSheet> createState() => _LMFeedLikesBottomSheetState();
}

class _LMFeedLikesBottomSheetState extends State<LMFeedLikesBottomSheet> {
  LMLikesScreenHandler? handler;
  LMFeedThemeData? feedTheme;
  LMUserViewData currentUser =
      LMFeedUserLocalPreference.instance.fetchUserData();

  @override
  void initState() {
    super.initState();

    handler = LMLikesScreenHandler.instance;
    handler?.initialise(postId: widget.postId, commentId: widget.commentId);

    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.likeListOpen,
        deprecatedEventName: LMFeedAnalyticsKeysDep.likeListOpen,
        eventProperties: {
          'postId': widget.postId,
        },
      ),
    );
  }

  @override
  void didUpdateWidget(LMFeedLikesBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.postId != oldWidget.postId ||
        widget.commentId != oldWidget.commentId) {
      handler?.initialise(postId: widget.postId, commentId: widget.commentId);
    }
  }

  @override
  void dispose() {
    super.dispose();
    handler?.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    LMFeedThemeData theme = LMFeedTheme.of(context);
    LMFeedBottomSheetStyle bottomSheetStyle =
        widget.style ?? theme.bottomSheetStyle;

    return handler == null
        ? const SizedBox()
        : CustomScrollView(
            shrinkWrap: true,
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  alignment: Alignment.topLeft,
                  margin: const EdgeInsets.only(bottom: 5.0),
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: LMFeedText(
                    text: "Likes",
                    style: bottomSheetStyle.titleStyle ??
                        LMFeedTextStyle(
                          textStyle: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 20,
                          ),
                        ),
                  ),
                ),
              ),
              PagedSliverList(
                pagingController: handler!.pagingController,
                shrinkWrapFirstPageIndicators: true,
                builderDelegate: PagedChildBuilderDelegate<LMLikeViewData>(
                  itemBuilder: (context, like, index) =>
                      widget.likeTileBuilder
                          ?.call(context, defLikesTile(like)) ??
                      defLikesTile(like),
                  firstPageProgressIndicatorBuilder: (context) =>
                      widget.firstPageProgressBuilder?.call(context) ??
                      newPageProgressLikesView(),
                  newPageProgressIndicatorBuilder: (context) =>
                      widget.newPageProgressBuilder?.call(context) ??
                      newPageProgressLikesView(),
                  noItemsFoundIndicatorBuilder: (context) =>
                      widget.noItemBuilder?.call(context) ?? noItemLikesView(),
                  noMoreItemsIndicatorBuilder: (context) =>
                      widget.noNewItemBuilder?.call(context) ??
                      const SizedBox(height: 20),
                ),
              ),
            ],
          );
  }

  void onUserTap(LMLikeViewData likeViewData) async {
    if (likeViewData.userId != currentUser.userUniqueId) {
      LMFeedProfileBloc.instance.add(LMFeedRouteToUserProfileEvent(
        userUniqueId: likeViewData.userId,
      ));
    } else {
      List<LMLikeViewData>? likesList = handler!.pagingController.itemList;

      int index = likesList?.indexWhere(
              (element) => element.userId == currentUser.userUniqueId) ??
          -1;

      if (index != -1) {
        handler!.pagingController.itemList?.removeAt(index);
        setState(() {});
        if (widget.commentId == null) {
          LikePostRequest likePostRequest =
              (LikePostRequestBuilder()..postId(widget.postId)).build();
          await LMFeedCore.client.likePost(likePostRequest);
        } else {
          ToggleLikeCommentRequest likeCommentRequest =
              (ToggleLikeCommentRequestBuilder()
                    ..postId(widget.postId)
                    ..commentId(widget.commentId!))
                  .build();
          await LMFeedCore.client.likeComment(likeCommentRequest);
        }
        LMFeedBloc.instance.add(LMFeedUpdatePostEvent(post: ));
      }
    }
  }

  LMFeedTile defLikesTile(LMLikeViewData like) {
    return LMFeedTile(
      onTap: () => onUserTap(like),
      style: LMFeedTileStyle(
          backgroundColor: feedTheme?.container,
          padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)),
      title: LMFeedText(
        text: handler!.userData[like.userId]!.name,
      ),
      leading: LMFeedProfilePicture(
        fallbackText: handler!.userData[like.userId]!.name,
        imageUrl: handler!.userData[like.userId]!.imageUrl,
        onTap: () => onUserTap(like),
      ),
      subtitle: like.userId == currentUser.userUniqueId
          ? LMFeedText(text: "Tap to remove")
          : null,
    );
  }
}
