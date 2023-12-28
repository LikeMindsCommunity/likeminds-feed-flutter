import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/common/popup_menu_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class CommentViewDataConvertor {
  static LMCommentViewData fromComment(Comment comment) {
    LMCommentViewDataBuilder commentViewDataBuilder =
        LMCommentViewDataBuilder();
    commentViewDataBuilder
      ..id(comment.id)
      ..userId(comment.userId)
      ..text(comment.text)
      ..level(comment.level)
      ..likesCount(comment.likesCount)
      ..repliesCount(comment.repliesCount)
      ..menuItems(comment.menuItems
          .map((e) => PopupMenuItemConvertor.fromPopUpMenuItemModel(item: e))
          .toList())
      ..createdAt(DateTime.fromMillisecondsSinceEpoch(comment.createdAt))
      ..updatedAt(DateTime.fromMillisecondsSinceEpoch(comment.updatedAt))
      ..isLiked(comment.isLiked)
      ..isEdited(comment.isEdited)
      ..uuid(comment.uuid)
      ..parentComment(comment.parentComment != null
          ? CommentViewDataConvertor.fromComment(comment.parentComment!)
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
          .map((e) => PopupMenuItemConvertor.toPopUpMenuItemModel(e))
          .toList(),
      createdAt: commentViewData.createdAt.millisecondsSinceEpoch,
      updatedAt: commentViewData.updatedAt.millisecondsSinceEpoch,
      isLiked: commentViewData.isLiked,
      id: commentViewData.id,
      parentComment: commentViewData.parentComment != null
          ? CommentViewDataConvertor.toComment(commentViewData.parentComment!)
          : null,
      isEdited: commentViewData.isEdited,
      replies: commentViewData.replies
          ?.map((e) => CommentViewDataConvertor.toComment(e))
          .toList(),
      uuid: commentViewData.uuid,
      tempId: commentViewData.tempId,
    );
  }
}