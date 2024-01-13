import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMFeedTheme extends InheritedWidget {
  const LMFeedTheme({super.key, required this.theme, required super.child});

  final LMFeedThemeData theme;

  @override
  bool updateShouldNotify(covariant LMFeedTheme oldWidget) {
    return theme != oldWidget.theme;
  }

  static LMFeedThemeData of(BuildContext context) {
    final lmTheme = context.dependOnInheritedWidgetOfExactType<LMFeedTheme>();

    // assert(
    //   lmTheme != null,
    //   'You must have a LMFeedTheme widget at the top of your widget tree',
    // );

    return lmTheme?.theme ?? LMFeedThemeData.light();
  }
}

class LMFeedThemeData {
  final LMFeedPostStyle postStyle;
  final LMFeedCommentStyle commentStyle;
  final LMFeedReplyStyle replyStyle;
  final LMFeedButtonStyle feedButtonStyle;
  final LMFeedIconStyle feedIconStyle;
  final LMFeedTextFieldStyle textFieldStyle;
  final LMFeedDialogStyle dialogStyle;
  final LMFeedPopUpMenuStyle popUpMenuStyle;

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

  const LMFeedThemeData._({
    required this.postStyle,
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
  });

  factory LMFeedThemeData.light() {
    return LMFeedThemeData._(
      backgroundColor: LikeMindsTheme.backgroundColor,
      primaryColor: LikeMindsTheme.primaryColor,
      secondaryColor: LikeMindsTheme.secondaryColor,
      shadowColor: LikeMindsTheme.shadowColor,
      disabledColor: LikeMindsTheme.disabledColor,
      errorColor: LikeMindsTheme.errorColor,
      inActiveColor: LikeMindsTheme.inactiveColor,
      container: LikeMindsTheme.container,
      onContainer: LikeMindsTheme.onContainer,
      onPrimary: LikeMindsTheme.onPrimary,
      postStyle: LMFeedPostStyle(
        boxShadow: [
          const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.239), blurRadius: 1.0)
        ],
        margin: const EdgeInsets.only(bottom: 16.0),
        topicStyle: LMFeedPostTopicStyle(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          activeChipStyle: LMFeedTopicChipStyle(
            backgroundColor: LikeMindsTheme.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            textStyle: const TextStyle(
              color: LikeMindsTheme.primaryColor,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          inactiveChipStyle: LMFeedTopicChipStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            textStyle: const TextStyle(
              color: LikeMindsTheme.primaryColor,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
            borderRadius: BorderRadius.circular(4.0),
            showBorder: true,
            borderColor: LikeMindsTheme.primaryColor,
          ),
        ),
        contentStyle: const LMFeedPostContentStyle(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          textStyle: TextStyle(
            color: LikeMindsTheme.greyColor,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        footerStyle: const LMFeedPostFooterStyle(
          showLikeButton: true,
          showCommentButton: true,
          showShareButton: true,
          showSaveButton: false,
          likeButtonStyle: LMFeedButtonStyle(
              icon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmLikeInActiveSvg,
              ),
              activeIcon: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmLikeActiveSvg,
              )),
          commentButtonStyle: LMFeedButtonStyle(
            icon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmCommentSvg,
            ),
          ),
          shareButtonStyle: LMFeedButtonStyle(
            icon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmShareSvg,
            ),
          ),
          alignment: MainAxisAlignment.spaceBetween,
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 10.0,
          ),
        ),
        headerStyle: const LMFeedPostHeaderStyle(
          imageSize: 48,
          padding: EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 8.0,
          ),
          fallbackTextStyle: LMFeedTextStyle(
            textStyle: TextStyle(
              color: Color(0xFF222020),
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      hashTagColor: LikeMindsTheme.hashTagColor,
      linkColor: LikeMindsTheme.linkColor,
      tagColor: LikeMindsTheme.tagColor,
      commentStyle: const LMFeedCommentStyle(
        likeButtonStyle: LMFeedButtonStyle(
          icon: LMFeedIcon(
            type: LMFeedIconType.icon,
            assetPath: lmLikeInActiveSvg,
          ),
          activeIcon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeActiveSvg,
          ),
        ),
        replyButtonStyle: LMFeedButtonStyle(
          icon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmCommentSvg,
          ),
        ),
        showRepliesButtonStyle: LMFeedButtonStyle(),
      ),
      replyStyle: const LMFeedReplyStyle(),
      feedButtonStyle: const LMFeedButtonStyle(),
      feedIconStyle: const LMFeedIconStyle(),
      textFieldStyle: const LMFeedTextFieldStyle(
        backgroundColor: LikeMindsTheme.backgroundColor,
        decoration: InputDecoration(
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
      dialogStyle: const LMFeedDialogStyle(),
      popUpMenuStyle: const LMFeedPopUpMenuStyle(),
    );
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
    LMFeedReplyStyle? replyStyle,
    LMFeedButtonStyle? feedButtonStyle,
    LMFeedIconStyle? feedIconStyle,
    Color? container,
    Color? onContainer,
    Color? onPrimary,
    LMFeedTextFieldStyle? textFieldStyle,
    LMFeedDialogStyle? dialogStyle,
    LMFeedPopUpMenuStyle? popUpMenuStyle,
  }) {
    return LMFeedThemeData._(
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
