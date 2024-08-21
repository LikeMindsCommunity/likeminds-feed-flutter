part of "../comment_bloc.dart";

/// Handles [LMFeedEditReplyEvent] event.
/// Edits a reply on the post.
/// Emits [LMFeedEditReplySuccessState] if the reply is edited successfully.
/// Emits [LMFeedEditReplyErrorState] if the reply is not edited successfully.
Future<void> _editReplyHandler(LMFeedEditReplyEvent event, emit) async {
  // emit success state to edit the reply from the state locally
  emit(LMFeedEditReplySuccessState(
    commentId: event.commentId,
    replyId: event.oldReply.id,
    reply: event.oldReply.copyWith(text: event.editText),
  ));
  // create edit reply request
  EditCommentReplyRequest editCommentReplyRequest =
      (EditCommentReplyRequestBuilder()
            ..commentId(event.commentId)
            ..postId(event.postId)
            ..replyId(event.oldReply.id)
            ..text(event.editText))
          .build();
  // make API call to edit reply
  EditCommentReplyResponse response =
      await LMFeedCore.client.editCommentReply(editCommentReplyRequest);

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

    LMCommentViewData reply =
        LMCommentViewDataConvertor.fromComment(response.reply!, users);
    // update the state with the edited reply
    emit(LMFeedEditReplySuccessState(
      commentId: event.commentId,
      replyId: event.oldReply.id,
      reply: reply,
    ));
  } else {
    // emit error state if the edit request fails and revert the state
    emit(LMFeedEditReplyErrorState(
      error: response.errorMessage ?? 'Failed to edit reply',
      commentId: event.commentId,
      oldReply: event.oldReply,
    ));
  }
}

/// Handles [LMFeedEditingReplyEvent] event.
/// Emits [LMFeedEditingReplyState] to update the state with the reply being edited.
void _editingReplyHandler(LMFeedEditingReplyEvent event, emit) {
  emit(LMFeedEditingReplyState(
    commentId: event.commentId,
    oldReply: event.oldReply,
    postId: event.postId,
    replyText: event.replyText,
  ));
}

void _editReplyCancelHandler(LMFeedEditReplyCancelEvent event, emit) {}
