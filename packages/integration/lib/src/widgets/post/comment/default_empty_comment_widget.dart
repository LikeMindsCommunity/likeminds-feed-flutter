import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/feed/platform_utils.dart';

class LMFeedEmptyCommentWidget extends StatelessWidget {
  const LMFeedEmptyCommentWidget({
    super.key,
    this.titleBuilder,
    this.subTitleBuilder,
  });
  final LMFeedTextBuilder? titleBuilder;
  final LMFeedTextBuilder? subTitleBuilder;

  @override
  Widget build(BuildContext context) {
    LMFeedThemeData feedTheme = LMFeedCore.theme;
    LMFeedPlatform platform = LMFeedPlatform.instance;
    bool isWeb = platform.isWeb();

    String commentTitleSmallCapPlural = LMFeedPostUtils.getCommentTitle(
        LMFeedPluralizeWordAction.allSmallPlural);
    String commentTitleSmallCapSingular = LMFeedPostUtils.getCommentTitle(
        LMFeedPluralizeWordAction.allSmallSingular);

    return isWeb
        ? const SizedBox.shrink()
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 60,
              ),
              titleBuilder?.call(
                    context,
                    _defTitle(commentTitleSmallCapPlural, feedTheme),
                  ) ??
                  _defTitle(commentTitleSmallCapPlural, feedTheme),
              subTitleBuilder?.call(
                    context,
                    _defSubTitle(commentTitleSmallCapSingular, feedTheme),
                  ) ??
                  _defSubTitle(commentTitleSmallCapSingular, feedTheme),
              SizedBox(
                height: 60,
              ),
            ],
          );
  }

  LMFeedText _defSubTitle(
      String commentTitleSmallCapSingular, LMFeedThemeData feedTheme) {
    return LMFeedText(
      text: 'Be the first one to create a $commentTitleSmallCapSingular',
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontWeight: FontWeight.w500,
          color: feedTheme.onContainer,
          fontSize: 14,
        ),
      ),
    );
  }

  LMFeedText _defTitle(
      String commentTitleSmallCapPlural, LMFeedThemeData feedTheme) {
    return LMFeedText(
      text: 'No $commentTitleSmallCapPlural found!',
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontWeight: FontWeight.w600,
          color: feedTheme.onContainer,
          fontSize: 16,
        ),
      ),
    );
  }
}
