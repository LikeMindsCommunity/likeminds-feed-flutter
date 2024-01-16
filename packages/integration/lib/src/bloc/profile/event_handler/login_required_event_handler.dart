part of '../profile_bloc.dart';

void handleLMLoginRequiredEvent(
        LMFeedLoginRequiredEvent event, Emitter<LMFeedProfileState> emit) =>
    emit(LMFeedLoginRequiredState());
