import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMFeedPostHeader extends StatelessWidget {
  const LMFeedPostHeader({
    super.key,
    required this.user,
    this.titleText,
    this.subText,
    this.menuBuilder,
    this.editedText,
    this.createdAt,
    this.onProfileTap,
    required this.isFeed,
    this.customTitle,
    this.profilePicture,
    this.postHeaderStyle = const LMFeedPostHeaderStyle(),
    required this.postViewData,
  });

  final LMFeedText? titleText;
  final LMFeedText? customTitle;
  final LMFeedText? subText;
  final LMFeedText? editedText;

  final Widget Function(LMFeedMenu)? menuBuilder;
  final LMFeedText? createdAt;
  final Function()? onProfileTap;

  final Widget? profilePicture;

  final bool isFeed;

  final LMUserViewData user;

  final LMFeedPostHeaderStyle postHeaderStyle;

  final LMPostViewData postViewData;

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    LMFeedThemeData feedTheme = LMFeedTheme.of(context);
    return Container(
      width: postHeaderStyle.width ?? screenSize.width,
      height: postHeaderStyle.height,
      padding: postHeaderStyle.padding ?? const EdgeInsets.only(bottom: 8),
      margin: postHeaderStyle.margin,
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
                          fallbackTextStyle: postHeaderStyle.fallbackTextStyle,
                          size: postHeaderStyle.imageSize ?? 42,
                        ),
                        fallbackText: user.name,
                        imageUrl: user.imageUrl,
                        onTap: onProfileTap,
                      ),
                  LikeMindsTheme.kHorizontalPaddingLarge,
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
                                        style: LMFeedTextStyle(
                                          textStyle: TextStyle(
                                            fontSize:
                                                LikeMindsTheme.kFontMedium,
                                            color: Colors.grey[900],
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                ),
                              ),
                              LikeMindsTheme.kHorizontalPaddingMedium,
                              !postHeaderStyle.showCustomTitle
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
                                                      Text(
                                                        user.customTitle!
                                                                .isNotEmpty
                                                            ? user.customTitle!
                                                            : "",
                                                        // maxLines: 1,
                                                        style: TextStyle(
                                                          fontSize:
                                                              LikeMindsTheme
                                                                  .kFontSmall,
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.w600,
                                                          fontStyle: user.name
                                                                  .isNotEmpty
                                                              ? FontStyle.normal
                                                              : FontStyle
                                                                  .italic,
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
                              LMFeedText(
                                text: subText != null ? '·' : '',
                                style: LMFeedTextStyle(
                                  textStyle: TextStyle(
                                    fontSize: LikeMindsTheme.kFontSmall,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ),
                              subText != null
                                  ? LikeMindsTheme.kHorizontalPaddingXSmall
                                  : const SizedBox(),
                              createdAt ??
                                  LMFeedText(
                                    text: postViewData.createdAt.timeAgo(),
                                    style: LMFeedTextStyle(
                                      textStyle: TextStyle(
                                        fontSize: LikeMindsTheme.kFontSmall,
                                        color: Colors.grey[700],
                                      ),
                                    ),
                                  ),
                              LikeMindsTheme.kHorizontalPaddingSmall,
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
                                        style: LMFeedTextStyle(
                                          textStyle: TextStyle(
                                            fontSize: LikeMindsTheme.kFontSmall,
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
          postViewData.menuItems.isNotEmpty
              ? menuBuilder?.call(_defMenuBuilder()) ?? _defMenuBuilder()
              : const SizedBox()
        ],
      ),
    );
  }

  LMFeedPostHeader copyWith(LMFeedPostHeader header) {
    return LMFeedPostHeader(
      user: header.user,
      titleText: header.titleText ?? titleText,
      subText: header.subText ?? subText,
      editedText: header.editedText ?? editedText,
      menuBuilder: header.menuBuilder ?? menuBuilder,
      createdAt: header.createdAt ?? createdAt,
      onProfileTap: header.onProfileTap ?? onProfileTap,
      isFeed: header.isFeed,
      customTitle: header.customTitle ?? customTitle,
      profilePicture: header.profilePicture ?? profilePicture,
      postHeaderStyle: header.postHeaderStyle,
      postViewData: header.postViewData,
    );
  }

  LMFeedMenu _defMenuBuilder() {
    return LMFeedMenu(
      menuItems: postViewData.menuItems,
      isFeed: isFeed,
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

  const LMFeedPostHeaderStyle({
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.imageSize,
    this.fallbackTextStyle,
    this.showCustomTitle = true,
  });
}
