part of '../comment_handler_bloc.dart';

/// {@template lm_comment_type}
/// LMCommentType defines the entity on which the
/// action is being performed [parent] or [reply]
/// {@endtemplate}
enum LMCommentType {
  parent,
  reply,
}

/// {@template lm_comment_action_type}
/// LMCommentActionType defines the type of
/// action being performed [LMCommentActionType.add],
/// [LMCommentActionType.edit], [LMCommentActionType.delete],
/// [LMCommentActionType.replying].
/// while adding a reply to an existing comment always
/// select [LMCommentActionType.replying]
/// {@endtemplate}
enum LMCommentActionType {
  add,
  edit,
  delete,
  replying,
}

/// {@template lm_comment_meta_data}
/// [LMCommentMetaData] defines the metadata of the comment
/// which is being added, edited or deleted
/// {@endtemplate}
class LMCommentMetaData {
  // [LMCommentType] defines the entity on which
  // the action is being performed (comment or reply)
  // {@macro lm_comment_type}
  final LMCommentType commentActionEntity;
  // [LMCommentActionType] defines the type of
  // action being performed [add], [edit], [delete]
  // {@macro lm_comment_action_type}
  final LMCommentActionType commentActionType;
  // Defines the level of the comment (0 for parent, 1 for reply,
  // 2 for reply of reply, and so on)
  final int level;
  // [ID] of the comment on which the action is being performed [REQUIRED]
  final String? commentId;
  // [ID] of the reply if the action is being performed on a reply
  // [REQUIRED] in case the action is being performed on a reply
  final String? replyId;
  // [LMUserViewData] data in case the action is being performed on a reply
  // @{macro lm_user_view_data}
  final LMUserViewData? user;

  /// {@macro lm_comment_meta_data}
  const LMCommentMetaData._({
    required this.commentActionEntity,
    required this.commentActionType,
    required this.level,
    required this.commentId,
    this.replyId,
    this.user,
  });
}

/// {@template lm_comment_meta_data_builder}
/// LMCommentMetaDataBuilder is a builder class for LMCommentMetaData
/// {@endtemplate}
class LMCommentMetaDataBuilder {
  // @{macro lm_comment_type}
  LMCommentType? _commentActionEntity;
  // @{macro lm_comment_action_type}
  LMCommentActionType? _commentActionType;
  int? _level;
  String? _commentId;
  String? _replyId;
  LMUserViewData? _user;

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

  void user(LMUserViewData user) {
    _user = user;
  }

  LMCommentMetaData build() {
    return LMCommentMetaData._(
      commentActionEntity: _commentActionEntity!,
      commentActionType: _commentActionType!,
      level: _level!,
      commentId: _commentId,
      replyId: _replyId,
      user: _user,
    );
  }
}
