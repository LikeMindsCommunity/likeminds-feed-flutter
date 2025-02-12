// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
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
        body: LMFeedLikeListView(
          postId: widget.postId,
          commentId: widget.commentId,
          isCommentLikes: widget.isCommentLikes,
          widgetSource: widget.widgetSource,
        ),
      ),
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
    String likeText = LMFeedPostUtils.getLikeTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalPlural,
    );
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
      return Center(
        child: LMFeedText(text: "No $likeText yet"),
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
