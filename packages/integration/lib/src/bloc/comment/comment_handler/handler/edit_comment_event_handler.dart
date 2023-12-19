part of '../comment_handler_bloc.dart';

void handleEditActionEvent(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) {
  // Notify the UI to change the view to Editing
  emit(LMCommentActionOngoingState(commentMetaData: event.commentMetaData));

  // Check if the comment is a parent comment or a reply to a comment
  if (event.commentMetaData.commentActionEntity == LMCommentType.parent) {
    _handleEditCommentAction(event, emit);
  } else if (event.commentMetaData.commentActionEntity == LMCommentType.reply) {
    _handleEditReplyAction(event, emit);
  }
}

void _handleEditCommentAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  EditCommentRequest editCommentRequest =
      event.commentActionRequest as EditCommentRequest;

  EditCommentResponse response = await LMCommentHandlerBloc
      .lmFeedBloc.lmFeedClient
      .editComment(editCommentRequest);

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

void _handleEditReplyAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  EditCommentReplyRequest editCommentReplyRequest =
      event.commentActionRequest as EditCommentReplyRequest;

  EditCommentReplyResponse response = await LMCommentHandlerBloc
      .lmFeedBloc.lmFeedClient
      .editCommentReply(editCommentReplyRequest);

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
