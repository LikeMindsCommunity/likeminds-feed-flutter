import 'dart:io';

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

PreferredSizeWidget qNaPostDetailScreenAppBarBuilder(
    BuildContext context, LMFeedAppBar appBar) {
  String postTitleFirstCap = LMFeedPostUtils.getPostTitle(
      LMFeedPluralizeWordAction.firstLetterCapitalSingular);

  return appBar.copyWith(
    title: LMFeedText(
      text: postTitleFirstCap,
      style: const LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          fontFamily: 'Inter',
        ),
      ),
    ),
    style: appBar.style?.copyWith(
      centerTitle: Platform.isAndroid ? false : true,
      height: 50,
    ),
  );
}
