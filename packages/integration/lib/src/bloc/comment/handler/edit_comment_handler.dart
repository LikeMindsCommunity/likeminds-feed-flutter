part of "../comment_bloc.dart";

Future<void> _editCommentHandler(LMFeedEditCommentEvent event, emit) async {
  // local commentViewData to add to the state
  LMCommentViewData commentViewData = event.oldComment.copyWith(
    text: event.editedText,
    isEdited: true,
  );
  emit(LMFeedEditCommentSuccessState(
    commentViewData: commentViewData,
  ));
  // build edit comment request
  EditCommentRequest editCommentRequest = (EditCommentRequestBuilder()
        ..postId(event.postId)
        ..commentId(event.oldComment.id)
        ..text(event.editedText))
      .build();
  final EditCommentResponse response =
      await LMFeedCore.client.editComment(editCommentRequest);

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

    commentViewData =
        LMCommentViewDataConvertor.fromComment(response.reply!, users);
    emit(LMFeedEditCommentSuccessState(
      commentViewData: commentViewData,
    ));
  } else {
    emit(LMFeedEditCommentErrorState(
      error: response.errorMessage ?? 'An error occurred',
      oldComment: event.oldComment,
    ));
  }
}

void _cancelEditingCommentHandler(LMFeedEditCommentCancelEvent event, emit) {
  emit(LMFeedEditingCommentCancelState());
}

void _editingCommentHandler(LMFeedEditingCommentEvent event, emit) {
  emit(LMFeedEditingCommentState(
    postId: event.postId,
    oldComment: event.oldComment,
  ));
}
