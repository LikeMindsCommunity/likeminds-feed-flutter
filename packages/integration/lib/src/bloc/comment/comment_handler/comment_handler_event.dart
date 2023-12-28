part of 'comment_handler_bloc.dart';

/// {@template lm_comment_handler_event}
/// LMCommentHandlerEvent defines the event handled by LMCommentHandlerBloc.
/// {@endtemplate}
abstract class LMCommentHandlerEvent extends Equatable {
  /// {@macro lm_comment_handler_event}
  const LMCommentHandlerEvent();

  @override
  List<Object> get props => [];
}

/// {@template lm_comment_action_event}
/// LMCommentActionEvent defines the event to handle comment related actions
/// like add, edit, delete, etc.
/// [commentActionRequest] of type Response defines the request to be sent
/// to the server. It can be of type AddCommentRequest, AddCommentReplyRequest,
/// EditCommentRequest, EditCommentReplyRequest, DeleteCommentRequest.
///
/// [commentMetaData] of type LMCommentMetaData defines the metadata of the
/// comment/reply on which the action is to be performed.
///
/// {@endtemplate}
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

/// {@template lm_comment_ongoing_event}
/// LMCommentOngoingEvent defines the event to handle the ongoing comment
/// i.e. A user is editing a comment/reply or replying to a existing comment
/// [commentMetaData] of type LMCommentMetaData defines the metadata of the
/// comment/reply on which the action is to be performed.
/// {@endtemplate}
class LMCommentOngoingEvent extends LMCommentHandlerEvent {
  final LMCommentMetaData commentMetaData;

  const LMCommentOngoingEvent({
    required this.commentMetaData,
  });
}

/// {@template lm_comment_cancel_event}
/// LMCommentCancelEvent defines the event to handle the cancel comment
/// i.e. A user has cancelled editing a comment/reply or
/// replying to a existing comment
/// {@endtemplate}
class LMCommentCancelEvent extends LMCommentHandlerEvent {}
