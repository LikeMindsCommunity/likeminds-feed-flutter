part of '../post_bloc.dart';

void togglePinPostEventHandler(
    LMFeedTogglePinPostEvent event, Emitter<LMFeedPostState> emit) async {
  PinPostRequest request =
      (PinPostRequestBuilder()..postId(event.postId)).build();

  PinPostResponse response =
      await LMFeedCore.instance.lmFeedClient.pinPost(request);

  if (response.success) {
    toast(event.isPinned ? "Post pinned" : "Post unpinned",
        duration: Toast.LENGTH_LONG);
    emit(LMFeedPostPinnedState(isPinned: event.isPinned, postId: event.postId));
  } else {
    emit(LMFeedPostPinErrorState(
        message: response.errorMessage ?? "An error occurred",
        isPinned: !event.isPinned,
        postId: event.postId));
  }
}
