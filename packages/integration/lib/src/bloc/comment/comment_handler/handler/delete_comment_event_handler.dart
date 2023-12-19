part of '../comment_handler_bloc.dart';

void handleDeleteActionEvent(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) {
  _handleDeleteCommentAction(event, emit);
}

void _handleDeleteCommentAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  DeleteCommentRequest deleteCommentRequest =
      event.commentActionRequest as DeleteCommentRequest;

  try {
    emit(LMCommentLoadingState(
      commentMetaData: event.commentMetaData,
    ));

    final response =
        await LMCommentHandlerBloc.lmFeedBloc.lmFeedClient.deleteComment(
      deleteCommentRequest,
    );

    if (response.success) {
      toast(
        'Comment Deleted',
        duration: Toast.LENGTH_LONG,
      );

      LMCommentHandlerBloc.lmFeedBloc.lmAnalyticsBloc.add(FireAnalyticEvent(
        eventName: AnalyticsKeys.LMCommentDeletedState,
        eventProperties: {
          "post_id": deleteCommentRequest.postId,
          "comment_id": deleteCommentRequest.commentId,
        },
      ));
      emit(
        LMCommentSuccessState(
          commentActionResponse: response,
          commentMetaData: event.commentMetaData,
        ),
      );
    } else {
      toast(
        response.errorMessage ?? '',
        duration: Toast.LENGTH_LONG,
      );
      emit(LMCommentErrorState(
        commentActionResponse: response,
        commentMetaData: event.commentMetaData,
      ));
    }
  } catch (err) {
    toast(
      'An error occcurred while deleting comment',
      duration: Toast.LENGTH_LONG,
    );
  }
}
