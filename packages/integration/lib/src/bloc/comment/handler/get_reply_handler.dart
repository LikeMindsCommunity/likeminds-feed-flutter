part of '../comment_bloc.dart';

/// Handles [LMFeedGetReplyEvent] event.
/// Fetches replies for a comment on the post.
/// Emits [LMFeedGetReplyCommentSuccessState] if the replies are fetched successfully.
/// Emits [LMFeedGetReplyCommentErrorState] if the replies are not fetched successfully.
Future<void> _getReplyHandler(LMFeedGetReplyEvent event, emit) async {
  // emit loading state to show loading indicator
  if (event.page == 1) {
    emit(LMFeedGetReplyCommentLoadingState(
      commentId: event.commentId,
    ));
  } else {
    emit(LMFeedGetReplyCommentPaginationLoadingState(
      commentId: event.commentId,
    ));
  }
  // create get comment request
  final GetCommentRequest request = (GetCommentRequestBuilder()
        ..commentId(event.commentId)
        ..postId(event.postId)
        ..page(event.page)
        ..pageSize(10))
      .build();
// make API call to get replies for the comment
  GetCommentResponse response = await LMFeedCore.client.getComment(request);
  if (response.success) {
    // parse the response and update the state
    final Map<String, LMTopicViewData> topics = {};
    final Map<String, LMWidgetViewData> widgets = {};
    final Map<String, LMUserViewData> users = {};

    widgets.addAll((response.widgets ?? {})
        .map((key, value) =>
            MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)))
        .cast<String, LMWidgetViewData>());

    topics.addAll((response.topics ?? {})
        .map((key, value) => MapEntry(
            key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)))
        .cast<String, LMTopicViewData>());

    users.addAll(response.users?.map((key, value) => MapEntry(
            key,
            LMUserViewDataConvertor.fromUser(
              value,
              topics: topics,
              widgets: widgets,
              userTopics: response.userTopics,
            ))) ??
        {});
    LMCommentViewData commentViewData =
        LMCommentViewDataConvertor.fromComment(response.postReplies!, users);
    // update the state with the fetched replies
    emit(LMFeedGetReplyCommentSuccessState(
        replies: commentViewData.replies ?? [],
        page: event.page,
        commentId: event.commentId));
  }
}

/// Handles [LMFeedCloseReplyEvent] event.
/// Closes the reply section for a comment on the post.
/// Emits [LMFeedCloseReplyState] to close the reply section.
void _closeReplyHandler(LMFeedCloseReplyEvent event, emit) {
  emit(LMFeedCloseReplyState(commentId: event.commentId));
}
