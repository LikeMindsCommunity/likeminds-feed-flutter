part of '../post_bloc.dart';

void getPostEventHandler(
    LMFeedGetPostEvent event, Emitter<LMFeedPostState> emit) async {
  emit(LMFeedGetPostLoadingState());

  if (event.postId != null) {
    await getPost(event, emit);
  } else if (event.pendingPostId != null) {
    await getPendingPost(event, emit);
  } else {
    emit(LMFeedPostErrorState(
        errorMessage: "Either post id or pending post id must be call"));
    return;
  }
}

Future<void> getPendingPost(
    LMFeedGetPostEvent event, Emitter<LMFeedPostState> emit) async {
  GetPendingPostRequest pendingPostRequest =
      (GetPendingPostRequestBuilder()..postId(event.pendingPostId!)).build();

  final response = await LMFeedCore.client.getPendingPost(pendingPostRequest);

  if (response.success) {
    GetPendingPostResponse pendingPostResponse =
        response.data as GetPendingPostResponse;

    // convert widgets map to widget view data map
    Map<String, LMWidgetViewData> widgets = pendingPostResponse.widgets!.map(
        (key, value) =>
            MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));
    // convert topic map to topic view data map
    Map<String, LMTopicViewData> topics = pendingPostResponse.topics!.map(
        (key, value) => MapEntry(
            key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

    Map<String, LMUserViewData> users = pendingPostResponse.users!.map(
        (key, value) => MapEntry(
            key,
            LMUserViewDataConvertor.fromUser(value,
                topics: topics,
                widgets: widgets,
                userTopics: pendingPostResponse.userTopics)));

    final Map<String, LMPostViewData>? repostedPosts =
        pendingPostResponse.repostedPosts?.map((key, value) => MapEntry(
            key,
            LMPostViewDataConvertor.fromPost(
              post: value,
              users: users,
              topics: topics,
              widgets: widgets,
              userTopics: pendingPostResponse.userTopics,
            )));

    LMPostViewData postViewData = LMPostViewDataConvertor.fromPost(
        post: pendingPostResponse.post!,
        users: users,
        topics: topics,
        widgets: widgets,
        repostedPosts: repostedPosts);

    emit(LMFeedGetPostSuccessState(
      post: postViewData,
      topics: topics,
      userData: users,
      widgets: widgets,
      repostedPosts: repostedPosts,
    ));
  } else {
    emit(LMFeedPostErrorState(
        errorMessage: response.errorMessage ?? "An error occured"));
  }
}

Future<void> getPost(
    LMFeedGetPostEvent event, Emitter<LMFeedPostState> emit) async {
  PostDetailRequest postDetailRequest = (PostDetailRequestBuilder()
        ..postId(event.postId!)
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

    Map<String, LMUserViewData> users = response.users!.map((key, value) =>
        MapEntry(
            key,
            LMUserViewDataConvertor.fromUser(value,
                topics: topics,
                widgets: widgets,
                userTopics: response.userTopics)));

    final Map<String, LMPostViewData>? repostedPosts =
        response.repostedPosts?.map((key, value) => MapEntry(
            key,
            LMPostViewDataConvertor.fromPost(
              post: value,
              users: users,
              topics: topics,
              widgets: widgets,
              userTopics: response.userTopics,
            )));

    LMPostViewData postViewData = LMPostViewDataConvertor.fromPost(
        post: response.post!,
        users: users,
        topics: topics,
        widgets: widgets,
        repostedPosts: repostedPosts);

    emit(LMFeedGetPostSuccessState(
      post: postViewData,
      topics: topics,
      userData: users,
      widgets: widgets,
      repostedPosts: repostedPosts,
    ));
  } else {
    emit(LMFeedPostErrorState(
        errorMessage: response.errorMessage ?? "An error occured"));
  }
}
