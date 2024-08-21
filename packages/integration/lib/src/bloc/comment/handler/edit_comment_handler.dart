part of "../comment_bloc.dart";

/// Handles [LMFeedEditCommentEvent] event.
/// Edits a comment on the post.
/// Emits [LMFeedEditCommentSuccessState] if the comment is edited successfully.
/// Emits [LMFeedEditCommentErrorState] if the comment is not edited successfully.
Future<void> _editCommentHandler(LMFeedEditCommentEvent event, emit) async {
  // local commentViewData to add to the state
  LMCommentViewData commentViewData = event.oldComment.copyWith(
    text: event.editedText,
    isEdited: true,
  );
  // update the state with the edited comment text locally
  emit(LMFeedEditCommentSuccessState(
    commentViewData: commentViewData,
  ));
  // build edit comment request
  EditCommentRequest editCommentRequest = (EditCommentRequestBuilder()
        ..postId(event.postId)
        ..commentId(event.oldComment.id)
        ..text(event.editedText))
      .build();
  // make API call to edit comment
  final EditCommentResponse response =
      await LMFeedCore.client.editComment(editCommentRequest);

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

    commentViewData =
        LMCommentViewDataConvertor.fromComment(response.reply!, users);
    // update the state with the edited comment
    emit(LMFeedEditCommentSuccessState(
      commentViewData: commentViewData,
    ));
  } else {
    // emit error state if the edit request fails and revert the state
    emit(LMFeedEditCommentErrorState(
      error: response.errorMessage ?? 'An error occurred',
      oldComment: event.oldComment,
    ));
  }
}

/// Handles [LMFeedEditCommentCancelEvent] event.
/// Cancels editing a comment on the post.
/// Emits [LMFeedEditingCommentCancelState] to cancel editing the comment.
void _cancelEditingCommentHandler(LMFeedEditCommentCancelEvent event, emit) {
  emit(LMFeedEditingCommentCancelState());
}

/// Handles [LMFeedEditingCommentEvent] event.
/// Edits a comment on the post.
/// Emits [LMFeedEditingCommentState] to edit the comment.
void _editingCommentHandler(LMFeedEditingCommentEvent event, emit) {
  emit(LMFeedEditingCommentState(
    postId: event.postId,
    oldComment: event.oldComment,
  ));
}
