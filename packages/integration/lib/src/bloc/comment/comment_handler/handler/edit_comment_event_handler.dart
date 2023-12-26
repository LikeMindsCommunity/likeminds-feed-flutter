part of '../comment_handler_bloc.dart';

/// {@template edit_comment_event_handler}
/// [handleEditActionEvent] is used to handle the edit request
/// for both comment and replies to comments
/// [LMCommentActionEvent] is used to send the request to the handler
/// {@endtemplate}
Future<void> handleEditActionEvent(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  // Notify the UI to change the view to Editing
  emit(LMCommentActionOngoingState(commentMetaData: event.commentMetaData));

  // Check if the comment is a parent comment or a reply to a comment
  if (event.commentMetaData.commentActionEntity == LMCommentType.parent) {
    await _handleEditCommentAction(event, emit);
  } else if (event.commentMetaData.commentActionEntity == LMCommentType.reply) {
    await _handleEditReplyAction(event, emit);
  }
}

Future<void> _handleEditCommentAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  LMFeedClient lmFeedClient = LMFeedIntegration.instance.lmFeedClient;

  EditCommentRequest editCommentRequest =
      event.commentActionRequest as EditCommentRequest;

  EditCommentResponse response =
      await lmFeedClient.editComment(editCommentRequest);

  if (!response.success) {
    emit(LMCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    emit(LMCommentSuccessState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  }
}

Future<void> _handleEditReplyAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  LMFeedClient lmFeedClient = LMFeedIntegration.instance.lmFeedClient;

  EditCommentReplyRequest editCommentReplyRequest =
      event.commentActionRequest as EditCommentReplyRequest;

  EditCommentReplyResponse response =
      await lmFeedClient.editCommentReply(editCommentReplyRequest);

  if (!response.success) {
    emit(LMCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    emit(LMCommentSuccessState(
      commentMetaData: event.commentMetaData,
      commentActionResponse: response,
    ));
  }
}
