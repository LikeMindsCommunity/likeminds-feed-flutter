part of '../comment_handler_bloc.dart';

/// {@template delete_comment_event_handler}
/// [handleDeleteActionEvent] is used to handle the delete action event
/// for both comment and replies to comments
/// [LMCommentActionEvent] is used to send the request to the handler
/// {@endtemplate}
Future<void> handleDeleteActionEvent(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  await _handleDeleteCommentAction(event, emit);
}

Future<void> _handleDeleteCommentAction(
    LMCommentActionEvent event, Emitter<LMCommentHandlerState> emit) async {
  // Get the instance of the LMFeedClient
  // to make the API call
  LMFeedClient lmFeedClient = LMFeedCore.instance.lmFeedClient;

  // DeleteCommentRequest is the request to be sent to the server
  // to delete a comment
  // It contains the [postId] and [commentId] to be deleted from the post
  DeleteCommentRequest deleteCommentRequest =
      event.commentActionRequest as DeleteCommentRequest;

  try {
    // Notify the UI to change the view to Loading
    emit(LMCommentLoadingState(
      commentMetaData: event.commentMetaData,
    ));

    // Call deleteComment API to delete the comment
    // and wait for the response
    final response = await lmFeedClient.deleteComment(
      deleteCommentRequest,
    );

    // Check if the response is success or not
    if (response.success) {
      // Show the toast message for comment deleted
      toast(
        'Comment Deleted',
        duration: Toast.LENGTH_LONG,
      );

      // Fire the analytic event for comment deleted
      LMAnalyticsBloc.instance.add(LMFireAnalyticsEvent(
        eventName: LMAnalyticsKeys.commentDeleted,
        eventProperties: {
          "post_id": deleteCommentRequest.postId,
          "comment_id": deleteCommentRequest.commentId,
        },
      ));
      // Notify the UI to change the view to Success
      // and remove the comment from the UI
      // and update the comment count
      emit(
        LMCommentSuccessState(
          commentActionResponse: response,
          commentMetaData: event.commentMetaData,
        ),
      );
    } else {
      // Notify the UI to change the view to Error
      // and show the error message
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
