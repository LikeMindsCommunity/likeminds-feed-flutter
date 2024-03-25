import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMActivityEntityViewDataConvertor {
  static LMActivityEntityViewData fromActivityEntity(
      ActivityEntityData activityEntityData, Map<String, User> users) {
    LMActivityEntityViewDataBuilder activityEntityViewDataBuilder =
        LMActivityEntityViewDataBuilder();

    activityEntityViewDataBuilder.id(activityEntityData.id);

    if (activityEntityData.attachments != null) {
      activityEntityViewDataBuilder.attachments(activityEntityData.attachments!
          .map((e) =>
              LMAttachmentViewDataConvertor.fromAttachment(attachment: e))
          .toList());
    }

    if (activityEntityData.chatroomId != null) {
      activityEntityViewDataBuilder.chatroomId(activityEntityData.chatroomId!);
    }

    activityEntityViewDataBuilder.communityId(activityEntityData.communityId);

    activityEntityViewDataBuilder.createdAt(activityEntityData.createdAt);

    if (activityEntityData.deleteReason != null) {
      activityEntityViewDataBuilder
          .deleteReason(activityEntityData.deleteReason!);
    }

    if (activityEntityData.deleteBy != null) {
      activityEntityViewDataBuilder.deleteBy(activityEntityData.deleteBy!);
    }

    if (activityEntityData.heading != null) {
      activityEntityViewDataBuilder.heading(activityEntityData.heading!);
    }

    if (activityEntityData.level != null) {
      activityEntityViewDataBuilder.level(activityEntityData.level!);
    }

    if (activityEntityData.postId != null) {
      activityEntityViewDataBuilder.postId(activityEntityData.postId!);
    }

    if (activityEntityData.isDeleted != null) {
      activityEntityViewDataBuilder.isDeleted(activityEntityData.isDeleted!);
    }

    if (activityEntityData.isPinned != null) {
      activityEntityViewDataBuilder.isPinned(activityEntityData.isPinned!);
    }

    if (activityEntityData.isEdited != null) {
      activityEntityViewDataBuilder.isEdited(activityEntityData.isEdited!);
    }

    activityEntityViewDataBuilder.text(activityEntityData.text);

    if (activityEntityData.replies != null) {
      activityEntityViewDataBuilder.replies(activityEntityData.replies!
          .map((e) => LMCommentViewDataConvertor.fromComment(
              e,
              users.map((key, value) =>
                  MapEntry(key, LMUserViewDataConvertor.fromUser(value)))))
          .toList());
    }

    if (activityEntityData.updatedAt != null) {
      activityEntityViewDataBuilder.updatedAt(activityEntityData.updatedAt!);
    }

    activityEntityViewDataBuilder.uuid(activityEntityData.uuid);

    return activityEntityViewDataBuilder.build();
  }

  static ActivityEntityData toActivityEntity(
      LMActivityEntityViewData activityEntityViewData) {
    return ActivityEntityData(
      id: activityEntityViewData.id,
      attachments: activityEntityViewData.attachments
          ?.map((e) => LMAttachmentViewDataConvertor.toAttachment(e))
          .toList(),
      chatroomId: activityEntityViewData.chatroomId,
      communityId: activityEntityViewData.communityId,
      createdAt: activityEntityViewData.createdAt,
      deleteReason: activityEntityViewData.deleteReason,
      deleteBy: activityEntityViewData.deleteBy,
      heading: activityEntityViewData.heading,
      level: activityEntityViewData.level,
      postId: activityEntityViewData.postId,
      isDeleted: activityEntityViewData.isDeleted,
      isEdited: activityEntityViewData.isEdited,
      isPinned: activityEntityViewData.isPinned,
      replies: activityEntityViewData.replies
          ?.map((e) => LMCommentViewDataConvertor.toComment(e))
          .toList(),
      text: activityEntityViewData.text,
      updatedAt: activityEntityViewData.updatedAt,
      uuid: activityEntityViewData.uuid,
    );
  }
}
