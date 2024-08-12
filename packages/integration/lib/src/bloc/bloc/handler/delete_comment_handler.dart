part of '../lm_comment_bloc.dart';

FutureOr<void> _deleteCommentHandler(LMDeleteComment event, emit) async {
  emit(LMDeleteCommentLoading());
  // create delete comment request
  DeleteCommentRequest deleteCommentRequest = (DeleteCommentRequestBuilder()
        ..postId(event.postId)
        ..commentId(event.commentId)
        ..reason(event.reason))
      .build();

  final DeleteCommentResponse response =
      await LMFeedCore.client.deleteComment(deleteCommentRequest);

  if (response.success) {
    emit(LMDeleteCommentSuccess(
      commentId: event.commentId,
    ));
  } else {
    emit(LMDeleteCommentError(
        error: response.errorMessage ?? "An error occurred"));
  }
}
