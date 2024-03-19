part of '../user_meta_bloc.dart';

getUserMetaEventHandler(
    LMFeedUserMetaGetEvent event, Emitter<LMFeedUserMetaState> emit) async {
  emit(LMFeedUserMetaLoadingState());
  try {
    final response = await LMFeedCore.instance.lmFeedClient.getUserFeedMeta(
        (GetUserFeedMetaRequestBuilder()..uuid(event.uuid)).build());

    final user = response.users?.entries.first.value;
    final userViewData = LMUserViewDataConvertor.fromUser(
      user!,
      widgets: response.widgets,
      userTopics: response.userTopics,
      topics: response.topics,
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
