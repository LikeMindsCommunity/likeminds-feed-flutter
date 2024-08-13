part of '../comment_bloc.dart';

Future<void> _getReplyHandler(LMGetReplyEvent event, emit) async {
  if (event.page == 1) {
    emit(LMGetReplyCommentLoading(
      commentId: event.commentId,
    ));
  } else {
    emit(LMGetReplyCommentPaginationLoading(
      commentId: event.commentId,
    ));
  }
  final GetCommentRequest request = (GetCommentRequestBuilder()
        ..commentId(event.commentId)
        ..postId(event.postId)
        ..page(event.page)
        ..pageSize(10))
      .build();

  GetCommentResponse response = await LMFeedCore.client.getComment(request);
  if (response.success) {
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
    emit(LMGetReplyCommentSuccess(
        replies: commentViewData.replies ?? [],
        page: event.page,
        commentId: event.commentId));
  }
}

void _closeReplyHandler(event, emit) {
  emit(LMCloseReplyState(commentId: event.commentId));
}
