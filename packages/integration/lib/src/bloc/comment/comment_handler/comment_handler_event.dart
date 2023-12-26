part of 'comment_handler_bloc.dart';

abstract class LMCommentHandlerEvent extends Equatable {
  const LMCommentHandlerEvent();

  @override
  List<Object> get props => [];
}

class LMCommentActionEvent<Response extends Object>
    extends LMCommentHandlerEvent {
  final Response commentActionRequest;
  final LMCommentMetaData commentMetaData;

  const LMCommentActionEvent({
    required this.commentActionRequest,
    required this.commentMetaData,
  }) : assert(commentActionRequest is AddCommentRequest ||
            commentActionRequest is AddCommentReplyRequest ||
            commentActionRequest is EditCommentRequest ||
            commentActionRequest is EditCommentReplyRequest ||
            commentActionRequest is DeleteCommentRequest);

  @override
  List<Object> get props => [commentActionRequest, commentMetaData];
}

class LMCommentOngoingEvent extends LMCommentHandlerEvent {
  final LMCommentMetaData commentMetaData;

  const LMCommentOngoingEvent({
    required this.commentMetaData,
  });
}

// This event is used to cancel the edit or reply flow
// for both comment and replies to comments
class LMCommentCancelEvent extends LMCommentHandlerEvent {}
