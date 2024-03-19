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
    this.subTextSeparator,
    this.menuBuilder,
    this.editedText,
    this.createdAt,
    this.onProfileTap,
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
  final Widget? subTextSeparator;
  final LMFeedText? editedText;

  final Widget Function(LMFeedMenu)? menuBuilder;
  final LMFeedMenu? menu;
  final LMFeedText? createdAt;
  final Function()? onProfileTap;

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
          GestureDetector(
            onTap: () {
              if (onProfileTap != null) {
                onProfileTap!();
              }
            },
            child: Container(
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
                        onTap: onProfileTap,
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
                          Row(
                            children: [
                              Flexible(
                                child: GestureDetector(
                                  onTap: () {
                                    if (onProfileTap != null) {
                                      onProfileTap!();
                                    }
                                  },
                                  child: titleText ??
                                      LMFeedText(
                                        text: user.name,
                                        style: postHeaderStyle
                                                ?.titleTextStyle ??
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
                              ),
                              LikeMindsTheme.kHorizontalPaddingMedium,
                              !headerStyle.showCustomTitle
                                  ? const SizedBox()
                                  : ((user.customTitle == null ||
                                              user.customTitle!.isEmpty) ||
                                          (user.isDeleted != null &&
                                              user.isDeleted!))
                                      ? const SizedBox()
                                      : IntrinsicWidth(
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          3.0),
                                                  color: feedTheme.primaryColor,
                                                ),
                                                child: Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: customTitle ??
                                                      LMFeedText(
                                                        text: user.customTitle!
                                                                .isNotEmpty
                                                            ? user.customTitle!
                                                            : "",
                                                        // maxLines: 1,
                                                        style: postHeaderStyle
                                                                ?.customTitleTextStyle ??
                                                            LMFeedTextStyle(
                                                              textStyle:
                                                                  TextStyle(
                                                                fontSize:
                                                                    LikeMindsTheme
                                                                        .kFontSmall,
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600,
                                                                fontStyle: user
                                                                        .name
                                                                        .isNotEmpty
                                                                    ? FontStyle
                                                                        .normal
                                                                    : FontStyle
                                                                        .italic,
                                                              ),
                                                            ),
                                                      ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                            ],
                          ),
                          LikeMindsTheme.kVerticalPaddingSmall,
                          Row(
                            children: [
                              Flexible(child: subText ?? const SizedBox()),
                              subText != null
                                  ? LikeMindsTheme.kHorizontalPaddingXSmall
                                  : const SizedBox(),
                              if (createdAt != null)
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
                              if (createdAt != null && subText != null)
                                LikeMindsTheme.kHorizontalPaddingXSmall,
                              createdAt ?? const SizedBox.shrink(),
                              LikeMindsTheme.kHorizontalPaddingSmall,
                              LMFeedText(
                                text: postViewData.isEdited ? '·' : '',
                                style: postHeaderStyle?.subTextStyle ??
                                    LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        fontSize: LikeMindsTheme.kFontSmall,
                                        color: Colors.grey[700],
                                      ),
                                    ),
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
                                        text: postViewData.isEdited
                                            ? 'Edited'
                                            : '',
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
          ),
          const Spacer(),
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

  LMFeedPostHeader copyWith({
    LMUserViewData? user,
    LMFeedText? titleText,
    LMFeedText? subText,
    Widget? subTextSeparator,
    LMFeedText? editedText,
    Widget Function(LMFeedMenu)? menuBuilder,
    LMFeedText? createdAt,
    Function()? onProfileTap,
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
      subTextSeparator: subTextSeparator ?? this.subTextSeparator,
      editedText: editedText ?? this.editedText,
      menuBuilder: menuBuilder ?? this.menuBuilder,
      createdAt: createdAt ?? this.createdAt,
      onProfileTap: onProfileTap ?? this.onProfileTap,
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
