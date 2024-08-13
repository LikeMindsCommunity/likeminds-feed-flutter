part of "../comment_bloc.dart";

Future<void> _editCommentHandler(LMEditCommentEvent event, emit) async {
  // local commentViewData to add to the state
  LMCommentViewData commentViewData = event.oldComment.copyWith(
    text: event.editedText,
    isEdited: true,
  );
  emit(LMEditCommentSuccess(
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
    emit(LMEditCommentSuccess(
      commentViewData: commentViewData,
    ));
  } else {
    emit(LMEditCommentError(
      error: response.errorMessage ?? 'An error occurred',
      oldComment: event.oldComment,
    ));
  }
}

void _cancelEditingCommentHandler(LMEditCommentCancelEvent event, emit) {
  emit(LMEditingCommentCancelState());
}

void _editingCommentHandler(LMEditingCommentEvent event, emit) {
  emit(LMEditingCommentState(
    postId: event.postId,
    oldComment: event.oldComment,
  ));
}
