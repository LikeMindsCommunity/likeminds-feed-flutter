part of '../profile_bloc.dart';

void handleLMLogoutEvent(LMLogout event, Emitter<LMProfileState> emit) =>
    emit(LMLogoutState());
