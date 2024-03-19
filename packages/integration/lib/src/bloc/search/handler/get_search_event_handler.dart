part of '../search_bloc.dart';

Future<void> getSearchEventHandler(
    LMFeedGetSearchEvent event, Emitter<LMFeedSearchState> emit) async {
  if (event.query.isEmpty) return;
  if (event.page > 1) {
    emit(LMFeedSearchPaginationLoadingState());
  } else {
    emit(LMFeedSearchLoadingState());
  }
  try {
    final searchRequest = (SearchPostRequestBuilder()
          ..search(event.query)
          ..searchType(event.type)
          ..page(event.page)
          ..pageSize(event.pageSize))
        .build();

    final searchResponse = await LMFeedCore.client.searchPosts(searchRequest);

    if (searchResponse.success && searchResponse.posts != null) {
      List<LMPostViewData> posts = [];
      for (Post post in searchResponse.posts!) {
        posts.add(LMPostViewDataConvertor.fromPost(
          post: post,
          widgets: searchResponse.widgets,
          users: searchResponse.users ?? {},
          topics: searchResponse.topics,
          repostedPosts: searchResponse.repostedPosts,
          userTopics: searchResponse.userTopics,
        ));
      }
      emit(LMFeedSearchLoadedState(posts: posts));
    } else {
      emit(LMFeedSearchErrorState(
          message: searchResponse.errorMessage ?? 'An error occurred.'));
    }
  } on Exception catch (e, stackTrace) {
    LMFeedLogger.instance.handleException(e, stackTrace);
    emit(LMFeedSearchErrorState(message: e.toString()));
  }
}