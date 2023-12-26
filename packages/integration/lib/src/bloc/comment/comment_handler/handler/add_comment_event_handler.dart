part of '../comment_handler_bloc.dart';

/// {@template add_comment_event_handler}
/// [handleAddActionEvent] is used to handle the add comment/reply event
/// [LMCommentActionEvent] is used to send the request to the handler
/// {@endtemplate}
Future<void> handleAddActionEvent(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  // Check if the comment is a parent comment or a reply to a comment
  // and call the respective handler
  if (event.commentMetaData.commentActionEntity == LMCommentType.parent) {
    await _handleAddCommentAction(event, emit);
  } else if (event.commentMetaData.commentActionEntity == LMCommentType.reply) {
    await _handleAddReplyAction(event, emit);
  }
}

// Add comment handler
// This handler is used to add a new comment
// to a post
Future<void> _handleAddCommentAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  LMFeedClient lmFeedClient = LMFeedIntegration.instance.lmFeedClient;

  AddCommentRequest addCommentRequest =
      event.commentActionRequest as AddCommentRequest;

  emit(LMCommentLoadingState(commentMetaData: event.commentMetaData));

  AddCommentResponse? response =
      await lmFeedClient.addComment(addCommentRequest);
  if (!response.success) {
    emit(LMCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    LMAnalyticsBloc.instance.add(FireAnalyticEvent(
      eventName: AnalyticsKeys.commentPosted,
      eventProperties: {
        "post_id": addCommentRequest.postId,
        "comment_id": response.reply?.id,
      },
    ));
    emit(LMCommentSuccessState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  }
}

// Add reply handler
// This handler is used to add a new reply
// to a comment
Future<void> _handleAddReplyAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  LMFeedClient lmFeedClient = LMFeedIntegration.instance.lmFeedClient;

  AddCommentReplyRequest addCommentReplyRequest =
      event.commentActionRequest as AddCommentReplyRequest;

  emit(LMCommentLoadingState(
    commentMetaData: event.commentMetaData,
  ));

  AddCommentReplyResponse response =
      await lmFeedClient.addCommentReply(addCommentReplyRequest);
  if (!response.success) {
    emit(LMCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    LMAnalyticsBloc.instance.add(FireAnalyticEvent(
      eventName: AnalyticsKeys.replyPosted,
      eventProperties: {
        "post_id": addCommentReplyRequest.postId,
        "comment_id": addCommentReplyRequest.commentId,
        "comment_reply_id": response.reply?.id,
        // TODO: Add user details
        // "user_id": event.userId,
      },
    ));
    emit(LMCommentSuccessState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  }
}
