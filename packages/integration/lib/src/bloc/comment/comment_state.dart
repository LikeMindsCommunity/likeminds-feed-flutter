part of 'comment_bloc.dart';

@immutable
sealed class LMCommentState extends Equatable {
  const LMCommentState();

  @override
  List<Object> get props => [];
}

final class LMCommentInitial extends LMCommentState {}

final class LMCommentRefreshState extends LMCommentState {}

final class LMGetCommentLoading extends LMCommentState {}

final class LMGetCommentPaginationLoading extends LMCommentState {}

final class LMGetCommentSuccess extends LMCommentState {
  final LMPostViewData post;
  final List<LMCommentViewData> comments;
  final int page;

  LMGetCommentSuccess({
    required this.post,
    required this.comments,
    required this.page,
  });

  @override
  List<Object> get props => [post, comments, page];
}

final class LMGetCommentError extends LMCommentState {
  final String error;

  LMGetCommentError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}

final class LMAddCommentSuccess extends LMCommentState {
  final LMCommentViewData comment;

  LMAddCommentSuccess({
    required this.comment,
  });

  @override
  List<Object> get props => [comment];
}

final class LMAddCommentError extends LMCommentState {
  final String error;
  final String commentId;

  LMAddCommentError({
    required this.error,
    required this.commentId,
  });

  @override
  List<Object> get props => [error, commentId];
}

final class LMEditingCommentState extends LMCommentState {
  final String postId;
  final LMCommentViewData oldComment;

  LMEditingCommentState({
    required this.postId,
    required this.oldComment,
  });

  @override
  List<Object> get props => [postId, oldComment];
}

final class LMEditingCommentCancelState extends LMCommentState {}

final class LMEditCommentSuccess extends LMCommentState {
  final LMCommentViewData commentViewData;
  LMEditCommentSuccess({
    required this.commentViewData,
  });
  @override
  List<Object> get props => [commentViewData];
}

final class LMEditCommentError extends LMCommentState {
  final String error;
  final LMCommentViewData oldComment;

  LMEditCommentError({
    required this.error,
    required this.oldComment,
  });

  @override
  List<Object> get props => [error, oldComment];
}

final class LMDeleteCommentSuccess extends LMCommentState {
  final String commentId;
  LMDeleteCommentSuccess({
    required this.commentId,
  });
  @override
  List<Object> get props => [commentId];
}

final class LMDeleteCommentError extends LMCommentState {
  final String error;
  final LMCommentViewData oldComment;
  final int index;

  LMDeleteCommentError({
    required this.error,
    required this.oldComment,
    required this.index,
  });

  @override
  List<Object> get props => [error, oldComment, index];
}

final class LMReplyingCommentState extends LMCommentState {
  final String postId;
  final LMCommentViewData parentComment;
  final String userName;

  LMReplyingCommentState({
    required this.postId,
    required this.parentComment,
    required this.userName,
  });

  @override
  List<Object> get props => [postId, parentComment, userName];
}

final class LMReplyCancelState extends LMCommentState {}

final class LMReplyCommentSuccess extends LMCommentState {
  final LMCommentViewData reply;

  LMReplyCommentSuccess({
    required this.reply,
  });

  @override
  List<Object> get props => [reply];
}

final class LMReplyCommentError extends LMCommentState {
  final String error;
  final String commentId;
  final String replyId;

  LMReplyCommentError({
    required this.error,
    required this.commentId,
    required this.replyId,
  });

  @override
  List<Object> get props => [error, commentId, replyId];
}

final class LMGetReplyCommentSuccess extends LMCommentState {
  final List<LMCommentViewData> replies;
  final int page;
  final String commentId;

  LMGetReplyCommentSuccess({
    required this.replies,
    required this.page,
    required this.commentId,
  });

  @override
  List<Object> get props => [replies, page, commentId];
}

final class LMGetReplyCommentLoading extends LMCommentState {
  final String commentId;

  LMGetReplyCommentLoading({
    required this.commentId,
  });

  @override
  List<Object> get props => [commentId];
}

final class LMGetReplyCommentPaginationLoading extends LMCommentState {
  final String commentId;

  LMGetReplyCommentPaginationLoading({
    required this.commentId,
  });

  @override
  List<Object> get props => [commentId];
}

final class LMCloseReplyState extends LMCommentState {
  final String commentId;

  LMCloseReplyState({
    required this.commentId,
  });

  @override
  List<Object> get props => [commentId];
}

final class LMEditingReplyState extends LMCommentState {
  final String postId;
  final String commentId;
  final LMCommentViewData oldReply;
  final String replyText;

  LMEditingReplyState({
    required this.postId,
    required this.commentId,
    required this.oldReply,
    required this.replyText,
  });

  @override
  List<Object> get props => [postId, commentId, oldReply, replyText];
}

final class LMEditReplySuccess extends LMCommentState {
  final String commentId;
  final String replyId;
  final LMCommentViewData reply;

  LMEditReplySuccess({
    required this.commentId,
    required this.replyId,
    required this.reply,
  });

  @override
  List<Object> get props => [commentId, replyId, reply];
}

final class LMEditReplyError extends LMCommentState {
  final String error;
  final String commentId;
  final LMCommentViewData oldReply;

  LMEditReplyError({
    required this.error,
    required this.commentId,
    required this.oldReply,
  });

  @override
  List<Object> get props => [error, commentId, oldReply];
}

final class LMDeleteReplySuccess extends LMCommentState {
  final String replyId;
  final String commentId;

  LMDeleteReplySuccess({
    required this.replyId,
    required this.commentId,
  });

  @override
  List<Object> get props => [replyId, commentId];
}

final class LMDeleteReplyError extends LMCommentState {
  final String error;
  final LMCommentViewData oldReply;

  LMDeleteReplyError({
    required this.error,
    required this.oldReply,
  });

  @override
  List<Object> get props => [error, oldReply];
}
