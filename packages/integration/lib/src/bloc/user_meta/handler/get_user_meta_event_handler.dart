part of '../user_meta_bloc.dart';

getUserMetaEventHandler(
    LMFeedUserMetaGetEvent event, Emitter<LMFeedUserMetaState> emit) async {
  emit(LMFeedUserMetaLoadingState(uuid: event.uuid));
  try {
    final response = await LMFeedCore.instance.lmFeedClient.getUserFeedMeta(
        (GetUserFeedMetaRequestBuilder()..uuid(event.uuid)).build());

    final user = response.users?.entries.first.value;

    Map<String, LMWidgetViewData> widgets =
        (response.widgets ?? <String, WidgetModel>{}).map((key, value) =>
            MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));

    Map<String, LMTopicViewData> topics = (response.topics ?? <String, Topic>{})
        .map((key, value) => MapEntry(
            key, LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

    final userViewData = LMUserViewDataConvertor.fromUser(
      user!,
      widgets: widgets,
      userTopics: response.userTopics,
      topics: topics,
    );

    emit(LMFeedUserMetaLoadedState(
      user: userViewData,
      postsCount: response.postsCount,
      commentsCount: response.commentsCount,
    ));
  } on Exception catch (e, stackTrace) {
    LMFeedLogger.instance.handleException(e, stackTrace);
    emit(LMFeedUserMetaErrorState(
      message: e.toString(),
    ));
  }
}
