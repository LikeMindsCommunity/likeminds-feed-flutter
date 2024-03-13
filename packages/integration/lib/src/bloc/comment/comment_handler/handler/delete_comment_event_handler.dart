part of '../comment_handler_bloc.dart';

/// {@template delete_comment_event_handler}
/// [handleDeleteActionEvent] is used to handle the delete action event
/// for both comment and replies to comments
/// [LMFeedCommentActionEvent] is used to send the request to the handler
/// {@endtemplate}
Future<void> handleDeleteActionEvent(LMFeedCommentActionEvent event,
    Emitter<LMFeedCommentHandlerState> emit) async {
  await _handleDeleteCommentAction(event, emit);
}

Future<void> _handleDeleteCommentAction(LMFeedCommentActionEvent event,
    Emitter<LMFeedCommentHandlerState> emit) async {
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
    emit(LMFeedCommentLoadingState(
      commentMetaData: event.commentMetaData,
    ));

    // Call deleteComment API to delete the comment
    // and wait for the response
    final response = await lmFeedClient.deleteComment(
      deleteCommentRequest,
    );

    // Check if the response is success or not
    if (response.success) {
      // Notify the UI to change the view to Success
      // and remove the comment from the UI
      // and update the comment count
      emit(
        LMFeedCommentSuccessState(
          commentActionResponse: response,
          commentMetaData: event.commentMetaData,
        ),
      );

      LMFeedAnalyticsBloc.instance.add(
        LMFeedFireAnalyticsEvent(
          eventName: LMFeedAnalyticsKeys.commentDeleted,
          deprecatedEventName: LMFeedAnalyticsKeysDep.commentDeleted,
          eventProperties: {
            "post_id": event.commentMetaData.postId,
            "comment_id": event.commentMetaData.commentId,
            if (event.commentMetaData.commentActionEntity ==
                LMFeedCommentType.reply)
              "comment_reply_id": event.commentMetaData.replyId,
          },
        ),
      );
    } else {
      // Notify the UI to change the view to Error
      // show the error message
      if (response.errorMessage != null) {
        LMFeedCore.showSnackBar(
          LMFeedSnackBar(
            content: LMFeedText(text: response.errorMessage!),
          ),
        );
      }

      emit(LMFeedCommentErrorState(
        commentActionResponse: response,
        commentMetaData: event.commentMetaData,
      ));
    }
  } on Exception catch (err, stacktrace) {
    LMFeedLogger.instance.handleException(err, stacktrace);
  }
}
