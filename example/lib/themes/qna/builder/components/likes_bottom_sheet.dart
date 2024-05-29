import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
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
  LMUserViewData? currentUser = LMFeedLocalPreference.instance.fetchUserData();

  @override
  void initState() {
    super.initState();

    handler = LMLikesScreenHandler.instance;
    handler?.initialise(postId: widget.postId, commentId: widget.commentId);

    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.likeListOpen,
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
    LMFeedThemeData theme = LMFeedCore.theme;
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
                        const LMFeedTextStyle(
                          textStyle: TextStyle(
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
    LMUserViewData likeTileUserData = handler!.userData[likeViewData.uuid]!;

    if (currentUser == null) {
      return;
    }
    if (likeTileUserData.sdkClientInfo.uuid !=
        currentUser!.sdkClientInfo.uuid) {
      LMFeedProfileBloc.instance.add(LMFeedRouteToUserProfileEvent(
        uuid: likeViewData.uuid,
        context: context,
      ));
    } else {
      LMFeedPostBloc postBloc = LMFeedPostBloc.instance;

      List<LMLikeViewData>? likesList = handler!.pagingController.itemList;

      int index = likesList
              ?.indexWhere((element) => element.uuid == currentUser!.uuid) ??
          -1;

      if (index != -1) {
        handler!.pagingController.itemList?.removeAt(index);
        setState(() {});
        if (widget.commentId == null) {
          LikePostRequest likePostRequest =
              (LikePostRequestBuilder()..postId(widget.postId)).build();

          postBloc.add(LMFeedUpdatePostEvent(
              actionType: LMFeedPostActionType.unlike, postId: widget.postId));

          LikePostResponse response =
              await LMFeedCore.client.likePost(likePostRequest);

          if (!response.success) {
            postBloc.add(LMFeedUpdatePostEvent(
                actionType: LMFeedPostActionType.like, postId: widget.postId));
          }
        } else {
          ToggleLikeCommentRequest likeCommentRequest =
              (ToggleLikeCommentRequestBuilder()
                    ..postId(widget.postId)
                    ..commentId(widget.commentId!))
                  .build();

          postBloc.add(LMFeedUpdatePostEvent(
              actionType: LMFeedPostActionType.unlike, postId: widget.postId));

          ToggleLikeCommentResponse response =
              await LMFeedCore.client.likeComment(likeCommentRequest);

          if (!response.success) {
            postBloc.add(LMFeedUpdatePostEvent(
                actionType: LMFeedPostActionType.like, postId: widget.postId));
          }
        }
      }
    }
  }

  LMFeedTile defLikesTile(LMLikeViewData like) {
    return LMFeedTile(
      onTap: () => onUserTap(like),
      style: LMFeedTileStyle(
          backgroundColor: feedTheme?.container,
          padding:
              const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0)),
      title: LMFeedText(
        text: handler!.userData[like.uuid]!.name,
      ),
      leading: LMFeedProfilePicture(
        fallbackText: handler!.userData[like.uuid]!.name,
        imageUrl: handler!.userData[like.uuid]!.imageUrl,
        onTap: () => onUserTap(like),
      ),
      subtitle: like.uuid == currentUser!.uuid
          ? const LMFeedText(text: "Tap to remove")
          : null,
    );
  }
}
