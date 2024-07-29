part of "../post_bloc.dart";

void initialEventHandler(
    LMFeedPostInitiateEvent event, Emitter<LMFeedPostState> emit) {
  emit(LMFeedNewPostInitiateState());
}
