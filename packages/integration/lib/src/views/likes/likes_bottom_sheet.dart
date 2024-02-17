import 'package:flutter/material.dart';
import 'package:infinite_scroll_pagination/infinite_scroll_pagination.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedLikesBottomSheet extends StatefulWidget {
  final String postId;
  final String? commentId;

  final Widget Function(BuildContext, LMLikeViewData)? likeTileBuilder;

  const LMFeedLikesBottomSheet({
    super.key,
    required this.postId,
    this.commentId,
    this.likeTileBuilder,
  });

  @override
  State<LMFeedLikesBottomSheet> createState() => _LMFeedLikesBottomSheetState();
}

class _LMFeedLikesBottomSheetState extends State<LMFeedLikesBottomSheet> {
  final PagingController<int, LMLikeViewData> pagingController =
      PagingController(firstPageKey: 1);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    LMFeedThemeData theme = LMFeedTheme.of(context);
    return Container(
      constraints: BoxConstraints(
          minHeight: screenSize.height * 0.4, minWidth: screenSize.width),
      decoration: BoxDecoration(
        color: theme.container,
      ),
      child: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              pinned: true,
              title: Container(
                width: 40,
                height: 5,
                margin: EdgeInsets.symmetric(vertical: 10.0),
                decoration: BoxDecoration(
                  color: theme.disabledColor,
                  borderRadius: BorderRadius.circular(5.0),
                ),
              ),
            ),
            PagedSliverList(
              pagingController: pagingController,
              builderDelegate: PagedChildBuilderDelegate<LMLikeViewData>(
                itemBuilder: (context, like, index) =>
                    widget.likeTileBuilder?.call() ??
                    LMFeedLikeTile(like: like),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LMFeedLikesBottomSheetStyle {
  final Color? backgroundColor;
  final Color? topNotchColor;
  final LMFeedTextStyle? usertitleStyle;
  final LMFeedTextStyle? usersubtitleStyle;
  final LMFeedTextStyle? headingStyle;
  final LMFeedProfilePictureStyle? profilePictureStyle;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
}
