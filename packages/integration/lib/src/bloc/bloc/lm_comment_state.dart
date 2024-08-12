part of 'lm_comment_bloc.dart';

@immutable
sealed class LMCommentState extends Equatable {
  const LMCommentState();

  @override
  List<Object> get props => [];
}

final class LMCommentInitial extends LMCommentState {}

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

final class LMAddCommentLoading extends LMCommentState {}

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

  LMAddCommentError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}

final class LMEditingCommentState extends LMCommentState {
  final String postId;
  final String commentId;
  final String comment;

  LMEditingCommentState({
    required this.postId,
    required this.commentId,
    required this.comment,
  });

  @override
  List<Object> get props => [postId, commentId, comment];
}

final class LMEditingCommentCancelState extends LMCommentState {}

final class LMEditCommentLoading extends LMCommentState {}

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

  LMEditCommentError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}

final class LMDeleteCommentLoading extends LMCommentState {}

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

  LMDeleteCommentError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}

final class LMReplyingCommentState extends LMCommentState {
  final String postId;
  final String commentId;
  final String userName;

  LMReplyingCommentState({
    required this.postId,
    required this.commentId,
    required this.userName,
  });

  @override
  List<Object> get props => [postId, commentId, userName];
}

final class LMReplyCancelState extends LMCommentState {}

final class LMReplyCommentLoading extends LMCommentState {}

final class LMReplyCommentSuccess extends LMCommentState {
  final LMCommentViewData comment;

  LMReplyCommentSuccess({
    required this.comment,
  });

  @override
  List<Object> get props => [comment];
}

final class LMReplyCommentError extends LMCommentState {
  final String error;

  LMReplyCommentError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}

final class LMGetReplyCommentSuccess extends LMCommentState {
  final List<LMCommentViewData> replies;
  final int page;

  LMGetReplyCommentSuccess({
    required this.replies,
    required this.page,
  });

  @override
  List<Object> get props => [replies, page];
}

final class LMEditReplyLoading extends LMCommentState {}

final class LMEditReplySuccess extends LMCommentState {}

final class LMEditReplyError extends LMCommentState {
  final String error;

  LMEditReplyError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}

final class LMDeleteReplyLoading extends LMCommentState {}

final class LMDeleteReplySuccess extends LMCommentState {}

final class LMDeleteReplyError extends LMCommentState {
  final String error;

  LMDeleteReplyError({
    required this.error,
  });

  @override
  List<Object> get props => [error];
}
