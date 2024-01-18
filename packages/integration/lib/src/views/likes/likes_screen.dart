import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/likes/handler/likes_screen_handler.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedLikesScreen extends StatefulWidget {
  static const String route = "/likes_screen";
  final String postId;
  final bool isCommentLikes;
  final String? commentId;

  const LMFeedLikesScreen({
    super.key,
    this.isCommentLikes = false,
    required this.postId,
    this.commentId,
  });

  @override
  State<LMFeedLikesScreen> createState() => _LMFeedLikesScreenState();
}

class _LMFeedLikesScreenState extends State<LMFeedLikesScreen> {
  LMLikesScreenHandler? handler;

  @override
  void initState() {
    super.initState();
    handler = LMLikesScreenHandler.instance;
    handler?.initialise(postId: widget.postId, commentId: widget.commentId);
  }

  @override
  void didUpdateWidget(covariant LMFeedLikesScreen oldWidget) {
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
    return WillPopScope(
      onWillPop: () {
        Navigator.of(context).pop();
        return Future(() => false);
      },
      child: Scaffold(body: getLikesLoadedView()),
    );
  }

  Widget getAppBar(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0),
      child: Row(
        children: [
          LikeMindsTheme.kHorizontalPaddingSmall,
          IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.arrow_back_ios),
          ),
          LikeMindsTheme.kHorizontalPaddingSmall,
          Text(
            text,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          )
        ],
      ),
    );
  }

  Widget getLikesLoadedView() {
    return SafeArea(
      child: Column(
        children: [
          ValueListenableBuilder(
            valueListenable: handler!.totalLikesCountNotifier,
            builder: (context, likesCount, __) {
              return getAppBar(
                "$likesCount ${likesCount == 1 ? 'Likes' : 'Like'}",
              );
            },
          ),
          LikeMindsTheme.kVerticalPaddingLarge,
          Expanded(
            child: PagedListView<int, LMLikeViewData>(
              padding: EdgeInsets.zero,
              pagingController: handler!.pagingController,
              builderDelegate: PagedChildBuilderDelegate<LMLikeViewData>(
                noMoreItemsIndicatorBuilder: (context) => const SizedBox(
                  height: 20,
                ),
                noItemsFoundIndicatorBuilder: (context) => const Scaffold(
                  backgroundColor: LikeMindsTheme.whiteColor,
                  body: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Text("No likes to show",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            )),
                        SizedBox(height: 12),
                        Text(
                          "Be the first one to like this post",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                            color: LikeMindsTheme.greyColor,
                          ),
                        ),
                        SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
                itemBuilder: (context, item, index) =>
                    LikesTile(user: handler!.userData[item.userId]),
                firstPageProgressIndicatorBuilder: (context) => SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 50.0),
                    child: ListView.builder(
                        itemCount: 5,
                        itemBuilder: (context, index) =>
                            const LMFeedUserTileShimmer()),
                  ),
                ),
                newPageProgressIndicatorBuilder: (context) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0),
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

class LikesTile extends StatelessWidget {
  final LMUserViewData? user;
  const LikesTile({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: user!.isDeleted != null && user!.isDeleted!
            ? const DeletedLikesTile()
            : LMFeedUserTile(
                user: user!,
                onTap: () {},
              ),
      );
    } else {
      return const Center(
        child: LMFeedText(text: "No likes yet"),
      );
    }
  }
}

class DeletedLikesTile extends StatelessWidget {
  const DeletedLikesTile({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(27),
          ),
          height: 54,
          width: 54,
        ),
        LikeMindsTheme.kHorizontalPaddingSmall,
        LikeMindsTheme.kHorizontalPaddingMedium,
        const LMFeedText(
          text: 'Deleted User',
          style: LMFeedTextStyle(
            textStyle: TextStyle(
              fontSize: LikeMindsTheme.kFontMedium,
            ),
          ),
        )
      ],
    );
  }
}
