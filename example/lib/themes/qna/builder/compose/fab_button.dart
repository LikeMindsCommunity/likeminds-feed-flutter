import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/constants/assets_constants.dart';

Widget qnAFeedCreatePostFABBuilder(context, floatingActionButton) {
  LMFeedThemeData feedTheme = LMFeedCore.theme;
  return GestureDetector(
    onTap: floatingActionButton.onTap,
    child: Container(
      height: 50,
      decoration: BoxDecoration(
        color: feedTheme.primaryColor,
        borderRadius: BorderRadius.circular(25.0),
      ),
      margin: const EdgeInsets.only(
        bottom: 10,
      ),
      padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: qNaAssetCreatePostIcon,
            style: LMFeedIconStyle(
              color: feedTheme.onPrimary,
            ),
          ),
          LikeMindsTheme.kHorizontalPaddingLarge,
          LMFeedText(
            text: "Start something new",
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                color: feedTheme.onPrimary,
              ),
            ),
          )
        ],
      ),
    ),
  );
}
