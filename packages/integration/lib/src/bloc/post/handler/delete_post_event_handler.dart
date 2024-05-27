part of '../post_bloc.dart';

void deletePostEventHandler(
    LMFeedDeletePostEvent event, Emitter<LMFeedPostState> emit) async {
  if (event.postId != null) {
    await deletePost(event, emit);
  } else if (event.pendingPostId != null) {
    await deletePendingPost(event, emit);
  } else {
    emit(LMFeedPostDeletionErrorState(
        message: 'Either post id or pending post id must be provided'));
  }
}

Future<void> deletePost(
    LMFeedDeletePostEvent event, Emitter<LMFeedPostState> emit) async {
  String postId = event.postId!;

  final response = await LMFeedCore.instance.lmFeedClient.deletePost(
    (DeletePostRequestBuilder()
          ..postId(postId)
          ..deleteReason(event.reason)
          ..isRepost(event.isRepost))
        .build(),
  );

  if (response.success) {
    emit(LMFeedPostDeletedState(postId: postId));

    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.postDeleted,
        eventProperties: {
          "post_id": postId,
          "post_type": event.postType,
          "user_id": event.userId,
          "user_state": event.userState,
        }));
  } else {
    emit(LMFeedPostDeletionErrorState(
        message: response.errorMessage ?? 'An error occurred'));
  }
}

Future<void> deletePendingPost(
    LMFeedDeletePostEvent event, Emitter<LMFeedPostState> emit) async {
  String pendingPostId = event.pendingPostId!;

  final response = await LMFeedCore.instance.lmFeedClient.deletePendingPost(
    (DeletePendingPostRequestBuilder()
          ..postId(pendingPostId)
          ..deleteReason(event.reason)
          ..isRepost(event.isRepost))
        .build(),
  );

  if (response.success) {
    emit(LMFeedPostDeletedState(pendingPostId: pendingPostId));

    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.postDeleted,
        eventProperties: {
          "post_id": pendingPostId,
          "post_type": event.postType,
          "user_id": event.userId,
          "user_state": event.userState,
        }));
  } else {
    emit(LMFeedPostDeletionErrorState(
        message: response.errorMessage ?? 'An error occurred'));
  }
}
