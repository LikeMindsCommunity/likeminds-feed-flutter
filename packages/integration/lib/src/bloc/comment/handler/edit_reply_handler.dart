part of "../comment_bloc.dart";

Future<void> _editReplyHandler(LMEditReply event, emit) async {
  // emit success state to edit the reply from the state locally
  emit(LMEditReplySuccess(
    commentId: event.commentId,
    replyId: event.oldReply.id,
    reply: event.oldReply.copyWith(text: event.editText),
  ));

  EditCommentReplyRequest editCommentReplyRequest =
      (EditCommentReplyRequestBuilder()
            ..commentId(event.commentId)
            ..postId(event.postId)
            ..replyId(event.oldReply.id)
            ..text(event.editText))
          .build();

  EditCommentReplyResponse response =
      await LMFeedCore.client.editCommentReply(editCommentReplyRequest);

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

    LMCommentViewData reply =
        LMCommentViewDataConvertor.fromComment(response.reply!, users);

    emit(LMEditReplySuccess(
      commentId: event.commentId,
      replyId: event.oldReply.id,
      reply: reply,
    ));
  } else {
    emit(LMEditReplyError(
      error: response.errorMessage ?? 'Failed to edit reply',
      commentId: event.commentId,
      oldReply: event.oldReply,
    ));
  }
}

void _editingReplyHandler(LMEditingReplyEvent event, emit) {
  emit(LMEditingReplyState(
    commentId: event.commentId,
    oldReply: event.oldReply,
    postId: event.postId,
    replyText: event.replyText,
  ));
}

void _editReplyCancelHandler(LMEditReplyCancelEvent event, emit) {}
