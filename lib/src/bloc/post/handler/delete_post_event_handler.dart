part of '../post_bloc.dart';

deletePostEventHandler(DeletePost event, Emitter<LMPostState> emit) async {
  final response = await LMFeedBloc.get().lmFeedClient.deletePost(
        (DeletePostRequestBuilder()
              ..postId(event.postId)
              ..deleteReason(event.reason))
            .build(),
      );

  if (response.success) {
    emit(PostDeleted(postId: event.postId));
  } else {
    emit(PostDeletionError(
        message: response.errorMessage ?? 'An error occurred'));
  }
}
