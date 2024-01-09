part of '../post_bloc.dart';

void deletePostEventHandler(
    LMFeedDeletePostEvent event, Emitter<LMFeedPostState> emit) async {
  final response = await LMFeedCore.instance.lmFeedClient.deletePost(
    (DeletePostRequestBuilder()
          ..postId(event.postId)
          ..deleteReason(event.reason))
        .build(),
  );

  if (response.success) {
    toast(
      'Post Deleted',
      duration: Toast.LENGTH_LONG,
    );
    emit(LMFeedPostDeletedState(postId: event.postId));
  } else {
    toast(
      response.errorMessage ?? 'An error occurred',
      duration: Toast.LENGTH_LONG,
    );
    emit(LMFeedPostDeletionErrorState(
        message: response.errorMessage ?? 'An error occurred'));
  }
}
