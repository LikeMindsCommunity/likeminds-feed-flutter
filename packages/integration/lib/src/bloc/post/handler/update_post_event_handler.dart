part of '../post_bloc.dart';

void updatePostEventHandler(LMUpdatePost event, Emitter<LMPostState> emit) =>
    emit(LMPostUpdateState(post: event.post));
