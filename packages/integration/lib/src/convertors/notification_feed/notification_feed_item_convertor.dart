import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/notification_feed/activity_entity_convertor.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/user/user_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMNotificationFeedItemViewDataConvertor {
  static LMNotificationFeedItemViewData fromNotificationFeedItem(
      NotificationFeedItem notificationFeedItem, Map<String, User> users) {
    LMNotificationFeedItemViewDataBuilder notificationFeedItemViewDataBuilder =
        LMNotificationFeedItemViewDataBuilder();

    notificationFeedItemViewDataBuilder.id(notificationFeedItem.id);

    notificationFeedItemViewDataBuilder.action(notificationFeedItem.action);

    List<LMUserViewData> actionBy = [];
    for (String userId in notificationFeedItem.actionBy) {
      if (users[userId] != null) {
        final user = LMUserViewDataConvertor.fromUser(users[userId]!);
        actionBy.add(user);
      }
    }
    notificationFeedItemViewDataBuilder.actionBy(actionBy);

    notificationFeedItemViewDataBuilder.actionOn(notificationFeedItem.actionOn);

    notificationFeedItemViewDataBuilder.activityEntityViewData(
        LMActivityEntityViewDataConvertor.fromActivityEntity(
            notificationFeedItem.activityEntityData, users));

    notificationFeedItemViewDataBuilder
        .activityText(notificationFeedItem.activityText);

    if (notificationFeedItem.cta != null) {
      notificationFeedItemViewDataBuilder.cta(notificationFeedItem.cta!);
    }

    notificationFeedItemViewDataBuilder.createdAt(
        DateTime.fromMillisecondsSinceEpoch(notificationFeedItem.createdAt));

    notificationFeedItemViewDataBuilder.entityId(notificationFeedItem.entityId);

    if (notificationFeedItem.entityOwnerId != null) {
      notificationFeedItemViewDataBuilder
          .entityOwnerId(notificationFeedItem.entityOwnerId!);
    }

    notificationFeedItemViewDataBuilder
        .entityType(notificationFeedItem.entityType);

    notificationFeedItemViewDataBuilder.isRead(notificationFeedItem.isRead);

    notificationFeedItemViewDataBuilder.updatedAt(
        DateTime.fromMillisecondsSinceEpoch(notificationFeedItem.updatedAt));

    return notificationFeedItemViewDataBuilder.build();
  }

  static NotificationFeedItem toNotificationFeedItem(
      LMNotificationFeedItemViewData notificationFeedItemViewData) {
    return NotificationFeedItem(
      id: notificationFeedItemViewData.id,
      action: notificationFeedItemViewData.action,
      actionBy: notificationFeedItemViewData.actionBy
          .map((e) => e.sdkClientInfo.uuid)
          .toList(),
      actionOn: notificationFeedItemViewData.actionOn,
      activityEntityData: LMActivityEntityViewDataConvertor.toActivityEntity(
          notificationFeedItemViewData.activityEntityData),
      activityText: notificationFeedItemViewData.activityText,
      createdAt: notificationFeedItemViewData.createdAt.millisecondsSinceEpoch,
      cta: notificationFeedItemViewData.cta,
      entityId: notificationFeedItemViewData.entityId,
      entityOwnerId: notificationFeedItemViewData.entityOwnerId,
      entityType: notificationFeedItemViewData.entityType,
      isRead: notificationFeedItemViewData.isRead,
      updatedAt: notificationFeedItemViewData.updatedAt.millisecondsSinceEpoch,
    );
  }
}
