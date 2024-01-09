part of '../comment_handler_bloc.dart';

/// {@template edit_comment_event_handler}
/// [handleEditActionEvent] is used to handle the edit request
/// for both comment and replies to comments
/// [LMFeedCommentActionEvent] is used to send the request to the handler
/// {@endtemplate}
Future<void> handleEditActionEvent(LMFeedCommentActionEvent event,
    Emitter<LMFeedCommentHandlerState> emit) async {
  // Notify the UI to change the view to Editing
  emit(LMFeedCommentActionOngoingState(commentMetaData: event.commentMetaData));

  // Check if the comment is a parent comment or a reply to a comment
  if (event.commentMetaData.commentActionEntity == LMFeedCommentType.parent) {
    await _handleEditCommentAction(event, emit);
  } else if (event.commentMetaData.commentActionEntity ==
      LMFeedCommentType.reply) {
    await _handleEditReplyAction(event, emit);
  }
}

// Edit comment handler
Future<void> _handleEditCommentAction(LMFeedCommentActionEvent event,
    Emitter<LMFeedCommentHandlerState> emit) async {
  // Get the instance of the LMFeedClient
  // to make the API call
  LMFeedClient lmFeedClient = LMFeedCore.instance.lmFeedClient;

  // EditCommentRequest is the request to be sent to the server
  // to edit a comment
  // It contains the [postId] and [commentId] to be edited from the post
  // and the [comment] to be updated
  EditCommentRequest editCommentRequest =
      event.commentActionRequest as EditCommentRequest;

  // Call editComment API to edit the comment
  // and wait for the response
  EditCommentResponse response =
      await lmFeedClient.editComment(editCommentRequest);

  // Check if the response is success or not
  if (!response.success) {
    // If the response is not success then notify the UI
    // to change the view to Error
    emit(LMFeedCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    // If the response is success then notify the UI
    //to change the view to Success
    emit(LMFeedCommentSuccessState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  }
}

// Edit reply handler
Future<void> _handleEditReplyAction(LMFeedCommentActionEvent event,
    Emitter<LMFeedCommentHandlerState> emit) async {
  // Get the instance of the LMFeedClient
  // to make the API call
  LMFeedClient lmFeedClient = LMFeedCore.instance.lmFeedClient;

  // EditCommentReplyRequest is the request to be sent to the server
  // to edit a reply
  // It contains the [postId] and [commentId] to be edited from the post
  // and the [comment] to be updated
  EditCommentReplyRequest editCommentReplyRequest =
      event.commentActionRequest as EditCommentReplyRequest;

  // Call editCommentReply API to edit the reply
  // and wait for the response
  EditCommentReplyResponse response =
      await lmFeedClient.editCommentReply(editCommentReplyRequest);

  // Check if the response is success or not
  if (!response.success) {
    // If the response is not success then notify the UI
    // to change the view to Error
    emit(LMFeedCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    // If the response is success then notify the UI
    // to change the view to Success
    emit(LMFeedCommentSuccessState(
      commentMetaData: event.commentMetaData,
      commentActionResponse: response,
    ));
  }
}
