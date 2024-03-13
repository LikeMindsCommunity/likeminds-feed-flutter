part of '../post_bloc.dart';

void updatePostEventHandler(
        LMFeedUpdatePostEvent event, Emitter<LMFeedPostState> emit) =>
    emit(LMFeedPostUpdateState(
        post: event.post, actionType: event.actionType, postId: event.postId));
