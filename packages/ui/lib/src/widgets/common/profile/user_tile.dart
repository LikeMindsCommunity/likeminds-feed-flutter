import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_ui/src/utils/index.dart';
import 'package:likeminds_feed_flutter_ui/src/widgets/widgets.dart';
import 'package:likeminds_feed_flutter_ui/src/models/models.dart';

class LMFeedUserTile extends LMFeedTile {
  final LMUserViewData user;
  @override
  final VoidCallback? onTap;
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
  }) : super(
          key: key,
          onTap: onTap,
          style: style,
          title: title,
          subtitle: subtitle,
        );

  @override
  Widget build(BuildContext context) {
    return LMFeedTile(
      leading: LMFeedProfilePicture(
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
                fontSize: LikeMindsTheme.kFontMedium,
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
                      fontSize: LikeMindsTheme.kFontSmall,
                      color: Colors.grey,
                      fontWeight: FontWeight.w300,
                    ),
                  ),
                )
              : null),
    );
  }
}
