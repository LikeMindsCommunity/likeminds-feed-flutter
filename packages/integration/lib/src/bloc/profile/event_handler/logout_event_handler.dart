part of '../profile_bloc.dart';

void handleLMLogoutEvent(
        LMFeedLogoutEvent event, Emitter<LMFeedProfileState> emit) =>
    emit(LMFeedLogoutState());
