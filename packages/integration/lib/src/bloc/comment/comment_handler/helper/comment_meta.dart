part of '../comment_handler_bloc.dart';

// [LMCommentType] defines the entity on which the
// action is being performed [COMMENT] or [REPLY]
enum LMCommentType {
  parent,
  reply,
}

// [LMCommentActionType] defines the type of
// action being performed [add], [edit], [delete]
enum LMCommentActionType {
  add,
  edit,
  delete,
}

// [LMCommentMetaData] defines the metadata of the comment
// which is being added, edited or deleted
class LMCommentMetaData {
  // [LMCommentType] defines the entity on which
  // the action is being performed (comment or reply)
  final LMCommentType commentActionEntity;
  // [LMCommentActionType] defines the type of
  // action being performed [add], [edit], [delete]
  final LMCommentActionType commentActionType;
  // Defines the level of the comment (0 for parent, 1 for reply,
  // 2 for reply of reply, and so on)
  final int level;
  // [ID] of the comment on which the action is being performed [REQUIRED]
  final String commentId;
  // [ID] of the reply if the action is being performed on a reply
  // [REQUIRED] in case the action is being performed on a reply
  final String? replyId;

  const LMCommentMetaData._({
    required this.commentActionEntity,
    required this.commentActionType,
    required this.level,
    required this.commentId,
    this.replyId,
  });
}

class LMCommentMetaDataBuilder {
  LMCommentType? _commentActionEntity;
  LMCommentActionType? _commentActionType;
  int? _level;
  String? _commentId;
  String? _replyId;

  void commentActionEntity(LMCommentType commentActionEntity) {
    _commentActionEntity = commentActionEntity;
  }

  void commentActionType(LMCommentActionType commentActionType) {
    _commentActionType = commentActionType;
  }

  void level(int level) {
    _level = level;
  }

  void commentId(String commentId) {
    _commentId = commentId;
  }

  void replyId(String replyId) {
    _replyId = replyId;
  }

  LMCommentMetaData build() {
    return LMCommentMetaData._(
      commentActionEntity: _commentActionEntity!,
      commentActionType: _commentActionType!,
      level: _level!,
      commentId: _commentId!,
      replyId: _replyId,
    );
  }
}
