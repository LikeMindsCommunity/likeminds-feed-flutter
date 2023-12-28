part of '../post_bloc.dart';

void togglePinPostEventHandler(
    LMTogglePinPost event, Emitter<LMPostState> emit) async {
  PinPostRequest request =
      (PinPostRequestBuilder()..postId(event.postId)).build();

  PinPostResponse response =
      await LMFeedIntegration.instance.lmFeedClient.pinPost(request);

  if (response.success) {
    toast(event.isPinned ? "Post pinned" : "Post unpinned",
        duration: Toast.LENGTH_LONG);
    emit(LMPostPinnedState(isPinned: event.isPinned, postId: event.postId));
  } else {
    emit(LMPostPinError(
        message: response.errorMessage ?? "An error occurred",
        isPinned: !event.isPinned,
        postId: event.postId));
  }
}
