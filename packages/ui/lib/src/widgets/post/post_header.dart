import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMPostHeader extends StatelessWidget {
  const LMPostHeader({
    super.key,
    required this.user,
    this.imageSize,
    this.titleText,
    this.subText,
    this.menu,
    this.editedText,
    this.createdAt,
    this.onProfileTap,
    required this.isFeed,
    this.fallbackTextStyle,
    this.customTitle,
    this.showCustomTitle = true,
    this.profilePicture,
  });

  final double? imageSize;
  final LMTextView? titleText;
  final LMTextView? customTitle;
  final LMTextView? subText;
  final LMTextView? editedText;

  final Widget? menu;
  final LMTextView? createdAt;
  final Function()? onProfileTap;
  final TextStyle? fallbackTextStyle;
  final bool? showCustomTitle;
  final Widget? profilePicture;

  final bool isFeed;

  final LMUserViewData user;

  @override
  Widget build(BuildContext context) {
    final postDetails = InheritedPostProvider.of(context)?.post;
    Size screenSize = MediaQuery.of(context).size;
    return SizedBox(
      width: screenSize.width,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: SizedBox(
          width: screenSize.width - 32,
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
                            size: imageSize ?? 42,
                            fallbackText: user.name,
                            imageUrl: user.imageUrl,
                            onTap: onProfileTap,
                            fallbackTextStyle: fallbackTextStyle,
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
                                  !showCustomTitle!
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
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .primary,
                                                    ),
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4.0),
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
                                  Flexible(child: subText ?? const SizedBox()),
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
                                        text: postDetails!.createdAt.timeAgo(),
                                        textStyle: const TextStyle(
                                          fontSize: kFontSmall,
                                          color: kGrey3Color,
                                        ),
                                      ),
                                  kHorizontalPaddingSmall,
                                  LMTextView(
                                    text: postDetails!.isEdited ? '·' : '',
                                    textStyle: const TextStyle(
                                      fontSize: kFontSmall,
                                      color: kGrey3Color,
                                    ),
                                  ),
                                  kHorizontalPaddingSmall,
                                  postDetails.isEdited
                                      ? editedText ??
                                          LMTextView(
                                            text: postDetails.isEdited
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
              postDetails.menuItems.isNotEmpty
                  ? menu ??
                      LMPostMenu(
                          menuItems: postDetails.menuItems,
                          isFeed: isFeed,
                          removeItemIds: const {},
                          onSelected: (id) {})
                  : const SizedBox()
            ],
          ),
        ),
      ),
    );
  }

  LMPostHeader copyWith(LMPostHeader header) {
    return LMPostHeader(
      user: header.user,
      imageSize: header.imageSize ?? imageSize,
      titleText: header.titleText ?? titleText,
      subText: header.subText ?? subText,
      editedText: header.editedText ?? editedText,
      menu: header.menu ?? menu,
      createdAt: header.createdAt ?? createdAt,
      onProfileTap: header.onProfileTap ?? onProfileTap,
      isFeed: header.isFeed,
      fallbackTextStyle: header.fallbackTextStyle ?? fallbackTextStyle,
      customTitle: header.customTitle ?? customTitle,
      showCustomTitle: header.showCustomTitle ?? showCustomTitle,
      profilePicture: header.profilePicture ?? profilePicture,
    );
  }
}
