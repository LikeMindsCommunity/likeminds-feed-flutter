part of "../comment_bloc.dart";

/// Handles [LMFeedDeleteReplyEvent] event.
/// Deletes a reply from the post.
/// Emits [LMFeedDeleteReplySuccessState] if the reply is deleted successfully.
/// Emits [LMFeedDeleteReplyErrorState] if the reply is not deleted successfully.
Future<void> _deleteReplyHandler(LMDeleteReplyEvent event, emit) async {
  // emit success state to remove the reply from the state locally
  emit(LMFeedDeleteReplySuccessState(
    commentId: event.commentId,
    replyId: event.oldReply.id,
  ));
  // create delete comment request
  DeleteCommentRequest deleteCommentRequest = (DeleteCommentRequestBuilder()
        ..postId(event.postId)
        ..commentId(event.oldReply.id)
        ..reason(event.reason))
      .build();
  final DeleteCommentResponse response =
      await LMFeedCore.client.deleteComment(deleteCommentRequest);
  // emit error state if the delete request fails
  if (!response.success) {
    emit(
      LMFeedDeleteReplyErrorState(
        error: response.errorMessage ?? 'Failed to delete reply',
        oldReply: event.oldReply,
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
        "comment_id": event.commentId,
        "comment_reply_id": event.oldReply.id,
      },
    ),
  );
}
