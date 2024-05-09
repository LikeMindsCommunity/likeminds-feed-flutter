import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_sample/themes/qna/utils/constants/assets_constants.dart';

const Color qNaPrimaryColor = Color.fromRGBO(0, 158, 130, 1);
const Color primaryBackgroundLight = Color.fromRGBO(217, 252, 243, 1);
const Color primaryBackgroundDark = Color.fromRGBO(196, 248, 234, 1);
const Color surface = Color.fromRGBO(253, 253, 253, 1);
const Color interactive100 = Color.fromRGBO(219, 234, 254, 1);
const Color kHeadingBlackColor = Color.fromRGBO(15, 23, 42, 1);
const Color kPrimaryColorLight = Color.fromRGBO(219, 234, 254, 1);
const Color kSecondary100 = Color.fromRGBO(241, 245, 249, 1);
const Color kSecondaryColor700 = Color.fromRGBO(51, 65, 85, 1);
const Color kSecondaryColorLight = Color.fromRGBO(237, 240, 254, 1);
const Color onSurface = Color.fromRGBO(226, 232, 240, 1);
const Color onSurface500 = Color.fromRGBO(100, 116, 139, 1);
const Color onSurface400 = Color.fromRGBO(148, 163, 184, 1);
const Color onSurface700 = Color.fromRGBO(51, 65, 85, 1);
const Color onSurface900 = Color.fromRGBO(15, 23, 42, 1);
const Color kBackgroundColor = Color.fromRGBO(244, 246, 245, 1);
const Color textPrimary = Color.fromRGBO(20, 25, 31, 1);
const Color textSecondary = Color.fromRGBO(90, 96, 104, 1);
const Color textTertiary = Color.fromRGBO(140, 144, 151, 1);
const Color likeActiveColor = Color.fromRGBO(226, 100, 108, 1);
const Color primaryCta = Color.fromRGBO(14, 18, 38, 1);
const Color dividerDark = Color.fromRGBO(199, 204, 202, 1);
const Color dividerLight = Color.fromRGBO(222, 226, 225, 1);
const Color gradientColor1 = Color(0xfffbe9d7);
const Color gradientColor2 = Color(0xfff6d5f7);
const Color onBoardingGradientBlue1 = Color.fromRGBO(67, 120, 168, 1);
const Color onBoardingGradientBlue2 = Color.fromRGBO(5, 47, 77, 1);
const LinearGradient qNaProfileGradient = LinearGradient(colors: [
  gradientColor1,
  gradientColor2,
], begin: Alignment.topCenter, end: Alignment.bottomCenter);
const LinearGradient qNaOnboardingGradient = LinearGradient(colors: [
  onBoardingGradientBlue1,
  onBoardingGradientBlue2,
], begin: Alignment.topCenter, end: Alignment.bottomCenter);

LMFeedThemeData qNaTheme = LMFeedThemeData.light(
  primaryColor: qNaPrimaryColor,
  secondaryColor: primaryBackgroundLight,
  backgroundColor: kBackgroundColor,
  container: surface,
  onContainer: textPrimary,
  loaderStyle: const LMFeedLoaderStyle(color: qNaPrimaryColor),
  textFieldStyle: LMFeedTextFieldStyle.basic().copyWith(
      decoration: const InputDecoration(
    focusedBorder: InputBorder.none,
    enabledBorder: InputBorder.none,
    errorBorder: InputBorder.none,
    disabledBorder: InputBorder.none,
    border: InputBorder.none,
    contentPadding: EdgeInsets.symmetric(
      horizontal: 8.0,
    ),
  )),
  postStyle: LMFeedPostStyle(
    padding: const EdgeInsets.all(15.0),
    margin: const EdgeInsets.only(top: 5.0),
  ),
  bottomSheetStyle: const LMFeedBottomSheetStyle(
    backgroundColor: kBackgroundColor,
    borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0), topRight: Radius.circular(20.0)),
  ),
  feedButtonStyle: const LMFeedButtonStyle(),
  topicStyle: LMFeedPostTopicStyle(
    padding: const EdgeInsets.symmetric(vertical: 7.5),
    margin: EdgeInsets.zero,
    activeChipStyle: LMFeedTopicChipStyle.active().copyWith(
      backgroundColor: primaryBackgroundLight,
      borderRadius: BorderRadius.circular(20.0),
      textStyle: const TextStyle(
        color: qNaPrimaryColor,
        fontFamily: 'Inter',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    ),
    inactiveChipStyle: LMFeedTopicChipStyle.active().copyWith(
      backgroundColor: surface,
      showBorder: true,
      borderRadius: BorderRadius.circular(20.0),
      borderColor: dividerLight,
      borderWidth: 1.0,
      textStyle: const TextStyle(
        color: textPrimary,
        fontFamily: 'Inter',
      ),
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
    ),
  ),
  contentStyle:
      LMFeedPostContentStyle.basic(onContainer: onSurface900).copyWith(
    padding: const EdgeInsets.symmetric(
      vertical: 7.5,
    ),
    textStyle: const TextStyle(
      color: textSecondary,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      height: 1.42,
    ),
    headingStyle: const TextStyle(
      color: textPrimary,
      fontSize: 17,
      fontFamily: 'Inter',
      fontWeight: FontWeight.w600,
      height: 1.17,
    ),
    headingSeparator: const SizedBox(
      height: 15,
    ),
    headingVisibleLines: 2,
    expandText: "Read More",
    expandTextStyle: const TextStyle(
      color: textSecondary,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      fontFamily: 'Inter',
      height: 1.66,
    ),
  ),
  mediaStyle: LMFeedPostMediaStyle(
    carouselStyle: LMFeedPostCarouselStyle(
      carouselBorderRadius: BorderRadius.circular(16.0),
      carouselPadding: const EdgeInsets.symmetric(
        vertical: 7.5,
      ),
    ),
    pollStyle: const LMFeedPollStyle(),
    documentStyle: const LMFeedPostDocumentStyle(
      height: 90,
      padding: EdgeInsets.symmetric(
        vertical: 8.0,
        horizontal: 16.0,
      ),
      titleStyle: LMFeedTextStyle(
        maxLines: 1,
        textStyle: TextStyle(
          color: onSurface900,
          fontSize: 13,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitleStyle: LMFeedTextStyle(
        maxLines: 1,
        textStyle: TextStyle(
          color: onSurface700,
          fontSize: 12,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
      ),
      borderColor: kSecondary100,
      backgroundColor: kSecondary100,
    ),
    imageStyle: const LMFeedPostImageStyle(),
    linkStyle: LMFeedPostLinkPreviewStyle.basic().copyWith(
      showLinkUrl: false,
      height: 216,
      imageHeight: 142,
      backgroundColor: kSecondary100,
      margin: const EdgeInsets.only(bottom: 16.0),
      padding: const EdgeInsets.all(12.0),
      titleStyle: const LMFeedTextStyle(
        maxLines: 1,
        textStyle: TextStyle(
          color: onSurface900,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitleStyle: const LMFeedTextStyle(
        maxLines: 1,
        textStyle: TextStyle(
          color: onSurface900,
          fontSize: 14,
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        ),
      ),
    ),
    videoStyle: const LMFeedPostVideoStyle(),
  ),
  footerStyle: LMFeedPostFooterStyle.basic().copyWith(
    padding: EdgeInsets.zero,
    margin: EdgeInsets.zero,
    height: 20,
    showSaveButton: true,
    alignment: MainAxisAlignment.spaceBetween,
    likeButtonStyle: LMFeedButtonStyle.like(
      primaryColor: qNaPrimaryColor,
    ).copyWith(
      margin: 4.0,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetLikeIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
        ),
      ),
      activeIcon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetLikeFilledIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
    commentButtonStyle: LMFeedButtonStyle.comment().copyWith(
      margin: 4.0,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetCommentIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
          color: textSecondary,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
    shareButtonStyle: LMFeedButtonStyle.share().copyWith(
      margin: 4.0,
      showText: true,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetShareIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
    saveButtonStyle: LMFeedButtonStyle.save().copyWith(
      showText: false,
      margin: 4.0,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetSaveIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
        ),
      ),
      activeIcon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetSaveFilledIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
        ),
      ),
    ),
  ),
  headerStyle: LMFeedPostHeaderStyle.basic().copyWith(
    showPinnedIcon: true,
    showTimeStamp: false,
    menuStyle: const LMFeedMenuStyle(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20.0),
        topRight: Radius.circular(20),
      ),
      menuType: LMFeedPostMenuType.bottomSheet,
      headingStyle: LMFeedTextStyle(
        textStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
          height: 1.25,
        ),
      ),
      showBottomSheetTitle: true,
      menuIcon: LMFeedIcon(
        icon: Icons.more_vert,
        type: LMFeedIconType.icon,
        style: LMFeedIconStyle(
          color: textSecondary,
        ),
      ),
    ),
    padding: const EdgeInsets.only(
      bottom: 7.5,
    ),
    titleTextStyle: const LMFeedTextStyle(
      textStyle: TextStyle(
        fontFamily: "Inter",
        fontWeight: FontWeight.w600,
      ),
    ),
    subTextStyle: const LMFeedTextStyle(
      textStyle: TextStyle(
        fontFamily: "Inter",
        fontWeight: FontWeight.w400,
        fontSize: 10,
        color: textSecondary,
      ),
    ),
  ),
  commentStyle: LMFeedCommentStyle.basic().copyWith(
    showProfilePicture: true,
    showTimestamp: false,
    profilePicturePadding: const EdgeInsets.only(
      right: 8.0,
    ),
    actionsPadding: const EdgeInsets.only(
      left: 44.0,
    ),
    subtitlePadding: const EdgeInsets.only(top: 4),
    expandText: "Read More",
    expandTextStyle: const TextStyle(
      color: textSecondary,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      fontFamily: 'Inter',
      height: 1.66,
    ),
    likeButtonStyle: LMFeedButtonStyle.like(
      primaryColor: qNaPrimaryColor,
    ).copyWith(
      margin: 4.0,
      textPadding: const EdgeInsets.only(right: 10),
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetLikeIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
        ),
      ),
      activeIcon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetLikeFilledIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
          color: Colors.transparent,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
    replyButtonStyle: LMFeedButtonStyle.comment().copyWith(
      margin: 4.0,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetCommentIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
  ),
  replyStyle: LMFeedCommentStyle.basic(isReply: true).copyWith(
    showProfilePicture: true,
    showTimestamp: false,
    expandText: "Read More",
    expandTextStyle: const TextStyle(
      color: textSecondary,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      fontFamily: 'Inter',
      height: 1.66,
    ),
    profilePicturePadding: const EdgeInsets.only(
      right: 8.0,
    ),
    actionsPadding: const EdgeInsets.only(
      left: 44.0,
    ),
    likeButtonStyle: LMFeedButtonStyle.like(
      primaryColor: qNaPrimaryColor,
    ).copyWith(
      margin: 4,
      textPadding: const EdgeInsets.only(right: 10),
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetLikeIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
        ),
      ),
      activeIcon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetLikeFilledIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
          color: Colors.transparent,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
    replyButtonStyle: LMFeedButtonStyle.comment().copyWith(
      margin: 4,
      icon: LMFeedIcon(
        type: LMFeedIconType.svg,
        assetPath: qNaAssetCommentIcon,
        style: LMFeedIconStyle.basic().copyWith(
          size: 16,
          boxPadding: 2,
        ),
      ),
      padding: EdgeInsets.zero,
    ),
  ),
  composeScreenStyle: LMFeedComposeScreenStyle.basic().copyWith(
    addImageIcon: const LMFeedIcon(
      type: LMFeedIconType.svg,
      assetPath: qNaAssetAddImageIcon,
      style: LMFeedIconStyle(
        boxPadding: 0,
        size: 36,
      ),
    ),
    addVideoIcon: const LMFeedIcon(
      type: LMFeedIconType.svg,
      assetPath: qNaAssetAddVideoIcon,
      style: LMFeedIconStyle(
        boxPadding: 0,
        size: 36,
      ),
    ),
    mediaPadding: const EdgeInsets.only(
      left: 20,
    ),
    mediaStyle: LMFeedComposeMediaStyle.basic().copyWith(
      documentStyle: const LMFeedPostDocumentStyle(
        titleStyle: LMFeedTextStyle(
          maxLines: 1,
          textStyle: TextStyle(
            color: onSurface900,
            fontSize: 13,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitleStyle: LMFeedTextStyle(
          maxLines: 1,
          textStyle: TextStyle(
            color: onSurface700,
            fontSize: 12,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w400,
          ),
        ),
        height: 90,
        borderColor: kSecondary100,
        backgroundColor: kSecondary100,
      ),
      linkStyle: LMFeedPostLinkPreviewStyle.basic().copyWith(
        showLinkUrl: false,
        height: 217,
        imageHeight: 138,
        backgroundColor: kSecondary100,
        margin: EdgeInsets.zero,
        padding: const EdgeInsets.all(12.0),
        titleStyle: const LMFeedTextStyle(
          maxLines: 1,
          textStyle: TextStyle(
            color: onSurface900,
            fontSize: 14,
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitleStyle: const LMFeedTextStyle(
          maxLines: 1,
          textStyle: TextStyle(
            color: onSurface900,
            fontSize: 14,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
      imageStyle: LMFeedPostImageStyle.basic().copyWith(
          height: 120,
          width: 104,
          borderRadius: BorderRadius.circular(8.0),
          backgroundColor: textPrimary,
          margin: const EdgeInsets.only(right: 5.0)),
      videoStyle: LMFeedPostVideoStyle.basic().copyWith(
          height: 120,
          width: 104,
          borderRadius: BorderRadius.circular(8.0),
          margin: const EdgeInsets.only(right: 5.0)),
    ),
  ),
);
