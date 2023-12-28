part of 'comment_replies_bloc.dart';

abstract class LMCommentRepliesEvent extends Equatable {
  const LMCommentRepliesEvent();
}

class LMGetCommentReplies extends LMCommentRepliesEvent {
  final GetCommentRequest commentDetailRequest;

  final bool forLoadMore;
  const LMGetCommentReplies(
      {required this.commentDetailRequest, required this.forLoadMore});

  @override
  List<Object?> get props => [commentDetailRequest, forLoadMore];
}

class LMClearCommentReplies extends LMCommentRepliesEvent {
  final int time = DateTime.now().millisecondsSinceEpoch;
  @override
  List<Object?> get props => [time];
}
