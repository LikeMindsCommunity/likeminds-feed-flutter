part of '../profile_bloc.dart';

void handleLMRouteToUserProfileEvent(
    LMRouteToUserProfile event, Emitter<LMProfileState> emit) {
  debugPrint("LM User ID caught in callback : ${event.userUniqueId}");
  emit(LMRouteToUserProfileState(userUniqueId: event.userUniqueId));
}
