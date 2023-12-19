part of '../post_bloc.dart';

void togglePinPostEventHandler(
    TogglePinPost event, Emitter<LMPostState> emit) async {
  PinPostRequest request =
      (PinPostRequestBuilder()..postId(event.postId)).build();

  PinPostResponse response =
      await LMFeedBloc.get().lmFeedClient.pinPost(request);

  if (response.success) {
    toast(event.isPinned ? "Post pinned" : "Post unpinned",
        duration: Toast.LENGTH_LONG);
    emit(PostPinnedState(isPinned: event.isPinned, postId: event.postId));
  } else {
    emit(PostPinError(
        message: response.errorMessage ?? "An error occurred",
        isPinned: !event.isPinned,
        postId: event.postId));
  }
}
