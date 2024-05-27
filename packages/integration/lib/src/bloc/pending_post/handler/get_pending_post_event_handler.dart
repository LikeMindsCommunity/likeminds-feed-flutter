part of '../pending_bloc.dart';

void getPendingPostsEventHandler(
    LMFeedGetPendingPostsEvent event, Emitter<LMFeedPendingState> emit) async {
  emit(LMFeedPendingPostsLoadingState());

  GetAllPendingPostsRequest request = (GetAllPendingPostsRequestBuilder()
        ..page(event.page)
        ..uuid(event.uuid)
        ..pageSize(event.pageSize))
      .build();

  LMResponse response = await LMFeedCore.client.getAllPendingPosts(request);

  if (!response.success) {
    emit(LMFeedPendingPostsErrorState(
        errorMessage: response.errorMessage ?? 'An error occurred'));
  } else {
    GetAllPendingPostsResponse pendingPostsResponse =
        response.data as GetAllPendingPostsResponse;

    Map<String, LMWidgetViewData> widgets = pendingPostsResponse.widgets.map(
        (key, value) =>
            MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));

    Map<String, LMTopicViewData> topics = pendingPostsResponse.topics.map(
        (key, value) => MapEntry(
            key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

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

    emit(
      LMFeedPendingPostsLoadedState(
        posts: posts,
        totalCount: pendingPostsResponse.totalCount,
        page: event.page,
      ),
    );
  }
}
