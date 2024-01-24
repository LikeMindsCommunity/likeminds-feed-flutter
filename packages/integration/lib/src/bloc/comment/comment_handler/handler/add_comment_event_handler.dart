part of '../comment_handler_bloc.dart';

/// {@template add_comment_event_handler}
/// [handleAddActionEvent] is used to handle the add comment/reply event
/// [LMFeedCommentActionEvent] is used to send the request to the handler
/// {@endtemplate}
Future<void> handleAddActionEvent(LMFeedCommentActionEvent event,
    Emitter<LMFeedCommentHandlerState> emit) async {
  // Check if the comment is a parent comment or a reply to a comment
  // and call the respective handler
  if (event.commentMetaData.commentActionType == LMFeedCommentActionType.add) {
    await _handleAddCommentAction(event, emit);
  } else if (event.commentMetaData.commentActionType ==
      LMFeedCommentActionType.replying) {
    await _handleAddReplyAction(event, emit);
  }
}

// Add comment handler
// This handler is used to add a new comment
// to a post
Future<void> _handleAddCommentAction(LMFeedCommentActionEvent event,
    Emitter<LMFeedCommentHandlerState> emit) async {
  // Get the instance of the LMFeedClient
  // to make the API call
  LMFeedClient lmFeedClient = LMFeedCore.instance.lmFeedClient;

  // AddCommentRequest is the request to be sent to the server
  // to add a new comment
  // It contains the [postId] and [comment] to be added to the post
  AddCommentRequest addCommentRequest =
      event.commentActionRequest as AddCommentRequest;

  // Emit the loading state
  // to show the loading indicator
  emit(LMFeedCommentLoadingState(commentMetaData: event.commentMetaData));

  // Make the API call to add the comment using the LMFeedClient and send
  // the [addCommentRequest] as the request and wait for the response
  AddCommentResponse? response =
      await lmFeedClient.addComment(addCommentRequest);

  // Check if the response is successful or not
  if (!response.success) {
    // If the response is not successful then emit the error state
    emit(LMFeedCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    // Fire the analytics event for comment posted
    // and send the [postId] and [commentId] as the parameters
    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
      eventName: LMFeedAnalyticsKeys.commentPosted,
      eventProperties: {
        "post_id": addCommentRequest.postId,
        "comment_id": response.reply?.id,
      },
    ));
    // If the response is successful then emit the success state
    // and send the [response] and [commentMetaData] as the parameters
    // to the state
    emit(LMFeedCommentSuccessState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  }
}

// Add reply handler
// This handler is used to add a new reply
// to a comment
Future<void> _handleAddReplyAction(LMFeedCommentActionEvent event,
    Emitter<LMFeedCommentHandlerState> emit) async {
  // Get the instance of the LMFeedClient
  // to make the API call
  LMFeedClient lmFeedClient = LMFeedCore.instance.lmFeedClient;

  // AddCommentReplyRequest is the request to be sent to the server
  // to add a new reply
  // It contains the [postId], [commentId] and [reply] to be added to the post
  // [commentId] is the id of the comment to which the reply is to be added
  AddCommentReplyRequest addCommentReplyRequest =
      event.commentActionRequest as AddCommentReplyRequest;

  // Emit the loading state
  // to show the loading indicator
  emit(LMFeedCommentLoadingState(
    commentMetaData: event.commentMetaData,
  ));

  // Make the API call to add the reply using the LMFeedClient and send
  // the [addCommentReplyRequest] as the request and wait for the response
  // AddCommentReplyResponse is the response received from the server
  AddCommentReplyResponse response =
      await lmFeedClient.addCommentReply(addCommentReplyRequest);

  // Check if the response is successful or not
  if (!response.success) {
    // If the response is not successful then emit the error state
    emit(LMFeedCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    // Fire the analytics event for reply posted
    // and send the [postId], [commentId] and [commentReplyId] as the parameters
    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
      eventName: LMFeedAnalyticsKeys.replyPosted,
      eventProperties: {
        "post_id": addCommentReplyRequest.postId,
        "comment_id": addCommentReplyRequest.commentId,
        "comment_reply_id": response.reply?.id,
        // TODO: Add user details
        // "user_id": event.userId,
      },
    ));
    // If the response is successful then emit the success state
    // and send the [response] and [commentMetaData] as the parameters
    //  to the state
    emit(LMFeedCommentSuccessState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  }
}
