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

    return lmTheme?.theme ?? LMFeedThemeData.fromThemeData(Theme.of(context));
  }
}

class LMFeedThemeData {
  final LMFeedPostStyle postStyle;
  final LMFeedCommentStyle commentStyle;
  final LMFeedReplyStyle replyStyle;
  final LMFeedButtonStyle feedButtonStyle;
  final LMFeedIconStyle feedIconStyle;

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

  // factory LMFeedThemeData({LMFeedPostStyle? postStyle}) {
  //   return LMFeedThemeData._(
  //     postStyle: postStyle ?? LMFeedPostStyle(),
  //     primaryColor:
  //   );
  // }

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
  });

  factory LMFeedThemeData.fromThemeData(ThemeData theme) {
    return LMFeedThemeData._(
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
      postStyle: LMFeedPostStyle(
        boxShadow: [
          const BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.239),
            blurRadius: 1.0,
          )
        ],
        margin: const EdgeInsets.only(bottom: 16.0),
        topicStyle: LMFeedPostTopicStyle(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          activeChipStyle: LMFeedTopicChipStyle(
            backgroundColor: theme.primaryColor.withOpacity(0.1),
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            textStyle: TextStyle(
              color: theme.primaryColor,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
            borderRadius: BorderRadius.circular(4.0),
          ),
          inactiveChipStyle: LMFeedTopicChipStyle(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2.0),
            textStyle: TextStyle(
              color: theme.primaryColor,
              fontSize: 14,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w400,
            ),
            borderRadius: BorderRadius.circular(4.0),
            showBorder: true,
            borderColor: theme.primaryColor,
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
        footerStyle: LMFeedPostFooterStyle(
          showLikeButton: true,
          showCommentButton: true,
          showShareButton: true,
          showSaveButton: false,
          likeButtonStyle: LMFeedButtonStyle(
            placement: LMFeedIconButtonPlacement.start,
            icon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmLikeInActiveSvg,
              style: LMFeedIconStyle(
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
            ),
            height: 48,
            activeIcon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmLikeActiveSvg,
              style: LMFeedIconStyle(
                color: theme.primaryColor,
                size: 28,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
            ),
          ),
          commentButtonStyle: LMFeedButtonStyle(
            showText: false,
            placement: LMFeedIconButtonPlacement.start,
            icon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmCommentSvg,
              style: LMFeedIconStyle(
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
            ),
            height: 48,
          ),
          shareButtonStyle: LMFeedButtonStyle(
            placement: LMFeedIconButtonPlacement.start,
            icon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmShareSvg,
              style: LMFeedIconStyle(
                color: theme.colorScheme.onPrimaryContainer,
                size: 28,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
            ),
            height: 48,
          ),
          alignment: MainAxisAlignment.spaceBetween,
          padding: const EdgeInsets.symmetric(
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
              color: LikeMindsTheme.onPrimary,
              fontSize: 16,
              fontFamily: 'Roboto',
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
      hashTagColor: theme.primaryColor,
      linkColor: theme.primaryColor,
      tagColor: theme.primaryColor,
      commentStyle: const LMFeedCommentStyle(),
      replyStyle: const LMFeedReplyStyle(),
      feedButtonStyle: const LMFeedButtonStyle(),
      feedIconStyle: const LMFeedIconStyle(),
    );
  }

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
            placement: LMFeedIconButtonPlacement.start,
            icon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmLikeInActiveSvg,
              style: LMFeedIconStyle(
                color: LikeMindsTheme.greyColor,
                size: 28,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
            ),
            height: 48,
            activeIcon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmLikeActiveSvg,
              style: LMFeedIconStyle(
                color: LikeMindsTheme.primaryColor,
                size: 28,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
            ),
          ),
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
              color: LikeMindsTheme.onPrimary,
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
      commentStyle: const LMFeedCommentStyle(),
      replyStyle: const LMFeedReplyStyle(),
      feedButtonStyle: const LMFeedButtonStyle(),
      feedIconStyle: const LMFeedIconStyle(),
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
