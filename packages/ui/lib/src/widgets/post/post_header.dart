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

  final LMTextView? titleText;
  final LMTextView? customTitle;
  final LMTextView? subText;
  final LMTextView? editedText;

  final Widget Function(LMFeedMenu)? menuBuilder;
  final LMTextView? createdAt;
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
                              size: postHeaderStyle.imageSize ?? 42,
                              fallbackText: user.name,
                              imageUrl: user.imageUrl,
                              onTap: onProfileTap,
                              fallbackTextStyle:
                                  postHeaderStyle.fallbackTextStyle,
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
                                            LMTextView(
                                              text: user.name,
                                              textStyle: const TextStyle(
                                                fontSize: kFontMedium,
                                                color: kGrey1Color,
                                                fontWeight: FontWeight.w500,
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
                                                        color: Theme.of(context)
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
                                                                color:
                                                                    kWhiteColor,
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
                                    LMTextView(
                                      text: subText != null ? '·' : '',
                                      textStyle: const TextStyle(
                                        fontSize: kFontSmall,
                                        color: kGrey3Color,
                                      ),
                                    ),
                                    subText != null
                                        ? kHorizontalPaddingXSmall
                                        : const SizedBox(),
                                    createdAt ??
                                        LMTextView(
                                          text:
                                              postViewData!.createdAt.timeAgo(),
                                          textStyle: const TextStyle(
                                            fontSize: kFontSmall,
                                            color: kGrey3Color,
                                          ),
                                        ),
                                    kHorizontalPaddingSmall,
                                    LMTextView(
                                      text: postViewData!.isEdited ? '·' : '',
                                      textStyle: const TextStyle(
                                        fontSize: kFontSmall,
                                        color: kGrey3Color,
                                      ),
                                    ),
                                    kHorizontalPaddingSmall,
                                    postViewData!.isEdited
                                        ? editedText ??
                                            LMTextView(
                                              text: postViewData!.isEdited
                                                  ? 'Edited'
                                                  : '',
                                              textStyle: const TextStyle(
                                                fontSize: kFontSmall,
                                                color: kGrey3Color,
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
  final TextStyle? fallbackTextStyle;
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
