part of '../post_bloc.dart';

togglePinPostEventHandler(
    TogglePinPost event, Emitter<LMPostState> emit) async {
  PinPostRequest request =
      (PinPostRequestBuilder()..postId(event.postId)).build();

  PinPostResponse response =
      await LMFeedBloc.get().lmFeedClient.pinPost(request);

  if (response.success) {
    emit(PostPinnedState(isPinned: event.isPinned, postId: event.postId));
  } else {
    emit(PostPinError(
        message: response.errorMessage ?? "An error occurred",
        isPinned: !event.isPinned,
        postId: event.postId));
  }
}
