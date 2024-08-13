part of 'comment_bloc.dart';

@immutable
sealed class LMCommentEvent extends Equatable {
  const LMCommentEvent();

  @override
  List<Object> get props => [];
}

final class LMCommentRefreshEvent extends LMCommentEvent {}

final class LMGetCommentsEvent extends LMCommentEvent {
  final String postId;
  final int page;
  final int commentListPageSize;

  LMGetCommentsEvent({
    required this.postId,
    required this.page,
    required this.commentListPageSize,
  });
  @override
  List<Object> get props => [postId, page, commentListPageSize];
}

final class LMAddCommentEvent extends LMCommentEvent {
  final String postId;
  final String comment;

  LMAddCommentEvent({
    required this.postId,
    required this.comment,
  });
  @override
  List<Object> get props => [postId, comment];
}

final class LMEditingCommentEvent extends LMCommentEvent {
  final String postId;
  final LMCommentViewData oldComment;

  LMEditingCommentEvent({
    required this.postId,
    required this.oldComment,
  });

  @override
  List<Object> get props => [postId, oldComment];
}

final class LMEditCommentEvent extends LMCommentEvent {
  final String postId;
  final LMCommentViewData oldComment;
  final String editedText;

  LMEditCommentEvent(this.postId, this.oldComment, this.editedText);
  @override
  List<Object> get props => [postId, oldComment, editedText];
}

final class LMEditCommentCancelEvent extends LMCommentEvent {}

final class LMDeleteComment extends LMCommentEvent {
  final String postId;
  final LMCommentViewData oldComment;
  final String reason;
  final int index;

  LMDeleteComment({
    required this.postId,
    required this.oldComment,
    required this.reason,
    required this.index,
  });

  @override
  List<Object> get props => [postId, oldComment, reason, index];
}

final class LMReplyingCommentEvent extends LMCommentEvent {
  final String postId;
  final LMCommentViewData parentComment;
  final String userName;

  LMReplyingCommentEvent({
    required this.postId,
    required this.parentComment,
    required this.userName,
  });

  @override
  List<Object> get props => [postId, parentComment, userName];
}

final class LMReplyCommentEvent extends LMCommentEvent {
  final String postId;
  final LMCommentViewData parentComment;
  final String replyText;

  LMReplyCommentEvent({
    required this.postId,
    required this.parentComment,
    required this.replyText,
  });
}

final class LMReplyCancelEvent extends LMCommentEvent {}

final class LMGetReplyEvent extends LMCommentEvent {
  final String postId;
  final String commentId;
  final int page;
  final int pageSize;

  LMGetReplyEvent({
    required this.postId,
    required this.commentId,
    required this.page,
    required this.pageSize,
  });

  @override
  List<Object> get props => [postId, commentId, page, pageSize];
}

final class LMCloseReplyEvent extends LMCommentEvent {
  final String commentId;

  LMCloseReplyEvent({
    required this.commentId,
  });

  @override
  List<Object> get props => [commentId];
}

final class LMEditingReplyEvent extends LMCommentEvent {
  final String postId;
  final String commentId;
  final LMCommentViewData oldReply;
  final String replyText;

  LMEditingReplyEvent({
    required this.postId,
    required this.commentId,
    required this.oldReply,
    required this.replyText,
  });

  @override
  List<Object> get props => [postId, commentId, oldReply, replyText];
}

final class LMEditReply extends LMCommentEvent {
  final String postId;
  final String commentId;
  final LMCommentViewData oldReply;
  final String editText;

  LMEditReply({
    required this.postId,
    required this.commentId,
    required this.oldReply,
    required this.editText,
  });

  @override
  List<Object> get props => [postId, commentId, oldReply, editText];
}

final class LMEditReplyCancelEvent extends LMCommentEvent {}

final class LMDeleteReplyEvent extends LMCommentEvent {
  final String postId;
  final LMCommentViewData oldReply;
  final String reason;
  final String commentId;

  LMDeleteReplyEvent({
    required this.postId,
    required this.oldReply,
    required this.reason,
    required this.commentId,
  });

  @override
  List<Object> get props => [postId, oldReply, reason, commentId];
}
