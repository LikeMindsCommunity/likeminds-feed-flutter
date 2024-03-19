// ignore_for_file: public_member_api_docs, sort_constructors_first
part of 'comment_replies_bloc.dart';

abstract class LMFeedCommentRepliesState extends Equatable {
  const LMFeedCommentRepliesState();
}

class LMFeedCommentRepliesInitialState extends LMFeedCommentRepliesState {
  @override
  List<Object?> get props => [];
}

class LMFeedCommentRepliesLoadedState extends LMFeedCommentRepliesState {
  final GetCommentResponse commentDetails;
  final String commentId;

  const LMFeedCommentRepliesLoadedState({
    required this.commentDetails,
    required this.commentId,
  });

  @override
  List<Object?> get props => [commentDetails];
}

class LMFeedCommentRepliesLoadingState extends LMFeedCommentRepliesState {
  final String commentId;

  const LMFeedCommentRepliesLoadingState({
    required this.commentId,
  });

  @override
  List<Object?> get props => [];
}

class LMFeedPaginatedCommentRepliesLoadingState
    extends LMFeedCommentRepliesState {
  final GetCommentResponse prevCommentDetails;
  final String commentId;

  const LMFeedPaginatedCommentRepliesLoadingState({
    required this.prevCommentDetails,
    required this.commentId,
  });
  @override
  List<Object?> get props => [];
}

class LMFeedCommentRepliesErrorState extends LMFeedCommentRepliesState {
  final String message;

  const LMFeedCommentRepliesErrorState({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

class LMFeedClearedCommentRepliesState extends LMFeedCommentRepliesState {
  final int time = DateTime.now().millisecondsSinceEpoch;
  @override
  List<Object?> get props => [time];
}

class LMFeedAddLocalReplyState extends LMFeedCommentRepliesState {
  final LMCommentViewData comment;
  const LMFeedAddLocalReplyState({required this.comment});
  @override
  List<Object?> get props => [comment];
}
