part of '../post_bloc.dart';

void updatePostEventHandler(UpdatePost event, Emitter<LMPostState> emit) =>
    emit(PostUpdateState(post: event.post));
