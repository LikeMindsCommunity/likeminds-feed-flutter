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
      Map<String, LMWidgetViewData> widgets = (searchResponse.widgets ??
              <String, WidgetModel>{})
          .map((key, value) =>
              MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));

      Map<String, LMTopicViewData> topics =
          (searchResponse.topics ?? <String, Topic>{}).map((key, value) =>
              MapEntry(key,
                  LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

      Map<String, LMUserViewData> users =
          (searchResponse.users ?? <String, User>{})
              .map((key, value) => MapEntry(
                  key,
                  LMUserViewDataConvertor.fromUser(
                    value,
                    topics: topics,
                    userTopics: searchResponse.userTopics,
                    widgets: widgets,
                  )));

      Map<String, LMPostViewData> respostedPost =
          searchResponse.repostedPosts?.map((key, value) => MapEntry(
                  key,
                  LMPostViewDataConvertor.fromPost(
                    post: value,
                    users: users,
                    topics: topics,
                    widgets: widgets,
                  ))) ??
              {};

      List<LMPostViewData> posts = [];
      for (Post post in searchResponse.posts!) {
        posts.add(LMPostViewDataConvertor.fromPost(
          post: post,
          users: users,
          topics: topics,
          widgets: widgets,
          repostedPosts: respostedPost,
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
