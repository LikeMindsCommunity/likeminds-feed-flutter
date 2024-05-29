part of '../pending_bloc.dart';

// Event handler for getting pending posts
void getPendingPostsEventHandler(
    LMFeedGetPendingPostsEvent event, Emitter<LMFeedPendingState> emit) async {
  emit(LMFeedPendingPostsLoadingState()); // Emit loading state

  // Build the request object
  GetAllPendingPostsRequest request = (GetAllPendingPostsRequestBuilder()
        ..page(event.page)
        ..uuid(event.uuid)
        ..pageSize(event.pageSize))
      .build();

  // Make the API call to get all pending posts
  LMResponse response = await LMFeedCore.client.getAllPendingPosts(request);

  if (!response.success) {
    // If the API call fails, emit error state with error message
    emit(LMFeedPendingPostsErrorState(
        errorMessage: response.errorMessage ?? 'An error occurred'));
  } else {
    // If the API call is successful, process the response data
    GetAllPendingPostsResponse pendingPostsResponse =
        response.data as GetAllPendingPostsResponse;
    // Convert widget models to view data
    Map<String, LMWidgetViewData> widgets = pendingPostsResponse.widgets.map(
        (key, value) =>
            MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));

    // Convert topics to view data, using the converted widgets
    Map<String, LMTopicViewData> topics = pendingPostsResponse.topics.map(
        (key, value) => MapEntry(
            key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

    // Convert users to view data, using the converted topics and widgets
    Map<String, LMUserViewData> users = pendingPostsResponse.users.map(
      (key, value) => MapEntry(
        key,
        LMUserViewDataConvertor.fromUser(
          value,
          topics: topics,
          widgets: widgets,
          userTopics: pendingPostsResponse.userTopics,
        ),
      ),
    );

    // Convert filtered comments to view data, using the converted users
    Map<String, LMCommentViewData> filteredComments =
        pendingPostsResponse.filteredComments.map(
      (key, value) => MapEntry(
        key,
        LMCommentViewDataConvertor.fromComment(
          value,
          users,
        ),
      ),
    );

    // Convert reposted posts to view data, using the converted users, topics, widgets, and filtered comments
    Map<String, LMPostViewData> repostedPosts =
        pendingPostsResponse.repostedPosts.map(
      (key, value) => MapEntry(
        key,
        LMPostViewDataConvertor.fromPost(
          post: value,
          users: users,
          topics: topics,
          widgets: widgets,
          userTopics: pendingPostsResponse.userTopics,
          filteredComments: filteredComments,
        ),
      ),
    );

    // Convert posts to view data, using the converted users, topics, widgets, filtered comments, and reposted posts
    List<LMPostViewData> posts = pendingPostsResponse.posts
        .map(
          (e) => LMPostViewDataConvertor.fromPost(
            post: e,
            users: users,
            topics: topics,
            widgets: widgets,
            userTopics: pendingPostsResponse.userTopics,
            filteredComments: filteredComments,
            repostedPosts: repostedPosts,
          ),
        )
        .toList();

    // Emit loaded state with the converted posts and other relevant data
    emit(
      LMFeedPendingPostsLoadedState(
        posts: posts,
        totalCount: pendingPostsResponse.totalCount,
        page: event.page,
      ),
    );
  }
}
