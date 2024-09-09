part of '../personalised_feed_bloc.dart';

/// Handler for getting personalised feed
Future<void> _getPersonalisedFeedHandler(
  LMFeedPersonalisedGetEvent event,
  Emitter<LMFeedPersonalisedState> emit,
) async {
  // variables to store users, topics and widgets
  Map<String, LMUserViewData> users = {};
  Map<String, LMTopicViewData> topics = {};
  Map<String, LMWidgetViewData> widgets = {};

  emit(LMFeedPersonalisedFeedLoadingState());
  // create request builder
  final GetPersonalisedFeedRequestBuilder requestBuilder =
      GetPersonalisedFeedRequestBuilder()
        ..page(event.pageKey)
        ..pageSize(event.pageSize);
  // if page is 1 then recompute and reorder the feed
  if (event.pageKey == 1) {
    requestBuilder
      ..shouldRecompute(true)
      ..shouldReorder(true);
  }

  // get personalised feed
  LMResponse<GetPersonalisedFeedResponse> response =
      await LMFeedCore.instance.lmFeedClient.getPersonalisedFeed(
    requestBuilder.build(),
  );

  if (!response.success || response.data == null) {
    emit(LMFeedPersonalisedErrorState(
        message: response.errorMessage ??
            "An error occurred, please check your network connection"));
  } else {
    // convert the response to view data models
    final GetPersonalisedFeedResponse personalisedFeedResponse = response.data!;
    widgets.addAll(personalisedFeedResponse.widgets.map((key, value) =>
        MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value))));

    topics.addAll(personalisedFeedResponse.topics.map((key, value) => MapEntry(
        key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets))));

    users.addAll(personalisedFeedResponse.users.map((key, value) => MapEntry(
          key,
          LMUserViewDataConvertor.fromUser(value,
              topics: topics,
              userTopics: personalisedFeedResponse.userTopics,
              widgets: widgets),
        )));

    Map<String, LMCommentViewData> filteredComments =
        personalisedFeedResponse.filteredComments.map((key, value) => MapEntry(
            key, LMCommentViewDataConvertor.fromComment(value, users)));

    Map<String, LMPostViewData> repostedPosts =
        personalisedFeedResponse.repostedPosts.map((key, value) => MapEntry(
            key,
            LMPostViewDataConvertor.fromPost(
                post: value,
                users: users,
                topics: topics,
                widgets: widgets,
                filteredComments: filteredComments,
                userTopics: personalisedFeedResponse.userTopics)));

    // emit the loaded state with the posts
    emit(
      LMFeedPersonalisedFeedLoadedState(
        pageKey: event.pageKey,
        posts: personalisedFeedResponse.posts
            .map((e) => LMPostViewDataConvertor.fromPost(
                  post: e,
                  widgets: widgets,
                  repostedPosts: repostedPosts,
                  users: users,
                  topics: topics,
                  filteredComments: filteredComments,
                  userTopics: personalisedFeedResponse.userTopics,
                ))
            .toList(),
      ),
    );
  }
}
