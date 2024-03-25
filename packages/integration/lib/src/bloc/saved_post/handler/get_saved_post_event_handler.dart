part of '../saved_post_bloc.dart';

getSavedPostEventHandler(LMFeedGetSavedPostEvent event, emit) async {
  try {
    emit(LMFeedSavedPostLoadingState());
    final user = LMFeedLocalPreference.instance.fetchUserData();
    final savePostResponse = await LMFeedCore.client.getSavedPost(
      (GetSavedPostRequestBuilder()
            ..uuid(user?.uuid ?? "")
            ..page(event.page)
            ..pageSize(event.pageSize))
          .build(),
    );
    debugPrint(user?.uuid);
    if (savePostResponse.success) {
      Map<String, LMWidgetViewData> widgets = (savePostResponse.widgets ??
              <String, WidgetModel>{})
          .map((key, value) =>
              MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)));

      Map<String, LMTopicViewData> topics =
          (savePostResponse.topics ?? <String, Topic>{}).map((key, value) =>
              MapEntry(key,
                  LMTopicViewDataConvertor.fromTopic(value, widgets: widgets)));

      Map<String, LMUserViewData> users =
          (savePostResponse.users ?? <String, User>{})
              .map((key, value) => MapEntry(
                  key,
                  LMUserViewDataConvertor.fromUser(
                    value,
                    topics: topics,
                    userTopics: savePostResponse.userTopics,
                    widgets: widgets,
                  )));

      Map<String, LMPostViewData> respostedPost =
          savePostResponse.repostedPosts?.map((key, value) => MapEntry(
                  key,
                  LMPostViewDataConvertor.fromPost(
                    post: value,
                    users: users,
                    topics: topics,
                    widgets: widgets,
                  ))) ??
              {};

      Map<String, LMCommentViewData> filteredComments =
          savePostResponse.filteredComments?.map((key, value) => MapEntry(
                  key,
                  LMCommentViewDataConvertor.fromComment(
                    value,
                    users,
                  ))) ??
              {};

      List<LMPostViewData> savedPost = [];

      savePostResponse.posts?.forEach((post) {
        savedPost.add(LMPostViewDataConvertor.fromPost(
          post: post,
          widgets: widgets,
          repostedPosts: respostedPost,
          users: users,
          topics: topics,
          filteredComments: filteredComments,
          userTopics: savePostResponse.userTopics,
        ));
      });
      emit(
        LMFeedSavedPostLoadedState(posts: savedPost, page: event.page),
      );
    } else {
      emit(
        LMFeedSavedPostErrorState(
            errorMessage: savePostResponse.errorMessage ??
                "An error occurred, Please try again",
            stackTrace: StackTrace.current),
      );
    }
  } on Exception catch (e, stackTrace) {
    emit(LMFeedSavedPostErrorState(
        errorMessage: e.toString(), stackTrace: stackTrace));
  }
}
