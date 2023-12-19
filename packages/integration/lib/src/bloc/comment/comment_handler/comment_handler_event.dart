part of 'comment_handler_bloc.dart';

abstract class LMCommentHandlerEvent extends Equatable {
  const LMCommentHandlerEvent();

  @override
  List<Object> get props => [];
}

class LMCommentActionEvent extends LMCommentHandlerEvent {
  final Object commentActionRequest;
  final LMCommentMetaData commentMetaData;

  LMCommentActionEvent({
    required this.commentActionRequest,
    required this.commentMetaData,
  }) : assert(commentActionRequest.runtimeType == AddCommentRequest ||
            commentActionRequest.runtimeType == AddCommentReplyRequest);

  @override
  List<Object> get props => [commentActionRequest, commentMetaData];
}

// This event is used to cancel the edit or reply flow
// for both comment and replies to comments
class LMCommentCancelEvent extends LMCommentHandlerEvent {
  final LMCommentType commentActionEntity;
  final LMCommentActionType commentActionType;

  const LMCommentCancelEvent({
    required this.commentActionEntity,
    required this.commentActionType,
  });
}
