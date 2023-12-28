import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/notification_feed/activity_entity_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class LMNotificationFeedItemViewDataConvertor {
  static LMNotificationFeedItemViewData fromNotificationFeedItem(
      NotificationFeedItem notificationFeedItem) {
    LMNotificationFeedItemViewDataBuilder notificationFeedItemViewDataBuilder =
        LMNotificationFeedItemViewDataBuilder();

    notificationFeedItemViewDataBuilder.id(notificationFeedItem.id);

    notificationFeedItemViewDataBuilder.action(notificationFeedItem.action);

    notificationFeedItemViewDataBuilder.actionBy(notificationFeedItem.actionBy);

    notificationFeedItemViewDataBuilder.actionOn(notificationFeedItem.actionOn);

    notificationFeedItemViewDataBuilder.activityEntityViewData(
        LMActivityEntityViewDataConvertor.fromActivityEntity(
            notificationFeedItem.activityEntityData));

    notificationFeedItemViewDataBuilder
        .activityText(notificationFeedItem.activityText);

    if (notificationFeedItem.cta != null) {
      notificationFeedItemViewDataBuilder.cta(notificationFeedItem.cta!);
    }

    notificationFeedItemViewDataBuilder
        .createdAt(notificationFeedItem.createdAt);

    notificationFeedItemViewDataBuilder.entityId(notificationFeedItem.entityId);

    if (notificationFeedItem.entityOwnerId != null) {
      notificationFeedItemViewDataBuilder
          .entityOwnerId(notificationFeedItem.entityOwnerId!);
    }

    notificationFeedItemViewDataBuilder
        .entityType(notificationFeedItem.entityType);

    notificationFeedItemViewDataBuilder.isRead(notificationFeedItem.isRead);

    notificationFeedItemViewDataBuilder
        .updatedAt(notificationFeedItem.updatedAt);

    return notificationFeedItemViewDataBuilder.build();
  }

  static NotificationFeedItem toNotificationFeedItem(
      LMNotificationFeedItemViewData notificationFeedItemViewData) {
    return NotificationFeedItem(
      id: notificationFeedItemViewData.id,
      action: notificationFeedItemViewData.action,
      actionBy: notificationFeedItemViewData.actionBy,
      actionOn: notificationFeedItemViewData.actionOn,
      activityEntityData: LMActivityEntityViewDataConvertor.toActivityEntity(
          notificationFeedItemViewData.activityEntityData),
      activityText: notificationFeedItemViewData.activityText,
      createdAt: notificationFeedItemViewData.createdAt,
      cta: notificationFeedItemViewData.cta,
      entityId: notificationFeedItemViewData.entityId,
      entityOwnerId: notificationFeedItemViewData.entityOwnerId,
      entityType: notificationFeedItemViewData.entityType,
      isRead: notificationFeedItemViewData.isRead,
      updatedAt: notificationFeedItemViewData.updatedAt,
    );
  }
}
