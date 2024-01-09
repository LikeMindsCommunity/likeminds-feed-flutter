import 'package:flutter/material.dart';

import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMFeedUserTile extends StatelessWidget {
  final LMUserViewData user;
  final LMFeedProfilePicture? profilePicture;
  final LMFeedText? titleText;
  final LMFeedText? subText;
  final double? imageSize;
  final Function onTap;

  const LMFeedUserTile({
    Key? key,
    this.titleText,
    this.imageSize,
    this.profilePicture,
    required this.user,
    this.subText,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        profilePicture ??
            LMFeedProfilePicture(
              size: imageSize ?? 50,
              backgroundColor: kPrimaryColor,
              fallbackText: user.name,
              onTap: () => onTap(),
              imageUrl: user.imageUrl,
            ),
        kHorizontalPaddingLarge,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              titleText ??
                  LMFeedText(
                    text: user.name,
                    style: const LMFeedTextStyle(
                      textStyle: TextStyle(
                        fontSize: kFontMedium,
                        color: kGrey1Color,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              kVerticalPaddingMedium,
              subText ?? const SizedBox(),
            ],
          ),
        ),
      ],
    );
  }
}
