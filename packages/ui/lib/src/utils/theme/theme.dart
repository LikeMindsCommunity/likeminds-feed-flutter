import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
export 'styles/styles.dart';

class LMFeedTheme {
  static LMFeedTheme? _instance;
  static LMFeedTheme get instance => _instance ??= LMFeedTheme._();

  LMFeedTheme._();

  late LMFeedThemeData theme;

  void initialise({LMFeedThemeData? theme}) {
    this.theme = theme ?? LMFeedThemeData.light();
  }
}

class LMFeedThemeData {
  final LMFeedPostStyle postStyle;
  final LMFeedPostReviewBannerStyle reviewBannerStyle;
  final LMFeedPostHeaderStyle headerStyle;
  final LMFeedPostTopicStyle topicStyle;
  final LMFeedPostContentStyle contentStyle;
  final LMFeedPostMediaStyle mediaStyle;
  final LMFeedPostFooterStyle footerStyle;
  final LMFeedCommentStyle commentStyle;
  final LMFeedCommentStyle replyStyle;
  final LMFeedButtonStyle feedButtonStyle;
  final LMFeedIconStyle feedIconStyle;
  final LMFeedTextFieldStyle textFieldStyle;
  final LMFeedDialogStyle dialogStyle;
  final LMFeedPopUpMenuStyle popUpMenuStyle;
  final LMFeedComposeScreenStyle composeScreenStyle;
  final LMFeedLoaderStyle loaderStyle;
  final LMFeedBottomSheetStyle bottomSheetStyle;
  final LMFeedSnackBarStyle snackBarTheme;

  final Color primaryColor;
  final Color backgroundColor;
  final Color secondaryColor;
  final Color shadowColor;
  final Color disabledColor;
  final Color errorColor;
  final Color inActiveColor;
  final Color tagColor;
  final Color hashTagColor;
  final Color linkColor;
  final Color container;
  final Color onContainer;
  final Color onPrimary;
  final Color textSecondary;

  const LMFeedThemeData({
    required this.postStyle,
    required this.reviewBannerStyle,
    required this.headerStyle,
    required this.topicStyle,
    required this.contentStyle,
    required this.mediaStyle,
    required this.footerStyle,
    required this.primaryColor,
    required this.backgroundColor,
    required this.secondaryColor,
    required this.shadowColor,
    required this.disabledColor,
    required this.errorColor,
    required this.inActiveColor,
    required this.tagColor,
    required this.hashTagColor,
    required this.linkColor,
    required this.commentStyle,
    required this.replyStyle,
    required this.feedButtonStyle,
    required this.feedIconStyle,
    required this.container,
    required this.onContainer,
    required this.onPrimary,
    required this.textFieldStyle,
    required this.dialogStyle,
    required this.popUpMenuStyle,
    required this.composeScreenStyle,
    required this.loaderStyle,
    required this.bottomSheetStyle,
    required this.snackBarTheme,
    required this.textSecondary,
  });

  factory LMFeedThemeData.fromThemeData(ThemeData theme) {
    return LMFeedThemeData.light(
      backgroundColor: theme.colorScheme.background,
      primaryColor: theme.primaryColor,
      secondaryColor: theme.colorScheme.secondary,
      shadowColor: theme.shadowColor,
      disabledColor: theme.disabledColor,
      errorColor: theme.colorScheme.error,
      inActiveColor: theme.unselectedWidgetColor,
      container: theme.colorScheme.background,
      onContainer: theme.colorScheme.onPrimaryContainer,
      onPrimary: theme.colorScheme.onPrimary,
    );
  }

  factory LMFeedThemeData.light({
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
      primaryColor: primaryColor ?? LikeMindsTheme.primaryColor,
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
      contentStyle: contentStyle ??
          LMFeedPostContentStyle.basic(onContainer: onContainer),
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
      footerStyle: footerStyle ??
          LMFeedPostFooterStyle.basic(primaryColor: primaryColor),
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

  /// copyWith method to update the theme
  LMFeedThemeData copyWith({
    LMFeedPostStyle? postStyle,
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
    LMFeedCommentStyle? commentStyle,
    LMFeedCommentStyle? replyStyle,
    LMFeedButtonStyle? feedButtonStyle,
    LMFeedIconStyle? feedIconStyle,
    Color? container,
    Color? onContainer,
    Color? onPrimary,
    Color? textSecondary,
    LMFeedTextFieldStyle? textFieldStyle,
    LMFeedDialogStyle? dialogStyle,
    LMFeedPopUpMenuStyle? popUpMenuStyle,
    LMFeedPostReviewBannerStyle? reviewBannerStyle,
    LMFeedPostHeaderStyle? headerStyle,
    LMFeedPostTopicStyle? topicStyle,
    LMFeedPostContentStyle? contentStyle,
    LMFeedPostMediaStyle? mediaStyle,
    LMFeedPostFooterStyle? footerStyle,
    LMFeedComposeScreenStyle? composeScreenStyle,
    LMFeedLoaderStyle? loaderStyle,
    LMFeedBottomSheetStyle? bottomSheetStyle,
    LMFeedSnackBarStyle? snackBarTheme,
  }) {
    return LMFeedThemeData(
      postStyle: postStyle ?? this.postStyle,
      primaryColor: primaryColor ?? this.primaryColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      secondaryColor: secondaryColor ?? this.secondaryColor,
      shadowColor: shadowColor ?? this.shadowColor,
      disabledColor: disabledColor ?? this.disabledColor,
      errorColor: errorColor ?? this.errorColor,
      inActiveColor: inActiveColor ?? this.inActiveColor,
      tagColor: tagColor ?? this.tagColor,
      hashTagColor: hashTagColor ?? this.hashTagColor,
      linkColor: linkColor ?? this.linkColor,
      commentStyle: commentStyle ?? this.commentStyle,
      replyStyle: replyStyle ?? this.replyStyle,
      feedButtonStyle: feedButtonStyle ?? this.feedButtonStyle,
      feedIconStyle: feedIconStyle ?? this.feedIconStyle,
      container: container ?? this.container,
      onContainer: onContainer ?? this.onContainer,
      onPrimary: onPrimary ?? this.onPrimary,
      dialogStyle: dialogStyle ?? this.dialogStyle,
      textFieldStyle: textFieldStyle ?? this.textFieldStyle,
      popUpMenuStyle: popUpMenuStyle ?? this.popUpMenuStyle,
      headerStyle: headerStyle ?? this.headerStyle,
      topicStyle: topicStyle ?? this.topicStyle,
      contentStyle: contentStyle ?? this.contentStyle,
      mediaStyle: mediaStyle ?? this.mediaStyle,
      footerStyle: footerStyle ?? this.footerStyle,
      composeScreenStyle: composeScreenStyle ?? this.composeScreenStyle,
      loaderStyle: loaderStyle ?? this.loaderStyle,
      bottomSheetStyle: bottomSheetStyle ?? this.bottomSheetStyle,
      snackBarTheme: snackBarTheme ?? this.snackBarTheme,
      reviewBannerStyle: reviewBannerStyle ?? this.reviewBannerStyle,
      textSecondary: textSecondary ?? this.textSecondary,
    );
  }
}

class LikeMindsTheme {
  static const Color backgroundColor = Color.fromRGBO(208, 216, 226, 1);
  static const Color primaryColor = Color.fromRGBO(80, 70, 229, 1);
  static const Color secondaryColor = Color.fromRGBO(72, 79, 103, 1);
  static const Color shadowColor = Color.fromRGBO(0, 0, 0, 0.239);
  static const Color disabledColor = Color.fromRGBO(208, 216, 226, 1);
  static const Color errorColor = Color.fromRGBO(251, 22, 9, 1);
  static const Color inactiveColor = Color.fromRGBO(155, 155, 155, 1);
  static const Color whiteColor = Color.fromRGBO(255, 255, 255, 1);
  static const Color greyColor = Color.fromRGBO(102, 102, 102, 1);
  static const Color blackColor = Color.fromRGBO(0, 0, 0, 1);
  static const Color tagColor = Color.fromRGBO(0, 122, 255, 1);
  static const Color hashTagColor = Color.fromRGBO(0, 122, 255, 1);
  static const Color linkColor = Color.fromRGBO(0, 122, 255, 1);
  static const Color headingColor = Color.fromRGBO(51, 51, 51, 1);
  static const Color unSelectedColor = Color.fromRGBO(230, 235, 245, 1);
  static const Color container = whiteColor;
  static const Color onContainer = blackColor;
  static const Color onPrimary = whiteColor;

  static const double kFontSmall = 12;
  static const double kButtonFontSize = 12;
  static const double kFontXSmall = 11;
  static const double kFontSmallMed = 14;
  static const double kFontMedium = 16;
  static const double kPaddingXSmall = 2;
  static const double kPaddingSmall = 4;
  static const double kPaddingMedium = 8;
  static const double kPaddingLarge = 16;
  static const double kPaddingXLarge = 20;
  static const double kBorderRadiusXSmall = 2;
  static const double kBorderRadiusMedium = 8;
  static const SizedBox kHorizontalPaddingXLarge =
      SizedBox(width: kPaddingXLarge);
  static const SizedBox kHorizontalPaddingSmall =
      SizedBox(width: kPaddingSmall);
  static const SizedBox kHorizontalPaddingXSmall =
      SizedBox(width: kPaddingXSmall);
  static const SizedBox kHorizontalPaddingLarge =
      SizedBox(width: kPaddingLarge);
  static const SizedBox kHorizontalPaddingMedium =
      SizedBox(width: kPaddingMedium);
  static const SizedBox kVerticalPaddingXLarge =
      SizedBox(height: kPaddingXLarge);
  static const SizedBox kVerticalPaddingSmall = SizedBox(height: kPaddingSmall);
  static const SizedBox kVerticalPaddingXSmall =
      SizedBox(height: kPaddingXSmall);
  static const SizedBox kVerticalPaddingMedium =
      SizedBox(height: kPaddingMedium);
  static const SizedBox kVerticalPaddingLarge = SizedBox(height: kPaddingLarge);
}

class LMFeedTextFieldStyle {
  final Color? backgroundColor;
  final InputDecoration? decoration;

  const LMFeedTextFieldStyle({
    this.backgroundColor,
    this.decoration,
  });

  LMFeedTextFieldStyle copyWith({
    Color? backgroundColor,
    InputDecoration? decoration,
  }) {
    return LMFeedTextFieldStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      decoration: decoration ?? this.decoration,
    );
  }

  factory LMFeedTextFieldStyle.basic({
    Color? backgroundColor,
  }) {
    return LMFeedTextFieldStyle(
      backgroundColor: backgroundColor ?? LikeMindsTheme.backgroundColor,
      decoration: const InputDecoration(
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
      ),
    );
  }
}

class LMFeedDialogStyle {
  final Alignment? alignment;
  final Color? backgroundColor;
  final Clip clipBehavior;
  final double? elevation;
  final Curve insetAnimationCurve;
  final Duration insetAnimationDuration;
  final EdgeInsets insetPadding;
  final EdgeInsets padding;
  final Color? shadowColor;
  final ShapeBorder? shape;
  final Color surfaceTintColor;
  final BoxConstraints constraints;

  const LMFeedDialogStyle({
    this.alignment,
    this.backgroundColor,
    this.clipBehavior = Clip.none,
    this.elevation,
    this.insetAnimationCurve = Curves.decelerate,
    this.insetAnimationDuration = const Duration(milliseconds: 100),
    this.insetPadding =
        const EdgeInsets.symmetric(horizontal: 40.0, vertical: 24.0),
    this.padding = const EdgeInsets.all(24.0),
    this.shadowColor,
    this.shape,
    this.surfaceTintColor = Colors.transparent,
    this.constraints = const BoxConstraints(maxWidth: 400),
  });

  LMFeedDialogStyle copyWith({
    Alignment? alignment,
    Color? backgroundColor,
    Clip? clipBehavior,
    double? elevation,
    Curve? insetAnimationCurve,
    Duration? insetAnimationDuration,
    EdgeInsets? insetPadding,
    EdgeInsets? padding,
    Color? shadowColor,
    ShapeBorder? shape,
    Color? surfaceTintColor,
    BoxConstraints? constraints,
  }) {
    return LMFeedDialogStyle(
      alignment: alignment ?? this.alignment,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      clipBehavior: clipBehavior ?? this.clipBehavior,
      elevation: elevation ?? this.elevation,
      insetAnimationCurve: insetAnimationCurve ?? this.insetAnimationCurve,
      insetAnimationDuration:
          insetAnimationDuration ?? this.insetAnimationDuration,
      insetPadding: insetPadding ?? this.insetPadding,
      shadowColor: shadowColor ?? this.shadowColor,
      shape: shape ?? this.shape,
      surfaceTintColor: surfaceTintColor ?? this.surfaceTintColor,
      padding: padding ?? this.padding,
      constraints: constraints ?? this.constraints,
    );
  }
}

class LMFeedPopUpMenuStyle {
  final Color? backgroundColor;
  final LMFeedIcon? icon;
  final LMFeedIcon? activeIcon;
  final Color? activeBackgroundColor;
  final Color? activeColor;
  final Color? inActiveColor;
  final double? width;
  final double? height;
  final Border? border;
  final Color? borderColor;
  final double? borderWidth;

  const LMFeedPopUpMenuStyle({
    this.backgroundColor,
    this.icon,
    this.activeIcon,
    this.activeBackgroundColor,
    this.activeColor,
    this.inActiveColor,
    this.width,
    this.height,
    this.border,
    this.borderColor,
    this.borderWidth,
  });

  LMFeedPopUpMenuStyle copyWith({
    Color? backgroundColor,
    LMFeedIcon? icon,
    LMFeedIcon? activeIcon,
    Color? activeBackgroundColor,
    Color? activeColor,
    Color? inActiveColor,
    double? width,
    double? height,
  }) {
    return LMFeedPopUpMenuStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      icon: icon ?? this.icon,
      activeIcon: activeIcon ?? this.activeIcon,
      activeBackgroundColor:
          activeBackgroundColor ?? this.activeBackgroundColor,
      activeColor: activeColor ?? this.activeColor,
      inActiveColor: inActiveColor ?? this.inActiveColor,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
