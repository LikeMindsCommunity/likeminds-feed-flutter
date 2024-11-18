// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/post/post_utils.dart';
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
  LMFeedWidgetUtility widgetUtility = LMFeedCore.widgetUtility;
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
      child: widgetUtility.scaffold(
          source: LMFeedWidgetSource.likesScreen,
          backgroundColor: feedTheme.container,
          appBar: getAppBar(),
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
                fontFamily: 'Roboto',
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
                  fontFamily: 'Roboto',
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
          noMoreItemsIndicatorBuilder: (context) => const SizedBox(
            height: 20,
          ),
          noItemsFoundIndicatorBuilder: (context) => Scaffold(
            backgroundColor: LikeMindsTheme.whiteColor,
            body: noItemLikesView(),
          ),
          itemBuilder: (context, item, index) =>
              LikesTile(user: handler!.userData[item.uuid]),
          firstPageProgressIndicatorBuilder: (context) => Padding(
            padding: const EdgeInsets.only(top: 50.0),
            child: Column(
              children: List.generate(5, (index) => LMFeedUserTileShimmer()),
            ),
          ),
          newPageProgressIndicatorBuilder: (context) =>
              newPageProgressLikesView(),
        ),
      ),
    );
  }
}

class LikesTile extends StatelessWidget {
  final LMUserViewData? user;
  const LikesTile({
    super.key,
    required this.user,
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
                style: const LMFeedTileStyle(
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
