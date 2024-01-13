import 'package:flutter/material.dart';

class LMFeedTheme extends InheritedWidget {
  const LMFeedTheme({super.key, required this.theme, required super.child});

  final ThemeData theme;

  @override
  bool updateShouldNotify(covariant LMFeedTheme oldWidget) {
    return theme != oldWidget.theme;
  }

  static ThemeData of(BuildContext context) {
    final lmTheme = context.dependOnInheritedWidgetOfExactType<LMFeedTheme>();

    assert(
      lmTheme != null,
      'You must have a LMFeedTheme widget at the top of your widget tree',
    );

    return lmTheme!.theme;
  }
}

// const Color kPrimaryColor = Color.fromARGB(255, 6, 92, 193);
// const Color kBackgroundColor = Color(0xffF5F5F5);
// const Color kWhiteColor = Color(0xffFFFFFF);
// const Color kGreyColor = Color(0xff666666);
// const Color kGrey1Color = Color(0xff222020);
// const Color kGrey2Color = Color(0xff504B4B);
// const Color kGrey3Color = Color(0xff9B9B9B);
// const Color kGreyWebBGColor = Color(0xffE6EBF5);
// const Color kGreyBGColor = Color.fromRGBO(208, 216, 226, .4);
// const Color kBlueGreyColor = Color(0xff484F67);
// const Color kLinkColor = Color(0xff007AFF);
// const Color kHeadingColor = Color(0xff333149);
// const Color kBorderColor = Color.fromRGBO(208, 216, 226, 0.5);
// const Color notificationReadColor = Color.fromRGBO(208, 216, 226, 0.4);

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
