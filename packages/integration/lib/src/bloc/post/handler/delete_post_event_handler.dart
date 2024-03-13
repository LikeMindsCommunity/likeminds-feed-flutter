part of '../post_bloc.dart';

void deletePostEventHandler(
    LMFeedDeletePostEvent event, Emitter<LMFeedPostState> emit) async {
  final response = await LMFeedCore.instance.lmFeedClient.deletePost(
    (DeletePostRequestBuilder()
          ..postId(event.postId)
          ..deleteReason(event.reason)
          ..isRepost(event.isRepost))
        .build(),
  );

  if (response.success) {
    emit(LMFeedPostDeletedState(postId: event.postId));
  } else {
    emit(LMFeedPostDeletionErrorState(
        message: response.errorMessage ?? 'An error occurred'));
  }
}
