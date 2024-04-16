part of 'comment_replies_bloc.dart';

abstract class LMFeedCommentRepliesEvent extends Equatable {
  const LMFeedCommentRepliesEvent();
}

class LMFeedGetCommentRepliesEvent extends LMFeedCommentRepliesEvent {
  final GetCommentRequest commentDetailRequest;

  final bool forLoadMore;
  const LMFeedGetCommentRepliesEvent(
      {required this.commentDetailRequest, required this.forLoadMore});

  @override
  List<Object?> get props => [commentDetailRequest, forLoadMore];
}

class LMFeedClearCommentRepliesEvent extends LMFeedCommentRepliesEvent {
  final int time = DateTime.now().millisecondsSinceEpoch;
  @override
  List<Object?> get props => [time];
}

class LMFeedAddLocalReplyEvent extends LMFeedCommentRepliesEvent {
  final LMCommentViewData comment;
  const LMFeedAddLocalReplyEvent({required this.comment});
  @override
  List<Object?> get props => [comment];
}

class LMFeedEditLocalReplyEvent extends LMFeedCommentRepliesEvent {
  final String text;
  final String replyId;

  const LMFeedEditLocalReplyEvent({required this.text, required this.replyId});

  @override
  List<Object?> get props => [text];
}

class LMFeedDeleteLocalReplyEvent extends LMFeedCommentRepliesEvent {
  final String replyId;

  const LMFeedDeleteLocalReplyEvent({required this.replyId});

  @override
  List<Object?> get props => [replyId];
}
