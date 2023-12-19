part of '../post_bloc.dart';

void deletePostEventHandler(DeletePost event, Emitter<LMPostState> emit) async {
  final response = await LMFeedBloc.get().lmFeedClient.deletePost(
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
    emit(PostDeleted(postId: event.postId));
  } else {
    toast(
      response.errorMessage ?? 'An error occurred',
      duration: Toast.LENGTH_LONG,
    );
    emit(PostDeletionError(
        message: response.errorMessage ?? 'An error occurred'));
  }
}
