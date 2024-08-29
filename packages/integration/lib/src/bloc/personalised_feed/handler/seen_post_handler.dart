part of '../personalised_feed_bloc.dart';

// Handler for marking post as seen
Future<void> _seenPostHandler(
  LMFeedPersonalisedSeenPostEvent event,
  Emitter<LMFeedPersonalisedState> emit,
) async {
  // if seen post is empty return
  if (event.seenPost.isEmpty) {
    return;
  }
  // create post seen request builder
  final PostSeenRequestBuilder postSeenRequestBuilder = PostSeenRequestBuilder()
    ..seenPostIDs(event.seenPost);
  // post seen api call
  final LMResponse<void> response = await LMFeedCore.instance.lmFeedClient
      .postSeen(postSeenRequestBuilder.build());
  if (response.success) {
    // clear seen post list from bloc and persistence
    LMFeedPersonalisedBloc.instance.seenPost.clear();
    await LMFeedPersistence.instance.clearSeenPostIDs();
    emit(LMFeedPersonalisedSeenPostSuccessState());
  } else {
    emit(LMFeedPersonalisedErrorState(
        message: response.errorMessage ??
            "An error occurred, please check your network connection"));
  }
}
