// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'comment_replies_bloc.dart';

abstract class LMCommentRepliesState extends Equatable {
  const LMCommentRepliesState();
}

class LMCommentRepliesInitial extends LMCommentRepliesState {
  @override
  List<Object?> get props => [];
}

class LMCommentRepliesLoaded extends LMCommentRepliesState {
  final GetCommentResponse commentDetails;
  final String commentId;

  const LMCommentRepliesLoaded({
    required this.commentDetails,
    required this.commentId,
  });

  @override
  List<Object?> get props => [commentDetails];
}

class LMCommentRepliesLoading extends LMCommentRepliesState {
  final String commentId;

  const LMCommentRepliesLoading({
    required this.commentId,
  });

  @override
  List<Object?> get props => [];
}

class LMPaginatedCommentRepliesLoading extends LMCommentRepliesState {
  final GetCommentResponse prevCommentDetails;
  final String commentId;

  const LMPaginatedCommentRepliesLoading({
    required this.prevCommentDetails,
    required this.commentId,
  });
  @override
  List<Object?> get props => [];
}

class LMCommentRepliesError extends LMCommentRepliesState {
  final String message;

  const LMCommentRepliesError({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class LMClearedCommentReplies extends LMCommentRepliesState {
  final int time = DateTime.now().millisecondsSinceEpoch;
  @override
  List<Object?> get props => [time];
}
