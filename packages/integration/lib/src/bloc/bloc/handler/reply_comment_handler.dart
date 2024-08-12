part of '../lm_comment_bloc.dart';

FutureOr<void> _replyCommentHandler(LMReplyCommentEvent event, emit) async {
  DateTime currentTime = DateTime.now();
  String tempId = '${-currentTime.millisecondsSinceEpoch}';
  final LMUserViewData currentUser =
      LMFeedLocalPreference.instance.fetchUserData()!;
  // create a local commentViewData to add to the state
  LMCommentViewData commentViewData = (LMCommentViewDataBuilder()
        ..id(tempId)
        ..uuid(currentUser.uuid)
        ..text(event.comment)
        ..level(1)
        ..likesCount(0)
        ..isEdited(false)
        ..repliesCount(0)
        ..menuItems([])
        ..createdAt(currentTime)
        ..updatedAt(currentTime)
        ..isLiked(false)
        ..user(currentUser)
        ..tempId(tempId))
      .build();
  // emit(LMReplyCommentSuccess(
  //   comment: commentViewData,
  // ));
  // create add reply comment request
  AddCommentReplyRequest addReplyRequest = (AddCommentReplyRequestBuilder()
        ..postId(event.postId)
        ..text(event.comment)
        ..tempId(tempId)
        ..commentId(event.commentId))
      .build();

  // Make API call to add comment
  final AddCommentReplyResponse response =
      await LMFeedCore.client.addCommentReply(addReplyRequest);
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
    emit(LMReplyCommentSuccess(reply: reply));
  } else {
    emit(
      LMAddCommentError(
          error: response.errorMessage ?? ' Something went wrong'),
    );
  }
}

FutureOr<void> _replyingCommentHandler(event, emit) {
  emit(LMReplyingCommentState(
    postId: event.postId,
    commentId: event.commentId,
    userName: event.userName,
  ));
}

FutureOr<void> _cancelReplyCommentHandler(event, emit) {
  emit(LMReplyCancelState());
}
