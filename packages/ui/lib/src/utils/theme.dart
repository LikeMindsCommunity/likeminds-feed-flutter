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

    return lmTheme?.theme ?? LMFeedThemeData.light();
  }
}

class LMFeedThemeData {
  final LMFeedPostStyle postStyle;
  final LMFeedCommentStyle commentStyle;
  final LMFeedCommentStyle replyStyle;
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

  const LMFeedThemeData({
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

  factory LMFeedThemeData.fromThemeData(ThemeData theme) {
    return LMFeedThemeData(
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
              color: Color.fromRGBO(0, 0, 0, 0.239), blurRadius: 1.0)
        ],
        margin: const EdgeInsets.only(bottom: 12.0),
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
            color: LikeMindsTheme.onContainer,
            fontSize: 16,
            fontFamily: 'Roboto',
            fontWeight: FontWeight.w400,
          ),
        ),
        mediaStyle: const LMFeedPostMediaStyle(
          carouselStyle: LMFeedPostCarouselStyle(),
          documentStyle: LMFeedPostDocumentStyle(),
          imageStyle: LMFeedPostImageStyle(),
          linkStyle: LMFeedPostLinkPreviewStyle(),
          videoStyle: LMFeedPostVideoStyle(),
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
              style: LMFeedIconStyle(
                color: LikeMindsTheme.greyColor,
                size: 24,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
            ),
            height: 44,
            activeIcon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmLikeActiveSvg,
              style: LMFeedIconStyle(
                color: LikeMindsTheme.errorColor,
                size: 24,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
            ),
          ),
          commentButtonStyle: LMFeedButtonStyle(
            icon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmCommentSvg,
              style: LMFeedIconStyle(
                color: LikeMindsTheme.greyColor,
                size: 24,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
            ),
          ),
          shareButtonStyle: LMFeedButtonStyle(
            showText: false,
            icon: LMFeedIcon(
              type: LMFeedIconType.svg,
              assetPath: lmShareSvg,
              style: LMFeedIconStyle(
                color: LikeMindsTheme.greyColor,
                size: 24,
                boxPadding: 0,
                fit: BoxFit.contain,
              ),
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
      commentStyle: const LMFeedCommentStyle(
        padding: EdgeInsets.all(12.0),
        likeButtonStyle: LMFeedButtonStyle(
          icon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeInActiveSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.greyColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
          height: 44,
          activeIcon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeActiveSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.errorColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        replyButtonStyle: LMFeedButtonStyle(),
        showRepliesButtonStyle: LMFeedButtonStyle(),
      ),
      replyStyle: const LMFeedCommentStyle(
        padding: EdgeInsets.all(12.0),
        likeButtonStyle: LMFeedButtonStyle(
          icon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeInActiveSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.greyColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
          height: 44,
          activeIcon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeActiveSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.errorColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        showRepliesButton: false,
        showReplyButton: false,
        replyButtonStyle: LMFeedButtonStyle(),
      ),
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
      postStyle: postStyle ??
          LMFeedPostStyle(
            boxShadow: [
              const BoxShadow(
                  color: Color.fromRGBO(0, 0, 0, 0.239), blurRadius: 1.0)
            ],
            margin: const EdgeInsets.only(bottom: 12.0),
            topicStyle: topicStyle ??
                LMFeedPostTopicStyle(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16.0, vertical: 8.0),
                  activeChipStyle: LMFeedTopicChipStyle(
                    backgroundColor: primaryColor?.withOpacity(0.1) ??
                        LikeMindsTheme.primaryColor.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    textStyle: TextStyle(
                      color: primaryColor ?? LikeMindsTheme.primaryColor,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                  ),
                  inactiveChipStyle: LMFeedTopicChipStyle(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 2.0),
                    textStyle: TextStyle(
                      color: primaryColor ?? LikeMindsTheme.primaryColor,
                      fontSize: 14,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.w400,
                    ),
                    borderRadius: BorderRadius.circular(4.0),
                    showBorder: true,
                    borderColor: primaryColor ?? LikeMindsTheme.primaryColor,
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
            mediaStyle: const LMFeedPostMediaStyle(
              carouselStyle: LMFeedPostCarouselStyle(),
              documentStyle: LMFeedPostDocumentStyle(),
              imageStyle: LMFeedPostImageStyle(),
              linkStyle: LMFeedPostLinkPreviewStyle(),
              videoStyle: LMFeedPostVideoStyle(),
            ),
            footerStyle: LMFeedPostFooterStyle(
              showLikeButton: true,
              showCommentButton: true,
              showShareButton: true,
              showSaveButton: true,
              likeButtonStyle: LMFeedButtonStyle(
                padding: const EdgeInsets.only(right: 16.0),
                icon: const LMFeedIcon(
                  type: LMFeedIconType.svg,
                  assetPath: lmLikeInActiveSvg,
                  style: LMFeedIconStyle(
                    color: LikeMindsTheme.greyColor,
                    size: 24,
                    boxPadding: 0,
                    fit: BoxFit.contain,
                  ),
                ),
                height: 44,
                activeIcon: LMFeedIcon(
                  type: LMFeedIconType.svg,
                  assetPath: lmLikeActiveSvg,
                  style: LMFeedIconStyle(
                    color: primaryColor ?? LikeMindsTheme.errorColor,
                    size: 24,
                    boxPadding: 0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              commentButtonStyle: const LMFeedButtonStyle(
                icon: LMFeedIcon(
                  type: LMFeedIconType.svg,
                  assetPath: lmCommentSvg,
                  style: LMFeedIconStyle(
                    color: LikeMindsTheme.greyColor,
                    size: 24,
                    boxPadding: 0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              shareButtonStyle: const LMFeedButtonStyle(
                showText: false,
                icon: LMFeedIcon(
                  type: LMFeedIconType.svg,
                  assetPath: lmShareSvg,
                  style: LMFeedIconStyle(
                    color: LikeMindsTheme.greyColor,
                    size: 24,
                    boxPadding: 0,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
              saveButtonStyle: LMFeedButtonStyle(
                showText: false,
                icon: const LMFeedIcon(
                  type: LMFeedIconType.svg,
                  assetPath: lmSaveInactiveSvg,
                  style: LMFeedIconStyle(
                    color: LikeMindsTheme.greyColor,
                    size: 24,
                    boxPadding: 0,
                    fit: BoxFit.contain,
                  ),
                ),
                activeIcon: LMFeedIcon(
                  type: LMFeedIconType.svg,
                  assetPath: lmSaveActiveSvg,
                  style: LMFeedIconStyle(
                    color: primaryColor ?? LikeMindsTheme.disabledColor,
                    size: 24,
                    boxPadding: 0,
                    fit: BoxFit.contain,
                  ),
                ),
                padding: const EdgeInsets.only(right: 8.0),
              ),
              alignment: MainAxisAlignment.start,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 10.0,
              ),
            ),
            headerStyle: LMFeedPostHeaderStyle(
              imageSize: 48,
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              fallbackTextStyle: LMFeedTextStyle(
                textStyle: TextStyle(
                  color: onPrimary ?? LikeMindsTheme.onPrimary,
                  fontSize: 16,
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      hashTagColor: hashTagColor ?? LikeMindsTheme.hashTagColor,
      linkColor: linkColor ?? LikeMindsTheme.linkColor,
      tagColor: tagColor ?? LikeMindsTheme.tagColor,
      commentStyle: LMFeedCommentStyle(
        showProfilePicture: false,
        padding: const EdgeInsets.all(12.0),
        likeButtonStyle: LMFeedButtonStyle(
          icon: const LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeInActiveSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.greyColor,
              size: 16,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
          height: 44,
          activeIcon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeActiveSvg,
            style: LMFeedIconStyle(
              color: errorColor ?? LikeMindsTheme.errorColor,
              size: 16,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        replyButtonStyle: const LMFeedButtonStyle(),
        showRepliesButtonStyle: const LMFeedButtonStyle(),
      ),
      replyStyle: LMFeedCommentStyle(
        showProfilePicture: false,
        padding: const EdgeInsets.only(
            left: 48.0, top: 12.0, bottom: 12, right: 12.0),
        likeButtonStyle: LMFeedButtonStyle(
          icon: const LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeInActiveSvg,
            style: LMFeedIconStyle(
              color: LikeMindsTheme.greyColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
          height: 44,
          activeIcon: LMFeedIcon(
            type: LMFeedIconType.svg,
            assetPath: lmLikeActiveSvg,
            style: LMFeedIconStyle(
              color: errorColor ?? LikeMindsTheme.errorColor,
              size: 24,
              boxPadding: 0,
              fit: BoxFit.contain,
            ),
          ),
        ),
        showRepliesButton: false,
        showReplyButton: false,
        replyButtonStyle: const LMFeedButtonStyle(),
      ),
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
    LMFeedCommentStyle? replyStyle,
    LMFeedButtonStyle? feedButtonStyle,
    LMFeedIconStyle? feedIconStyle,
    Color? container,
    Color? onContainer,
    Color? onPrimary,
    LMFeedTextFieldStyle? textFieldStyle,
    LMFeedDialogStyle? dialogStyle,
    LMFeedPopUpMenuStyle? popUpMenuStyle,
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
