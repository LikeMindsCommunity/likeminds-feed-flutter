import 'package:flutter/material.dart';

import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:likeminds_feed_ui_fl/src/utils/theme.dart';

class LMUserTile extends StatelessWidget {
  final UserViewData user;
  final LMProfilePicture? profilePicture;
  final LMTextView? titleText;
  final LMTextView? subText;
  final double? imageSize;
  final Function onTap;

  const LMUserTile({
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
            LMProfilePicture(
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
                  LMTextView(
                    text: user.name,
                    textStyle: const TextStyle(
                      fontSize: kFontMedium,
                      color: kGrey1Color,
                      fontWeight: FontWeight.w500,
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
