part of '../comment_bloc.dart';

Future<void> _getCommentHandler(LMFeedGetCommentsEvent event, emit) async {
  if (event.page == 1) {
    emit(LMFeedGetCommentLoadingState());
  } else {
    emit(LMFeedGetCommentPaginationLoadingState());
  }
  final (post, comments) = await fetchCommentListWithPage(
    event.page,
    event.postId,
    event.pageSize,
  );
  if (post != null && comments != null) {
    emit(LMFeedGetCommentSuccessState(post: post, comments: comments, page: event.page));
  } else {
    emit(LMFeedGetCommentErrorState(error: 'Failed to fetch comments'));
  }
}

Future<(LMPostViewData?, List<LMCommentViewData>?)> fetchCommentListWithPage(
    int page, String postId, int commentListPageSize) async {
  PostDetailRequest postDetailRequest = (PostDetailRequestBuilder()
        ..postId(postId)
        ..pageSize(commentListPageSize)
        ..page(page))
      .build();

  final PostDetailResponse response =
      await LMFeedCore.client.getPostDetails(postDetailRequest);

  if (response.success) {
    final Map<String, LMTopicViewData> topics = {};
    final Map<String, LMPostViewData> repostedPosts = {};
    final Map<String, LMWidgetViewData> widgets = {};
    final Map<String, List<String>> userTopics = {};
    final Map<String, LMUserViewData> users = {};
    // Convert [WidgetModel] to [LMWidgetViewData]
    // Add widgets to the map
    widgets.addAll(response.widgets?.map((key, value) =>
            MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
        {});

    // Convert [Topic] to [LMTopicViewData]
    // Add topics to the map
    topics.addAll(response.topics!.map((key, value) => MapEntry(
        key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets))));

    userTopics.addAll(response.userTopics!);

    // Convert [User] to [LMUserViewData]
    // Add users to the map
    users.addAll(
      response.users!.map(
        (key, value) => MapEntry(
          key,
          LMUserViewDataConvertor.fromUser(
            value,
            topics: topics,
            widgets: widgets,
            userTopics: userTopics,
          ),
        ),
      ),
    );

    // Convert [Post] to [LMPostViewData]
    // Add reposted posts to the map
    repostedPosts.addAll(response.repostedPosts?.map((key, value) => MapEntry(
            key,
            LMPostViewDataConvertor.fromPost(
              post: value,
              widgets: widgets,
              repostedPosts: repostedPosts,
              users: users,
              topics: topics,
              userTopics: userTopics,
            ))) ??
        {});

    // Convert [Post] to [LMPostViewData]
    // Add post data, and all supporting data to the map
    final LMPostViewData postViewData = LMPostViewDataConvertor.fromPost(
      post: response.post!,
      widgets: widgets,
      repostedPosts: repostedPosts,
      users: users,
      topics: topics,
      userTopics: userTopics,
    );

    final List<LMCommentViewData> commentList = postViewData.replies;

    return (postViewData, commentList);
  } else {
    return (null, null);
  }
}
