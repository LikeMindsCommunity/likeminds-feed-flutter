part of '../profile_bloc.dart';

void handleLMRouteToUserProfileEvent(
    LMFeedRouteToUserProfileEvent event, Emitter<LMFeedProfileState> emit) {
  debugPrint("LM User ID caught in callback : ${event.userUniqueId}");
  emit(LMFeedRouteToUserProfileState(userUniqueId: event.userUniqueId, context: event.context));
}
