part of '../comment_handler_bloc.dart';

void handleAddActionEvent(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) {
  if (event.commentMetaData.commentActionEntity == LMCommentType.parent) {
    _handleAddCommentAction(event, emit);
  } else if (event.commentMetaData.commentActionEntity == LMCommentType.reply) {
    _handleAddReplyAction(event, emit);
  }
}

void _handleAddCommentAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  AddCommentRequest addCommentRequest =
      event.commentActionRequest as AddCommentRequest;

  emit(LMCommentLoadingState(commentMetaData: event.commentMetaData));

  AddCommentResponse? response = await LMCommentHandlerBloc
      .lmFeedBloc.lmFeedClient
      .addComment(addCommentRequest);
  if (!response.success) {
    emit(LMCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    LMCommentHandlerBloc.lmFeedBloc.lmAnalyticsBloc.add(FireAnalyticEvent(
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

void _handleAddReplyAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  AddCommentReplyRequest addCommentReplyRequest =
      event.commentActionRequest as AddCommentReplyRequest;

  emit(LMCommentLoadingState(
    commentMetaData: event.commentMetaData,
  ));

  AddCommentReplyResponse response = await LMCommentHandlerBloc
      .lmFeedBloc.lmFeedClient
      .addCommentReply(addCommentReplyRequest);
  if (!response.success) {
    emit(LMCommentErrorState(
      commentActionResponse: response,
      commentMetaData: event.commentMetaData,
    ));
  } else {
    LMCommentHandlerBloc.lmFeedBloc.lmAnalyticsBloc.add(FireAnalyticEvent(
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
