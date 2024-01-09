import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMFeedPostHeader extends StatelessWidget {
  LMFeedPostHeader({
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

  LMPostViewData? postViewData;

  @override
  Widget build(BuildContext context) {
    postViewData = InheritedPostProvider.of(context)?.post;
    Size screenSize = MediaQuery.of(context).size;
    return postViewData == null
        ? const SizedBox()
        : Container(
            width: postHeaderStyle.width ?? screenSize.width,
            height: postHeaderStyle.height,
            padding:
                postHeaderStyle.padding ?? const EdgeInsets.only(bottom: 8),
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
                            LMProfilePicture(
                              fallbackText: user.name,
                              imageUrl: user.imageUrl,
                              onTap: onProfileTap,
                              style: LMFeedProfilePictureStyle(
                                fallbackTextStyle:
                                    postHeaderStyle.fallbackTextStyle,
                                size: postHeaderStyle.imageSize ?? 42,
                              ),
                            ),
                        kHorizontalPaddingLarge,
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
                                              style: const LMFeedTextStyle(
                                                textStyle: TextStyle(
                                                  fontSize: kFontMedium,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                    kHorizontalPaddingMedium,
                                    !postHeaderStyle.showCustomTitle
                                        ? const SizedBox()
                                        : ((user.customTitle == null ||
                                                    user.customTitle!
                                                        .isEmpty) ||
                                                (user.isDeleted != null &&
                                                    user.isDeleted!))
                                            ? const SizedBox()
                                            : IntrinsicWidth(
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(3.0),
                                                        color: LMFeedTheme.of(
                                                                context)
                                                            .colorScheme
                                                            .primary,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4.0),
                                                        child: customTitle ??
                                                            Text(
                                                              user.customTitle!
                                                                      .isNotEmpty
                                                                  ? user
                                                                      .customTitle!
                                                                  : "",
                                                              // maxLines: 1,
                                                              style: TextStyle(
                                                                fontSize:
                                                                    kFontSmall,
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
                                                  ],
                                                ),
                                              ),
                                  ],
                                ),
                                kVerticalPaddingSmall,
                                Row(
                                  children: [
                                    Flexible(
                                        child: subText ?? const SizedBox()),
                                    subText != null
                                        ? kHorizontalPaddingXSmall
                                        : const SizedBox(),
                                    LMFeedText(
                                      text: subText != null ? '·' : '',
                                      style: LMFeedTextStyle(
                                        textStyle: TextStyle(
                                          fontSize: kFontSmall,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    subText != null
                                        ? kHorizontalPaddingXSmall
                                        : const SizedBox(),
                                    createdAt ??
                                        LMFeedText(
                                          text:
                                              postViewData!.createdAt.timeAgo(),
                                          style: LMFeedTextStyle(
                                            textStyle: TextStyle(
                                              fontSize: kFontSmall,
                                              color: Colors.grey.shade300,
                                            ),
                                          ),
                                        ),
                                    kHorizontalPaddingSmall,
                                    LMFeedText(
                                      text: postViewData!.isEdited ? '·' : '',
                                      style: LMFeedTextStyle(
                                        textStyle: TextStyle(
                                          fontSize: kFontSmall,
                                          color: Colors.grey.shade300,
                                        ),
                                      ),
                                    ),
                                    kHorizontalPaddingSmall,
                                    postViewData!.isEdited
                                        ? editedText ??
                                            LMFeedText(
                                              text: postViewData!.isEdited
                                                  ? 'Edited'
                                                  : '',
                                              style: LMFeedTextStyle(
                                                textStyle: TextStyle(
                                                  fontSize: kFontSmall,
                                                  color: Colors.grey.shade300,
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
                postViewData!.menuItems.isNotEmpty
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
    );
  }

  LMFeedMenu _defMenuBuilder() {
    return LMFeedMenu(
      menuItems: postViewData!.menuItems,
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
