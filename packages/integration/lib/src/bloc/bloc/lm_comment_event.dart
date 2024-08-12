part of 'lm_comment_bloc.dart';

@immutable
sealed class LMCommentEvent extends Equatable {
  const LMCommentEvent();

  @override
  List<Object> get props => [];
}

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
  final String commentId;
  final String commentText;

  LMEditingCommentEvent({
    required this.postId,
    required this.commentId,
    required this.commentText,
  });

  @override
  List<Object> get props => [postId, commentId, commentText];
}

final class LMEditCommentEvent extends LMCommentEvent {
  final String postId;
  final String commentId;
  final String commentText;

  LMEditCommentEvent(this.postId, this.commentId, this.commentText);
  @override
  List<Object> get props => [postId, commentId, commentText];
}

final class LMEditCommentCancelEvent extends LMCommentEvent {}

final class LMDeleteComment extends LMCommentEvent {
  final String postId;
  final String commentId;
  final String reason;

  LMDeleteComment({
    required this.postId,
    required this.commentId,
    required this.reason,
  });

  @override
  List<Object> get props => [postId, commentId, reason];
}

final class LMReplyingCommentEvent extends LMCommentEvent {
  final String postId;
  final String commentId;
  final String userName;

  LMReplyingCommentEvent({
    required this.postId,
    required this.commentId,
    required this.userName,
  });

  @override
  List<Object> get props => [postId, commentId, userName];
}

final class LMReplyCommentEvent extends LMCommentEvent {
  final String postId;
  final String commentId;
  final String comment;

  LMReplyCommentEvent({
    required this.postId,
    required this.commentId,
    required this.comment,
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

final class LMEditReply extends LMCommentEvent {
  final String postId;
  final String commentId;
  final String replyId;
  final String comment;

  LMEditReply(this.postId, this.commentId, this.replyId, this.comment);
}

final class LMEditReplyCancelEvent extends LMCommentEvent {}

final class LMDeleteReplyEvent extends LMCommentEvent {
  final String postId;
  final String commentId;
  final String replyId;

  LMDeleteReplyEvent(this.postId, this.commentId, this.replyId);
}
