import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/post/post_topic.dart';

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

const double kFontSmall = 12;
const double kButtonFontSize = 12;
const double kFontXSmall = 11;
const double kFontSmallMed = 14;
const double kFontMedium = 16;
const double kPaddingXSmall = 2;
const double kPaddingSmall = 4;
const double kPaddingMedium = 8;
const double kPaddingLarge = 16;
const double kPaddingXLarge = 20;
const double kBorderRadiusXSmall = 2;
const double kBorderRadiusMedium = 8;
const SizedBox kHorizontalPaddingXLarge = SizedBox(width: kPaddingXLarge);
const SizedBox kHorizontalPaddingSmall = SizedBox(width: kPaddingSmall);
const SizedBox kHorizontalPaddingXSmall = SizedBox(width: kPaddingXSmall);
const SizedBox kHorizontalPaddingLarge = SizedBox(width: kPaddingLarge);
const SizedBox kHorizontalPaddingMedium = SizedBox(width: kPaddingMedium);
const SizedBox kVerticalPaddingXLarge = SizedBox(height: kPaddingXLarge);
const SizedBox kVerticalPaddingSmall = SizedBox(height: kPaddingSmall);
const SizedBox kVerticalPaddingXSmall = SizedBox(height: kPaddingXSmall);
const SizedBox kVerticalPaddingLarge = SizedBox(height: kPaddingLarge);
const SizedBox kVerticalPaddingMedium = SizedBox(height: kPaddingMedium);

class LMFeedThemeData {
  final LMFeedPostStyle postStyle;

  final Color primaryColor;
  final Color backgroundColor;
  final Color secondaryColor;
  final Color shadowColor;
  final Color disabledColor;
  final Color errorColor;
  final Color inActiveColor;

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
      postStyle: LMFeedPostStyle(
        boxShadow: [
          const BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.239), blurRadius: 1.0)
        ],
        margin: const EdgeInsets.only(bottom: 16.0),
        topicStyle: LMFeedPostTopicStyle(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          chipPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2.0),
          backgroundColor: LikeMindsTheme.backgroundColor,
          chipColor: LikeMindsTheme.primaryColor.withOpacity(0.1),
          textStyle: const TextStyle(
            color: LikeMindsTheme.primaryColor,
            fontSize: 14,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
          borderRadius: BorderRadius.circular(4.0),
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
                type: LMFeedIconType.icon,
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
