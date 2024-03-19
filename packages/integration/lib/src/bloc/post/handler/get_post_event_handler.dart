part of '../post_bloc.dart';

void getPostEventHandler(
    LMFeedGetPostEvent event, Emitter<LMFeedPostState> emit) async {
  PostDetailRequest postDetailRequest = (PostDetailRequestBuilder()
        ..postId(event.postId)
        ..page(event.page)
        ..pageSize(event.pageSize))
      .build();

  final response = await LMFeedCore.client.getPostDetails(postDetailRequest);

  if (response.success) {
    // convert widgets map to widget view data map
    Map<String, LMWidgetViewData> widgets = response.widgets!.map(
        (key, value) =>
            MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));
    // convert topic map to topic view data map
    Map<String, LMTopicViewData> topics = response.topics!.map((key, value) =>
        MapEntry(
            key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

    Map<String, LMUserViewData> userData = response.users!.map((key, value) =>
        MapEntry(
            key,
            LMUserViewDataConvertor.fromUser(value,
                topics: response.topics, widgets: response.widgets)));

    final Map<String, LMPostViewData>? repostedPosts =
        response.repostedPosts?.map((key, value) => MapEntry(
            key,
            LMPostViewDataConvertor.fromPost(
              post: value,
              users: response.users!,
              topics: response.topics,
              widgets: response.widgets,
            )));

    LMPostViewData postViewData = LMPostViewDataConvertor.fromPost(
      post: response.post!,
      users: response.users!,
      topics: response.topics,
      widgets: response.widgets,
      repostedPosts: response.repostedPosts,
    );

    emit(LMFeedGetPostSuccessState(
      post: postViewData,
      topics: topics,
      userData: userData,
      widgets: widgets,
      repostedPosts: repostedPosts,
    ));
  } else {
    emit(LMFeedPostErrorState(
        errorMessage: response.errorMessage ?? "An error occured"));
  }
}
