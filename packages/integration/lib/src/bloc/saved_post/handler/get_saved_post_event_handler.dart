part of '../saved_post_bloc.dart';

getSavedPostEventHandler(LMFeedGetSavedPostEvent event, emit) async {
  try {
    emit(LMFeedSavedPostLoadingState());
    final user = LMFeedLocalPreference.instance.fetchUserData();
    final savePostResponse = await LMFeedCore.client.getSavedPost(
      (GetSavedPostRequestBuilder()
            ..uuid(user?.uuid ?? "")
            ..page(event.page)
            ..pageSize(event.pageSize))
          .build(),
    );
    debugPrint(user?.uuid);
    if (savePostResponse.success) {
      List<LMPostViewData> savedPost = [];
      savePostResponse.posts?.forEach((post) {
        savedPost.add(LMPostViewDataConvertor.fromPost(
          post: post,
          widgets: savePostResponse.widgets,
          repostedPosts: savePostResponse.repostedPosts,
          users: savePostResponse.users ?? {},
          topics: savePostResponse.topics,
          filteredComments: savePostResponse.filteredComments,
          userTopics: savePostResponse.userTopics,
        ));
      });
      emit(
        LMFeedSavedPostLoadedState(posts: savedPost, page: event.page),
      );
    } else {
      emit(
        LMFeedSavedPostErrorState(
            errorMessage: savePostResponse.errorMessage ??
                "An error occurred, Please try again",
            stackTrace: StackTrace.current
                ),
                
      );
    }
  } on Exception catch (e, stackTrace) {
    emit(LMFeedSavedPostErrorState(errorMessage: e.toString(), stackTrace: stackTrace));
  }
}
