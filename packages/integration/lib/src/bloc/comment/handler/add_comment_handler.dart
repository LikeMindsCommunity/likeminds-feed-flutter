part of '../comment_bloc.dart';

Future<void> _addCommentHandler(LMFeedAddCommentEvent event, emit) async {
  DateTime currentTime = DateTime.now();
  String tempId = '${-currentTime.millisecondsSinceEpoch}';
  final LMUserViewData currentUser =
      LMFeedLocalPreference.instance.fetchUserData()!;

  // create a local commentViewData to add to the state
  LMCommentViewData commentViewData = (LMCommentViewDataBuilder()
        ..id(tempId)
        ..uuid(currentUser.uuid)
        ..text(event.commentText)
        ..level(0)
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
  emit(LMFeedAddCommentSuccessState(comment: commentViewData));

  // Make a comment request
  AddCommentRequest addCommentRequest = (AddCommentRequestBuilder()
        ..postId(event.postId)
        ..text(event.commentText)
        ..tempId(tempId))
      .build();

  // Make API call to add comment
  final AddCommentResponse response =
      await LMFeedCore.client.addComment(addCommentRequest);
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
    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
      eventName: LMFeedAnalyticsKeys.commentPosted,
      widgetSource: LMFeedWidgetSource.postDetailScreen,
      eventProperties: {
        "post_id": addCommentRequest.postId,
        "comment_id": response.reply?.id,
      },
    ));
    commentViewData =
        LMCommentViewDataConvertor.fromComment(response.reply!, users);
    emit(LMFeedAddCommentSuccessState(comment: commentViewData));
  } else {
    emit(
      LMFeedAddCommentErrorState(
        error: response.errorMessage ?? 'Failed to add comment',
        commentId: commentViewData.id,
      ),
    );
  }
}
