import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';

class LMFeedPostHeader extends StatelessWidget {
  const LMFeedPostHeader({
    super.key,
    required this.user,
    this.titleText,
    this.subText,
    this.subTextBuilder,
    this.subTextSeparator,
    this.menuBuilder,
    this.editedText,
    this.createdAt,
    this.onProfileNameTap,
    this.onProfilePictureTap,
    required this.isFeed,
    this.customTitle,
    this.profilePicture,
    this.postHeaderStyle,
    required this.postViewData,
    this.menu,
  });

  final LMFeedText? titleText;
  final LMFeedText? customTitle;
  final LMFeedText? subText;
  final Widget? Function(BuildContext context, LMFeedText subtext)?
      subTextBuilder;
  final Widget? subTextSeparator;
  final LMFeedText? editedText;

  final Widget Function(LMFeedMenu)? menuBuilder;
  final LMFeedMenu? menu;
  final LMFeedText? createdAt;
  final Function()? onProfileNameTap;
  final Function()? onProfilePictureTap;

  final Widget? profilePicture;

  final bool isFeed;

  final LMUserViewData user;

  final LMFeedPostHeaderStyle? postHeaderStyle;

  final LMPostViewData postViewData;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    LMFeedThemeData feedTheme = LMFeedTheme.instance.theme;
    LMFeedPostHeaderStyle headerStyle =
        postHeaderStyle ?? feedTheme.headerStyle;
    return Container(
      width: headerStyle.width ?? screenSize.width,
      height: headerStyle.height,
      padding: headerStyle.padding ?? const EdgeInsets.only(bottom: 8),
      margin: headerStyle.margin,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            color: Colors.transparent,
            child: Row(
              children: [
                profilePicture ??
                    LMFeedProfilePicture(
                      style: LMFeedProfilePictureStyle(
                        fallbackTextStyle: headerStyle.fallbackTextStyle,
                        size: headerStyle.imageSize ?? 42,
                      ),
                      fallbackText: user.name,
                      imageUrl: user.imageUrl,
                      onTap: onProfilePictureTap,
                    ),
                LikeMindsTheme.kHorizontalPaddingMedium,
                Container(
                  constraints: BoxConstraints(
                    maxWidth: screenSize.width * 0.66,
                  ),
                  child: IntrinsicWidth(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        GestureDetector(
                          onTap: onProfileNameTap,
                          behavior: HitTestBehavior.translucent,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: titleText ??
                                    LMFeedText(
                                      text: user.name,
                                      style: postHeaderStyle?.titleTextStyle ??
                                          LMFeedTextStyle(
                                            textStyle: TextStyle(
                                              fontSize:
                                                  LikeMindsTheme.kFontMedium,
                                              color: feedTheme.onContainer,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                    ),
                              ),
                              LikeMindsTheme.kHorizontalPaddingMedium,
                              getCustomTitle(headerStyle, feedTheme),
                            ],
                          ),
                        ),
                        LikeMindsTheme.kVerticalPaddingSmall,
                        Row(
                          children: [
                            Flexible(
                                child: subTextBuilder?.call(
                                        context,
                                        subText ??
                                            const LMFeedText(
                                              text: '',
                                            )) ??
                                    subText ??
                                    const SizedBox()),
                            subText != null
                                ? LikeMindsTheme.kHorizontalPaddingXSmall
                                : const SizedBox(),
                            if (createdAt != null && headerStyle.showTimeStamp)
                              subTextSeparator ??
                                  LMFeedText(
                                    text: subText != null ? '·' : '',
                                    style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        fontSize: LikeMindsTheme.kFontSmall,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                            if (createdAt != null &&
                                subText != null &&
                                headerStyle.showTimeStamp)
                              LikeMindsTheme.kHorizontalPaddingXSmall,
                            if (headerStyle.showTimeStamp)
                              createdAt ??
                                  LMFeedText(
                                    text: LMFeedTimeAgo.instance
                                        .format(postViewData.createdAt),
                                  ),
                            LikeMindsTheme.kHorizontalPaddingSmall,
                            if (postViewData.isEdited)
                              subTextSeparator ??
                                  LMFeedText(
                                    text: postViewData.isEdited ? '·' : '',
                                    style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        fontSize: LikeMindsTheme.kFontSmall,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                            LikeMindsTheme.kHorizontalPaddingSmall,
                            postViewData.isEdited
                                ? editedText ??
                                    LMFeedText(
                                      text:
                                          postViewData.isEdited ? 'Edited' : '',
                                      style: postHeaderStyle?.subTextStyle ??
                                          LMFeedTextStyle(
                                            textStyle: TextStyle(
                                              fontSize:
                                                  LikeMindsTheme.kFontSmall,
                                              color: Colors.grey[700],
                                            ),
                                          ),
                                    )
                                : const SizedBox(),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if ((postHeaderStyle?.showPinnedIcon ?? true) &&
              postViewData.isPinned)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: LMFeedIcon(
                type: LMFeedIconType.svg,
                assetPath: lmPinSvg,
                style: LMFeedIconStyle.basic(),
              ),
            ),
          postViewData.menuItems.isNotEmpty
              ? menuBuilder?.call(_defMenuBuilder(feedTheme)) ??
                  _defMenuBuilder(feedTheme)
              : const SizedBox()
        ],
      ),
    );
  }

  Widget getCustomTitle(
      LMFeedPostHeaderStyle headerStyle, LMFeedThemeData feedTheme) {
    return !headerStyle.showCustomTitle
        ? const SizedBox()
        : ((user.customTitle == null ||
                    user.customTitle!.isEmpty && customTitle == null) ||
                (user.isDeleted != null && user.isDeleted!))
            ? const SizedBox()
            : Flexible(
                child: customTitle ??
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(3.0),
                        color: feedTheme.primaryColor,
                      ),
                      padding: const EdgeInsets.all(4.0),
                      child: LMFeedText(
                        text: user.customTitle!.isNotEmpty
                            ? user.customTitle!
                            : "",
                        style: postHeaderStyle?.customTitleTextStyle ??
                            LMFeedTextStyle(
                              textStyle: TextStyle(
                                fontSize: LikeMindsTheme.kFontSmall,
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                                fontWeight: FontWeight.w600,
                                fontStyle: user.name.isNotEmpty
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                      ),
                    ),
              );
  }

  LMFeedPostHeader copyWith({
    LMUserViewData? user,
    LMFeedText? titleText,
    LMFeedText? subText,
    Widget? Function(BuildContext context, LMFeedText subtext)? subTextBuilder,
    Widget? subTextSeparator,
    LMFeedText? editedText,
    Widget Function(LMFeedMenu)? menuBuilder,
    LMFeedText? createdAt,
    Function()? onProfileNameTap,
    Function()? onProfilePictureTap,
    bool? isFeed,
    LMFeedText? customTitle,
    Widget? profilePicture,
    LMFeedPostHeaderStyle? postHeaderStyle,
    LMPostViewData? postViewData,
    LMFeedMenu? menu,
  }) {
    return LMFeedPostHeader(
      user: user ?? this.user,
      titleText: titleText ?? this.titleText,
      subText: subText ?? this.subText,
      subTextBuilder: subTextBuilder ?? this.subTextBuilder,
      subTextSeparator: subTextSeparator ?? this.subTextSeparator,
      editedText: editedText ?? this.editedText,
      menuBuilder: menuBuilder ?? this.menuBuilder,
      createdAt: createdAt ?? this.createdAt,
      onProfileNameTap: onProfileNameTap ?? this.onProfileNameTap,
      onProfilePictureTap: onProfilePictureTap ?? this.onProfilePictureTap,
      isFeed: isFeed ?? this.isFeed,
      customTitle: customTitle ?? this.customTitle,
      profilePicture: profilePicture ?? this.profilePicture,
      postHeaderStyle: postHeaderStyle ?? this.postHeaderStyle,
      postViewData: postViewData ?? this.postViewData,
      menu: menu ?? this.menu,
    );
  }

  LMFeedMenu _defMenuBuilder(LMFeedThemeData feedTheme) {
    return menu ??
        LMFeedMenu(
          menuItems: postViewData.menuItems,
          removeItemIds: const {},
          action: LMFeedMenuAction(),
        );
  }
}

class LMFeedPostHeaderStyle {
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final double? imageSize;
  final LMFeedTextStyle? fallbackTextStyle;
  final bool showCustomTitle;
  final LMFeedTextStyle? titleTextStyle;
  final LMFeedTextStyle? subTextStyle;
  final LMFeedTextStyle? customTitleTextStyle;
  final LMFeedMenuStyle? menuStyle;
  final bool showTimeStamp;

  final bool showPinnedIcon;

  const LMFeedPostHeaderStyle({
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.imageSize,
    this.fallbackTextStyle,
    this.showCustomTitle = true,
    this.showPinnedIcon = true,
    this.titleTextStyle,
    this.subTextStyle,
    this.customTitleTextStyle,
    this.menuStyle,
    this.showTimeStamp = true,
  });

  LMFeedPostHeaderStyle copyWith({
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    double? imageSize,
    LMFeedTextStyle? fallbackTextStyle,
    bool? showCustomTitle,
    bool? showPinnedIcon,
    LMFeedTextStyle? titleTextStyle,
    LMFeedTextStyle? subTextStyle,
    LMFeedTextStyle? customTitleTextStyle,
    LMFeedMenuStyle? menuStyle,
    bool? showTimeStamp,
  }) {
    return LMFeedPostHeaderStyle(
      padding: padding ?? this.padding,
      margin: margin ?? this.margin,
      width: width ?? this.width,
      height: height ?? this.height,
      imageSize: imageSize ?? this.imageSize,
      fallbackTextStyle: fallbackTextStyle ?? this.fallbackTextStyle,
      showCustomTitle: showCustomTitle ?? this.showCustomTitle,
      showPinnedIcon: showPinnedIcon ?? this.showPinnedIcon,
      titleTextStyle: titleTextStyle ?? this.titleTextStyle,
      subTextStyle: subTextStyle ?? this.subTextStyle,
      customTitleTextStyle: customTitleTextStyle ?? this.customTitleTextStyle,
      menuStyle: menuStyle ?? this.menuStyle,
      showTimeStamp: showTimeStamp ?? this.showTimeStamp,
    );
  }

  factory LMFeedPostHeaderStyle.basic({Color? onPrimary}) =>
      LMFeedPostHeaderStyle(
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
      );
}
