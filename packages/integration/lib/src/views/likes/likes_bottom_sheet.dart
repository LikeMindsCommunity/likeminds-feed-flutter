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
  LMLikesScreenHandler? handler;
  LMFeedThemeData? feedTheme;

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
    return handler == null
        ? const SizedBox()
        : Container(
            constraints: BoxConstraints(
              maxHeight: screenSize.height * 0.4,
              minWidth: screenSize.width,
            ),
            decoration: BoxDecoration(
              color: theme.container,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20.0),
                topRight: Radius.circular(20.0),
              ),
            ),
            child: SafeArea(
              child: CustomScrollView(
                physics: const FixedExtentScrollPhysics(),
                slivers: [
                  SliverAppBar(
                    pinned: true,
                    leading: null,
                    backgroundColor: theme.container,
                    centerTitle: true,
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
                    pagingController: handler!.pagingController,
                    builderDelegate: PagedChildBuilderDelegate<LMLikeViewData>(
                      itemBuilder: (context, like, index) =>
                          LikesTile(user: handler!.userData[like.userId]),
                      // widget.likeTileBuilder?.call() ??
                      // LMFeedLikeTile(like: like),
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

  const LMFeedLikesBottomSheetStyle({
    this.backgroundColor,
    this.topNotchColor,
    this.usertitleStyle,
    this.usersubtitleStyle,
    this.headingStyle,
    this.profilePictureStyle,
    this.borderRadius,
    this.padding,
    this.margin,
  });

  LMFeedLikesBottomSheetStyle copyWith({
    Color? backgroundColor,
    Color? topNotchColor,
    LMFeedTextStyle? usertitleStyle,
    LMFeedTextStyle? usersubtitleStyle,
    LMFeedTextStyle? headingStyle,
    LMFeedProfilePictureStyle? profilePictureStyle,
    BorderRadius? borderRadius,
    EdgeInsets? padding,
    EdgeInsets? margin,
  }) {
    return LMFeedLikesBottomSheetStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      topNotchColor: topNotchColor ?? this.topNotchColor,
      usertitleStyle: usertitleStyle ?? this.usertitleStyle,
      usersubtitleStyle: usersubtitleStyle ?? this.usersubtitleStyle,
      headingStyle: headingStyle ?? this.headingStyle,
      profilePictureStyle: profilePictureStyle ?? this.profilePictureStyle,
      borderRadius: borderRadius ?? this.borderRadius,
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
    );
  }
}
