import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/src/utils/index.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/widgets.dart';
import 'package:likeminds_feed_ui_fl/src/models/models.dart';

class LMUserTile extends StatelessWidget {
  final LMUserViewData user;
  final LMProfilePicture? profilePicture;
  final LMFeedText? titleText;
  final LMFeedText? subText;
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
              backgroundColor: Colors.blue,
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
                        color: Colors.grey,
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
