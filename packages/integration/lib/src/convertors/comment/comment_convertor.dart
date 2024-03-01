import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMCommentViewDataConvertor {
  static LMCommentViewData fromComment(
      Comment comment, Map<String, LMUserViewData> users) {
    LMCommentViewDataBuilder commentViewDataBuilder =
        LMCommentViewDataBuilder();
    commentViewDataBuilder
      ..id(comment.id)
      ..userId(comment.userId)
      ..text(comment.text)
      ..level(comment.level ?? 0)
      ..likesCount(comment.likesCount)
      ..repliesCount(comment.repliesCount)
      ..menuItems(comment.menuItems
          .map((e) => LMPopupMenuItemConvertor.fromPopUpMenuItemModel(item: e))
          .toList())
      ..createdAt(DateTime.fromMillisecondsSinceEpoch(comment.createdAt))
      ..updatedAt(DateTime.fromMillisecondsSinceEpoch(comment.updatedAt))
      ..isLiked(comment.isLiked)
      ..isEdited(comment.isEdited)
      ..uuid(comment.uuid)
      ..user(users[comment.userId]!)
      ..tempId(comment.tempId ?? '')
      ..parentComment(comment.parentComment != null
          ? LMCommentViewDataConvertor.fromComment(
              comment.parentComment!, users)
          : null);

    return commentViewDataBuilder.build();
  }

  static Comment toComment(LMCommentViewData commentViewData) {
    return Comment(
      userId: commentViewData.userId,
      text: commentViewData.text,
      level: commentViewData.level,
      likesCount: commentViewData.likesCount,
      repliesCount: commentViewData.repliesCount,
      menuItems: commentViewData.menuItems
          .map((e) => LMPopupMenuItemConvertor.toPopUpMenuItemModel(e))
          .toList(),
      createdAt: commentViewData.createdAt.millisecondsSinceEpoch,
      updatedAt: commentViewData.updatedAt.millisecondsSinceEpoch,
      isLiked: commentViewData.isLiked,
      id: commentViewData.id,
      parentComment: commentViewData.parentComment != null
          ? LMCommentViewDataConvertor.toComment(commentViewData.parentComment!)
          : null,
      isEdited: commentViewData.isEdited,
      replies: commentViewData.replies
          ?.map((e) => LMCommentViewDataConvertor.toComment(e))
          .toList(),
      uuid: commentViewData.uuid,
      tempId: commentViewData.tempId,
    );
  }
}
