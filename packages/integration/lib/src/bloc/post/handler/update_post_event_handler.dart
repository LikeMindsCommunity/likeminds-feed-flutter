part of '../post_bloc.dart';

void updatePostEventHandler(
        LMFeedUpdatePostEvent event, Emitter<LMFeedPostState> emit) =>
    emit(LMFeedPostUpdateState(
      post: event.post,
      commentId: event.commentId,
      actionType: event.actionType,
      postId: event.postId,
      source: event.source,
    ));
