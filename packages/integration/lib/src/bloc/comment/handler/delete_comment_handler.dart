part of '../comment_bloc.dart';

/// Handles [LMFeedDeleteCommentEvent] event.
/// Deletes a comment from the post.
/// Emits [LMFeedDeleteCommentSuccessState] if the comment is deleted successfully.
Future<void> _deleteCommentHandler(LMFeedDeleteCommentEvent event, emit) async {
  // emit success state to remove the comment from the state locally
  emit(LMFeedDeleteCommentSuccessState(
    commentId: event.oldComment.id,
  ));
  // create delete comment request
  DeleteCommentRequest deleteCommentRequest = (DeleteCommentRequestBuilder()
        ..postId(event.postId)
        ..commentId(event.oldComment.id)
        ..reason(event.reason))
      .build();

  final DeleteCommentResponse response =
      await LMFeedCore.client.deleteComment(deleteCommentRequest);

  // emit error state if the delete request fails and revert the state
  if (!response.success) {
    emit(
      LMFeedDeleteCommentErrorState(
        error: response.errorMessage ?? 'Failed to delete comment',
        oldComment: event.oldComment,
        index: event.index,
      ),
    );
  }
  // Fire analytics event
  LMFeedAnalyticsBloc.instance.add(
    LMFeedFireAnalyticsEvent(
      eventName: LMFeedAnalyticsKeys.commentDeleted,
      widgetSource: LMFeedWidgetSource.postDetailScreen,
      eventProperties: {
        "post_id": event.postId,
        "comment_id": event.oldComment.id,
      },
    ),
  );
}
