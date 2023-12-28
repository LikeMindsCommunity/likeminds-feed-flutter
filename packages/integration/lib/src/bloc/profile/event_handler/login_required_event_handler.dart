part of '../profile_bloc.dart';

void handleLMLoginRequiredEvent(
        LMLoginRequired event, Emitter<LMProfileState> emit) =>
    emit(LMLoginRequiredState());
