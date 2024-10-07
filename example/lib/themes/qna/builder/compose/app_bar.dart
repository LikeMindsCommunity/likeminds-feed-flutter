import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/packages/pluralize/pluralize.dart';

PreferredSizeWidget qNaComposeAppbarBuilder(
    BuildContext context, LMFeedAppBar oldWidget) {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);

  return oldWidget.copyWith(
    style: oldWidget.style?.copyWith(
      centerTitle: false,
    ),
    title: LMFeedText(
      text: "Create $postTitleFirstCap",
      style: LMFeedTextStyle(
        textStyle: TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 18,
          color: LMFeedCore.theme.onContainer,
        ),
      ),
    ),
  );
}
