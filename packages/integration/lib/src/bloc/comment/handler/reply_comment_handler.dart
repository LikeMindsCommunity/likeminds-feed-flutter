part of '../comment_bloc.dart';

Future<void> _replyCommentHandler(LMReplyCommentEvent event, emit) async {
  DateTime currentTime = DateTime.now();
  String tempId = '${-currentTime.millisecondsSinceEpoch}';
  final LMUserViewData currentUser =
      LMFeedLocalPreference.instance.fetchUserData()!;
  // create a local commentViewData to add to the state
  LMCommentViewData commentViewData = (LMCommentViewDataBuilder()
        ..id(tempId)
        ..uuid(currentUser.uuid)
        ..text(event.replyText)
        ..level(1)
        ..likesCount(0)
        ..isEdited(false)
        ..repliesCount(0)
        ..parentComment(event.parentComment)
        ..menuItems([])
        ..createdAt(currentTime)
        ..updatedAt(currentTime)
        ..isLiked(false)
        ..user(currentUser)
        ..tempId(tempId))
      .build();
  emit(LMReplyCommentSuccess(
    reply: commentViewData,
  ));
  // create add reply comment request
  AddCommentReplyRequest addReplyRequest = (AddCommentReplyRequestBuilder()
        ..postId(event.postId)
        ..text(event.replyText)
        ..tempId(tempId)
        ..commentId(event.parentComment.id))
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
    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.replyPosted,
        widgetSource: LMFeedWidgetSource.postDetailScreen,
        eventProperties: {
          "post_id": addReplyRequest.postId,
          "comment_id": addReplyRequest.commentId,
          "comment_reply_id": response.reply?.id,
          "user_id": currentUser.id,
        },
      ),
    );
    LMCommentViewData reply =
        LMCommentViewDataConvertor.fromComment(response.reply!, users);
    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.replyPosted,
        widgetSource: LMFeedWidgetSource.postDetailScreen,
        eventProperties: {
          "post_id": addReplyRequest.postId,
          "comment_id": addReplyRequest.commentId,
          "comment_reply_id": response.reply?.id,
          "user_id": currentUser.id,
        },
      ),
    );
    emit(LMReplyCommentSuccess(reply: reply));
  } else {
    emit(
      LMReplyCommentError(
        error: response.errorMessage ?? ' Something went wrong',
        commentId: event.parentComment.id,
        replyId: commentViewData.id,
      ),
    );
  }
}

void _replyingCommentHandler(LMReplyingCommentEvent event, emit) {
  emit(LMReplyingCommentState(
    postId: event.postId,
    parentComment: event.parentComment,
    userName: event.userName,
  ));
}

void _cancelReplyCommentHandler(event, emit) {
  emit(LMReplyCancelState());
}
