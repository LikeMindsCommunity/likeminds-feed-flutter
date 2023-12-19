part of 'add_comment_reply_bloc.dart';

abstract class LMCommentHandlerEvent extends Equatable {
  const LMCommentHandlerEvent();

  @override
  List<Object> get props => [];
}

// Add Comment events
class LMAddCommentReplyEvent extends LMCommentHandlerEvent {
  final AddCommentReplyRequest addCommentRequest;
  const LMAddCommentReplyEvent({required this.addCommentRequest});

  @override
  List<Object> get props => [addCommentRequest];
}

class LMDeleteCommentEvent extends LMCommentHandlerEvent {
  final DeleteCommentRequest deleteCommentRequest;
  const LMDeleteCommentEvent(this.deleteCommentRequest);
}

class LMDeleteCommentReplyEvent extends LMCommentHandlerEvent {
  final DeleteCommentRequest deleteCommentReplyRequest;
  const LMDeleteCommentReplyEvent(this.deleteCommentReplyRequest);
}

class LMEditCommentEvent extends LMCommentHandlerEvent {
  final EditCommentRequest editCommentRequest;
  const LMEditCommentEvent({required this.editCommentRequest});

  @override
  List<Object> get props => [editCommentRequest];
}

class LMEditCommentCancelEvent extends LMCommentHandlerEvent {}

class LMEditingCommentEvent extends LMCommentHandlerEvent {
  final String commentId;
  final String text;

  const LMEditingCommentEvent({required this.commentId, required this.text});
}

class LMEditReplyEvent extends LMCommentHandlerEvent {
  final EditCommentReplyRequest editCommentReplyRequest;

  const LMEditReplyEvent({required this.editCommentReplyRequest});

  @override
  List<Object> get props => [editCommentReplyRequest];
}

class LMEditReplyCancelEvent extends LMCommentHandlerEvent {}

class LMEditingReplyEvent extends LMCommentHandlerEvent {
  final String commentId;
  final String text;
  final String replyId;

  const LMEditingReplyEvent(
      {required this.commentId, required this.text, required this.replyId});
}
