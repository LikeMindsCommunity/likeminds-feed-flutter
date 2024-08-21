part of '../comment_bloc.dart';

/// Handles [LMFeedReplyCommentEvent] event.
/// Replies to a comment on the post.
/// Emits [LMFeedReplyCommentSuccessState] if the reply is added successfully.
/// Emits [LMFeedReplyCommentErrorState] if the reply is not added successfully.
Future<void> _replyCommentHandler(LMFeedReplyCommentEvent event, emit) async {
  // create a temp id for the comment
  DateTime currentTime = DateTime.now();
  String tempId = '${-currentTime.millisecondsSinceEpoch}';
  // get the current user
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
  // Update the state with the local comment
  emit(LMFeedReplyCommentSuccessState(
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
    // Parse the response and update the state
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

    // fire analytics event for reply posted
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

    // update the state with the new reply
    emit(LMFeedReplyCommentSuccessState(reply: reply));
  } else {
    // emit error state if the reply request fails and revert the state
    emit(
      LMFeedReplyCommentErrorState(
        error: response.errorMessage ?? ' Something went wrong',
        commentId: event.parentComment.id,
        replyId: commentViewData.id,
      ),
    );
  }
}

/// Handles [LMFeedReplyingCommentEvent] event.
/// Prepares the state to reply to a comment on the post.
/// Emits [LMFeedReplyingCommentState] to prepare the state to reply to a comment.
void _replyingCommentHandler(LMFeedReplyingCommentEvent event, emit) {
  emit(LMFeedReplyingCommentState(
    postId: event.postId,
    parentComment: event.parentComment,
    userName: event.userName,
  ));
}

/// Handles [LMFeedReplyCancelEvent] event.
/// Cancels the reply to a comment on the post.
/// Emits [LMFeedReplyCancelState] to cancel the reply.
void _cancelReplyCommentHandler(event, emit) {
  emit(LMFeedReplyCancelState());
}
