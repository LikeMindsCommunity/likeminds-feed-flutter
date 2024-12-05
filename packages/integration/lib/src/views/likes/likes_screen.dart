// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/views/likes/widgets/widgets.dart';

part 'handler/likes_screen_handler.dart';

class LMFeedLikesScreen extends StatefulWidget {
  static const String route = "/likes_screen";
  final String postId;
  final bool isCommentLikes;
  final String? commentId;
  final LMFeedWidgetSource? widgetSource;

  const LMFeedLikesScreen({
    super.key,
    this.isCommentLikes = false,
    required this.postId,
    this.commentId,
    this.widgetSource,
  });

  @override
  State<LMFeedLikesScreen> createState() => _LMFeedLikesScreenState();
}

class _LMFeedLikesScreenState extends State<LMFeedLikesScreen> {
  LMLikesScreenHandler? handler;
  LMFeedThemeData feedTheme = LMFeedCore.theme;
  LMFeedLikeScreenBuilderDelegate _widgetBuilder =
      LMFeedCore.config.likeScreenConfig.builder;
  String likeText = LMFeedPostUtils.getLikeTitle(
    LMFeedPluralizeWordAction.firstLetterCapitalPlural,
  );

  @override
  void initState() {
    super.initState();
    handler = LMLikesScreenHandler.instance;
    handler?.initialise(postId: widget.postId, commentId: widget.commentId);

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
      child: _widgetBuilder.scaffold(
          source: LMFeedWidgetSource.likesScreen,
          backgroundColor: feedTheme.container,
          appBar: _widgetBuilder.appBarBuilder(
            context,
            getAppBar(),
          ),
          body: getLikesLoadedView()),
    );
  }

  LMFeedAppBar getAppBar() {
    return LMFeedAppBar(
      style: LMFeedAppBarStyle(
        backgroundColor: feedTheme.container,
        height: 60,
      ),
      leading: BackButton(),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          LMFeedText(
            text: likeText,
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                color: Color(0xFF333333),
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ValueListenableBuilder(
            valueListenable: handler!.totalLikesCountNotifier,
            builder: (context, likesCount, __) {
              return Text(
                LMFeedPostUtils.getLikeCountTextWithCount(
                  likesCount,
                ),
                style: const TextStyle(
                  color: Color(0xFF666666),
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget getLikesLoadedView() {
    return SafeArea(
      child: PagedListView<int, LMLikeViewData>(
        padding: EdgeInsets.zero,
        pagingController: handler!.pagingController,
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
            handler!.userData[item.uuid]!,
            LMFeedLikeTile(user: handler!.userData[item.uuid]),
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

class LMFeedLikeTile extends StatelessWidget {
  final LMUserViewData? user;
  final LMFeedTileStyle? style;

  const LMFeedLikeTile({
    super.key,
    required this.user,
    this.style = const LMFeedTileStyle(
      padding: EdgeInsets.only(
        left: 16.0,
        top: 16.0,
        right: 8.0,
      ),
    ),
  });

  @override
  Widget build(BuildContext context) {
    if (user != null) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: user!.isDeleted != null && user!.isDeleted!
            ? const DeletedLikesTile()
            : LMFeedUserTile(
                user: user!,
                style: style ??
                    const LMFeedTileStyle(
                      padding: EdgeInsets.only(
                        left: 16.0,
                        top: 16.0,
                        right: 8.0,
                      ),
                    ),
                onTap: () {
                  LMFeedProfileBloc.instance.add(
                    LMFeedRouteToUserProfileEvent(
                      uuid: user?.sdkClientInfo.uuid ?? user?.uuid ?? '',
                      context: context,
                    ),
                  );
                },
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
