import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/persistence/user_local_preference.dart';

part 'saved_post_event.dart';
part 'saved_post_state.dart';

class LMFeedSavedPostBloc extends Bloc<LMFeedSavedPostEvent, LMFeedSavedPostState> {
  LMFeedSavedPostBloc() : super(LMFeedSavedPostInitialState()) {
    on<LMFeedGetSavedPostEvent>(_mapGetSavedPostToState);
  }

  _mapGetSavedPostToState(LMFeedGetSavedPostEvent event, emit) async {
    emit(LMFeedSavedPostLoadingState());
    if (event.page > 1) {
      emit(LMFeedSavedPostPaginationLoadingState());
    } else {
      emit(LMFeedSavedPostLoadingState());
    }

    try {
      final user = LMFeedUserLocalPreference.instance.fetchUserData();
      final savePostResponse = await LMFeedCore.client.getSavedPost(
        (GetSavedPostRequestBuilder()
              ..uuid(user.userUniqueId)
              ..page(event.page)
              ..pageSize(event.pageSize))
            .build(),
      );
      debugPrint(user.userUniqueId);
      if (savePostResponse.success) {
        List<LMPostViewData> savedPost = [];
        savePostResponse.posts?.forEach((post) {
          savedPost.add(LMPostViewDataConvertor.fromPost(
            post: post,
            widgets: savePostResponse.widgets,
            repostedPosts: savePostResponse.repostedPosts,
            users: savePostResponse.users,
            topics: savePostResponse.topics,
          ));
        });
        emit(
          LMFeedSavedPostLoadedState(posts: savedPost),
        );
      } else {
        emit(
          LMFeedSavedPostErrorState(
              errorMessage: savePostResponse.errorMessage ??
                  "An error occurred, Please try again"),
        );
      }
    } catch (e) {
      emit(LMFeedSavedPostErrorState(errorMessage: e.toString()));
    }
  }
}
