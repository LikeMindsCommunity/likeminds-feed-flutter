import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';
export 'styles/styles.dart';

class LMFeedTheme extends InheritedWidget {
  const LMFeedTheme({super.key, required this.theme, required super.child});

  final LMFeedThemeData theme;

  @override
  bool updateShouldNotify(covariant LMFeedTheme oldWidget) {
    return theme != oldWidget.theme;
  }

  static LMFeedThemeData of(BuildContext context) {
    final lmTheme = context.dependOnInheritedWidgetOfExactType<LMFeedTheme>();

    return lmTheme?.theme ?? LMFeedThemeData.light();
  }
}

class LMFeedThemeData {
  final LMFeedPostStyle postStyle;
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

  const LMFeedThemeData({
    required this.postStyle,
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
        postStyle: postStyle ?? LMFeedPostStyle.basic(),
        topicStyle: topicStyle ??
            LMFeedPostTopicStyle.basic(primaryColor: primaryColor),
        contentStyle: contentStyle ??
            LMFeedPostContentStyle.basic(onContainer: onContainer),
        mediaStyle: mediaStyle ?? LMFeedPostMediaStyle.basic(),
        footerStyle: footerStyle ??
            LMFeedPostFooterStyle.basic(primaryColor: primaryColor),
        headerStyle: headerStyle ?? LMFeedPostHeaderStyle.basic(),
        hashTagColor: hashTagColor ?? LikeMindsTheme.hashTagColor,
        linkColor: linkColor ?? LikeMindsTheme.linkColor,
        tagColor: tagColor ?? LikeMindsTheme.tagColor,
        commentStyle: commentStyle ?? LMFeedCommentStyle.basic(),
        replyStyle: replyStyle ?? LMFeedCommentStyle.basic(isReply: true),
        feedButtonStyle: feedButtonStyle ?? const LMFeedButtonStyle(),
        feedIconStyle: feedIconStyle ?? const LMFeedIconStyle(),
        textFieldStyle: textFieldStyle ??
            LMFeedTextFieldStyle.basic(
              backgroundColor: LikeMindsTheme.backgroundColor,
            ),
        dialogStyle: dialogStyle ?? const LMFeedDialogStyle(),
        popUpMenuStyle: popUpMenuStyle ?? const LMFeedPopUpMenuStyle(),
        composeScreenStyle: composeScreenStyle ??
            LMFeedComposeScreenStyle.basic(primaryColor: primaryColor));
  }

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
    LMFeedTextFieldStyle? textFieldStyle,
    LMFeedDialogStyle? dialogStyle,
    LMFeedPopUpMenuStyle? popUpMenuStyle,
    LMFeedPostHeaderStyle? headerStyle,
    LMFeedPostTopicStyle? topicStyle,
    LMFeedPostContentStyle? contentStyle,
    LMFeedPostMediaStyle? mediaStyle,
    LMFeedPostFooterStyle? footerStyle,
    LMFeedComposeScreenStyle? composeScreenStyle,
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

class LMFeedTextTheme {
  final String fontFamily;

  const LMFeedTextTheme({
    required this.fontFamily,
  });

  factory LMFeedTextTheme.basic() =>
      const LMFeedTextTheme(fontFamily: 'Roboto');

  LMFeedTextTheme copyWith({
    String? fontFamily,
  }) {
    return LMFeedTextTheme(fontFamily: fontFamily ?? this.fontFamily);
  }
}

class LMFeedDialogStyle {
  final Color? backgroundColor;

  const LMFeedDialogStyle({
    this.backgroundColor,
  });

  LMFeedDialogStyle copyWith({Color? backgroundColor}) {
    return LMFeedDialogStyle(
      backgroundColor: backgroundColor ?? this.backgroundColor,
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
