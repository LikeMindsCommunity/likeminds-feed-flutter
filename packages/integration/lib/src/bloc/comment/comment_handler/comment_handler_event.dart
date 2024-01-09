part of 'comment_handler_bloc.dart';

/// {@template lm_comment_handler_event}
/// LMFeedCommentHandlerEvent defines the event handled by LMFeedCommentHandlerBloc.
/// {@endtemplate}
abstract class LMFeedCommentHandlerEvent extends Equatable {
  /// {@macro lm_comment_handler_event}
  const LMFeedCommentHandlerEvent();

  @override
  List<Object> get props => [];
}

/// {@template lm_comment_action_event}
/// LMFeedCommentActionEvent defines the event to handle comment related actions
/// like add, edit, delete, etc.
/// [commentActionRequest] of type Response defines the request to be sent
/// to the server. It can be of type AddCommentRequest, AddCommentReplyRequest,
/// EditCommentRequest, EditCommentReplyRequest, DeleteCommentRequest.
///
/// [commentMetaData] of type LMCommentMetaData defines the metadata of the
/// comment/reply on which the action is to be performed.
///
/// {@endtemplate}
class LMFeedCommentActionEvent<Response extends Object>
    extends LMFeedCommentHandlerEvent {
  final Response commentActionRequest;
  final LMCommentMetaData commentMetaData;

  const LMFeedCommentActionEvent({
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
/// LMFeedCommentOngoingEvent defines the event to handle the ongoing comment
/// i.e. A user is editing a comment/reply or replying to a existing comment
/// [commentMetaData] of type LMCommentMetaData defines the metadata of the
/// comment/reply on which the action is to be performed.
/// {@endtemplate}
class LMFeedCommentOngoingEvent extends LMFeedCommentHandlerEvent {
  final LMCommentMetaData commentMetaData;

  const LMFeedCommentOngoingEvent({
    required this.commentMetaData,
  });
}

/// {@template lm_comment_cancel_event}
/// LMFeedCommentCancelEvent defines the event to handle the cancel comment
/// i.e. A user has cancelled editing a comment/reply or
/// replying to a existing comment
/// {@endtemplate}
class LMFeedCommentCancelEvent extends LMFeedCommentHandlerEvent {}
