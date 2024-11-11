part of 'theme.dart';

LMFeedThemeData qnaTheme({
  Color? primaryColor,
  Color? backgroundColor,
  Color? secondaryColor,
  Color? shadowColor,
  Color? disabledColor,
  Color? errorColor,
  Color? inActiveColor,
  Color? tagColor,
  Color? hashTagColor,
  Color? linkColor,
  LMFeedPostStyle? postStyle,
  LMFeedPostReviewBannerStyle? reviewBannerStyle,
  LMFeedPostHeaderStyle? headerStyle,
  LMFeedPostTopicStyle? topicStyle,
  LMFeedPostContentStyle? contentStyle,
  LMFeedPostMediaStyle? mediaStyle,
  LMFeedPostFooterStyle? footerStyle,
  LMFeedCommentStyle? commentStyle,
  LMFeedCommentStyle? replyStyle,
  LMFeedButtonStyle? feedButtonStyle,
  LMFeedIconStyle? feedIconStyle,
  LMFeedTextFieldStyle? textFieldStyle,
  LMFeedDialogStyle? dialogStyle,
  LMFeedPopUpMenuStyle? popUpMenuStyle,
  LMFeedComposeScreenStyle? composeScreenStyle,
  Color? container,
  Color? onContainer,
  Color? onPrimary,
  LMFeedLoaderStyle? loaderStyle,
  LMFeedBottomSheetStyle? bottomSheetStyle,
  LMFeedSnackBarStyle? snackBarTheme,
  Color? textSecondary,
}) {
  return LMFeedThemeData(
    backgroundColor: backgroundColor ?? LikeMindsTheme.backgroundColor,
    primaryColor: primaryColor ?? Colors.green,
    secondaryColor: secondaryColor ?? LikeMindsTheme.secondaryColor,
    shadowColor: shadowColor ?? LikeMindsTheme.shadowColor,
    disabledColor: disabledColor ?? LikeMindsTheme.disabledColor,
    errorColor: errorColor ?? LikeMindsTheme.errorColor,
    inActiveColor: inActiveColor ?? LikeMindsTheme.inactiveColor,
    container: container ?? LikeMindsTheme.container,
    onContainer: onContainer ?? LikeMindsTheme.onContainer,
    onPrimary: onPrimary ?? LikeMindsTheme.onPrimary,
    postStyle: postStyle ??
        LMFeedPostStyle.basic().copyWith(borderRadius: BorderRadius.zero),
    topicStyle:
        topicStyle ?? LMFeedPostTopicStyle.basic(primaryColor: primaryColor),
    contentStyle:
        contentStyle ?? LMFeedPostContentStyle.basic(onContainer: onContainer),
    mediaStyle: mediaStyle ??
        LMFeedPostMediaStyle.basic(
          primaryColor: primaryColor,
          containerColor: container ?? LikeMindsTheme.container,
          inActiveColor: inActiveColor ?? LikeMindsTheme.unSelectedColor,
        ),
    reviewBannerStyle: reviewBannerStyle ??
        LMFeedPostReviewBannerStyle.basic(
          backgroundColor: container ?? LikeMindsTheme.container,
          onContainer: onContainer ?? LikeMindsTheme.onContainer,
        ),
    footerStyle:
        footerStyle ?? LMFeedPostFooterStyle.basic(primaryColor: primaryColor),
    headerStyle: headerStyle ?? LMFeedPostHeaderStyle.basic(),
    hashTagColor: hashTagColor ?? LikeMindsTheme.hashTagColor,
    linkColor: linkColor ?? LikeMindsTheme.linkColor,
    tagColor: tagColor ?? LikeMindsTheme.tagColor,
    textSecondary: textSecondary ?? LikeMindsTheme.greyColor,
    commentStyle: commentStyle ?? LMFeedCommentStyle.basic(),
    replyStyle: replyStyle ?? LMFeedCommentStyle.basic(isReply: true),
    feedButtonStyle: feedButtonStyle ?? const LMFeedButtonStyle(),
    feedIconStyle: feedIconStyle ?? const LMFeedIconStyle(),
    textFieldStyle: textFieldStyle ??
        LMFeedTextFieldStyle.basic(
          backgroundColor: LikeMindsTheme.backgroundColor,
        ),
    dialogStyle: dialogStyle ??
        LMFeedDialogStyle(
          backgroundColor: container ?? LikeMindsTheme.container,
          insetPadding: const EdgeInsets.all(24.0),
        ),
    popUpMenuStyle: popUpMenuStyle ?? const LMFeedPopUpMenuStyle(),
    composeScreenStyle: composeScreenStyle ??
        LMFeedComposeScreenStyle.basic(
          primaryColor: primaryColor,
        ),
    loaderStyle: loaderStyle ??
        LMFeedLoaderStyle(
          color: primaryColor ?? LikeMindsTheme.primaryColor,
        ),
    bottomSheetStyle: bottomSheetStyle ?? const LMFeedBottomSheetStyle(),
    snackBarTheme: snackBarTheme ??
        LMFeedSnackBarStyle(
          behavior: SnackBarBehavior.floating,
          backgroundColor: primaryColor ?? LikeMindsTheme.primaryColor,
        ),
  );
}
