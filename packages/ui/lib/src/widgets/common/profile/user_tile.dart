import 'package:flutter/material.dart';
import 'package:likeminds_feed_ui_fl/src/utils/index.dart';
import 'package:likeminds_feed_ui_fl/src/widgets/widgets.dart';
import 'package:likeminds_feed_ui_fl/src/models/models.dart';

class LMFeedUserTile extends LMFeedTile {
  final LMUserViewData user;
  @override
  final Function()? onTap;
  @override
  final LMFeedTileStyle? style;
  @override
  final Widget? title;
  @override
  final Widget? subtitle;

  const LMFeedUserTile({
    Key? key,
    required this.user,
    this.onTap,
    this.style,
    this.title,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // return Row(
    //   children: [
    //     profilePicture ??
    //         LMProfilePicture(
    //           size: imageSize ?? 50,
    //           backgroundColor: Colors.blue,
    //           fallbackText: user.name,
    //           onTap: () => onTap(),
    //           imageUrl: user.imageUrl,
    //         ),
    //     kHorizontalPaddingLarge,
    //     Expanded(
    //       child: Column(
    //         crossAxisAlignment: CrossAxisAlignment.start,
    //         children: [
    //           titleText ??
    //               LMFeedText(
    //                 text: user.name,
    //                 style: const LMFeedTextStyle(
    //                   textStyle: TextStyle(
    //                     fontSize: kFontMedium,
    //                     color: Colors.grey,
    //                     fontWeight: FontWeight.w500,
    //                   ),
    //                 ),
    //               ),
    //           kVerticalPaddingMedium,
    //           subText ?? const SizedBox(),
    //         ],
    //       ),
    //     ),
    //   ],
    // );
    // return super.build(context);
    return LMFeedTile(
      leading: LMProfilePicture(
        style: const LMFeedProfilePictureStyle(
          backgroundColor: Colors.blue,
        ),
        fallbackText: user.name,
        imageUrl: user.imageUrl,
      ),
      title: title ??
          LMFeedText(
            text: user.name,
            style: const LMFeedTextStyle(
              textStyle: TextStyle(
                fontSize: kFontMedium,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      subtitle: subtitle ??
          (user.sdkClientInfo != null
              ? LMFeedText(
                  text: user.sdkClientInfo!.userUniqueId,
                  style: const LMFeedTextStyle(
                    textStyle: TextStyle(
                      fontSize: kFontSmall,
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                )
              : null),
    );
  }
}
