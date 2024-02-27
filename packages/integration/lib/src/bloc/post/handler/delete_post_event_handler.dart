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
    LMFeedCore.showSnackBar(
      SnackBar(
        content: LMFeedText(
          text: 'Comment Deleted',
        ),
      ),
    );
    // TODO: remove old toast
    // toast(
    //   'Post Deleted',
    //   duration: Toast.LENGTH_LONG,
    // );
    emit(LMFeedPostDeletedState(postId: event.postId));
  } else {
    LMFeedCore.showSnackBar(
      SnackBar(
        content: LMFeedText(text: response.errorMessage ?? "An error occurred"),
      ),
    );
    // TODO: remove old toast
    // toast(
    //   response.errorMessage ?? 'An error occurred',
    //   duration: Toast.LENGTH_LONG,
    // );
    emit(LMFeedPostDeletionErrorState(
        message: response.errorMessage ?? 'An error occurred'));
  }
}
