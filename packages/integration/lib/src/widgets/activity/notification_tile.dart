import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedNotificationTile extends StatelessWidget {
  final LMNotificationFeedItemViewData notificationItemViewData;
  final LMFeedTileStyle? style;
  final VoidCallback? onTap;

  const LMFeedNotificationTile({
    Key? key,
    required this.notificationItemViewData,
    this.style,
    this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    DateTime createdAt = notificationItemViewData.createdAt;
    return LMFeedTile(
        style: style,
        onTap: onTap,
        leading: LMFeedProfilePicture(
          imageUrl: notificationItemViewData.actionBy.last.imageUrl,
          fallbackText: notificationItemViewData.actionBy.last.name,
        ),
        title: RichText(
          text: TextSpan(
            children: LMFeedTaggingHelper.extractNotificationTags(
              notificationItemViewData.activityText,
              normalTextStyle: TextStyle(
                color: Color(0xff14191f),
                fontSize: 14,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
              tagTextStyle: TextStyle(
                fontWeight: FontWeight.w400,
                color: LMFeedTheme.of(context).primaryColor,
              ),
            ),
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: LMFeedText(
            text: LMFeedTimeAgo.instance.format(createdAt),
            style: LMFeedTextStyle(
              textStyle: TextStyle(
                color: Color(0xff5A6068),
                fontSize: 10,
                fontWeight: FontWeight.w400,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ));
  }
}
