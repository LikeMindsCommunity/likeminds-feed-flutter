part of '../feedroom_bloc.dart';

FutureOr<void> _mapLMGetFeedRoomToState({
  required LMFeedGetFeedRoomEvent event,
  required Emitter<LMFeedRoomState> emit,
}) async {
  Map<String, LMUserViewData> users = {};
  Map<String, LMTopicViewData> topics = {};
  Map<String, LMWidgetViewData> widgets = {};

  if (LMFeedRoomBloc.instance.state is LMFeedRoomLoadedState) {
    LMFeedRoomLoadedState prevState =
        LMFeedRoomBloc.instance.state as LMFeedRoomLoadedState;
    users = prevState.users;
    topics = prevState.topics;
    widgets = prevState.widgets;

    emit(LMFeedRoomPaginationLoadingState(
      posts: prevState.posts,
      users: prevState.users,
      widgets: prevState.widgets,
      topics: prevState.topics,
      feedRoom: prevState.feedRoom,
    ));
  } else {
    emit(LMFeedRoomLoadingState());
  }

  GetFeedOfFeedRoomResponse response =
      await LMFeedCore.client.getFeedOfFeedRoom(
    (GetFeedOfFeedRoomRequestBuilder()
          ..feedroomId(event.feedRoomId)
          ..topicIds(
              LMFeedRoomBloc.instance.selectedTopics.map((e) => e.id).toList())
          ..page(event.offset)
          ..pageSize(10))
        .build(),
  );
  if (!response.success) {
    emit(
      LMFeedRoomErrorState(
        message: response.errorMessage ?? 'An error occurred',
      ),
    );
  }

  users.addAll(
    response.users.map(
      (key, value) => MapEntry(
        key,
        LMUserViewDataConvertor.fromUser(value),
      ),
    ),
  );

  topics.addAll(
    response.topics.map(
      (key, value) => MapEntry(key, LMTopicViewDataConvertor.fromTopic(value)),
    ),
  );

  GetFeedRoomResponse feedRoomResponse = await LMFeedCore.client.getFeedRoom(
    (GetFeedRoomRequestBuilder()
          ..feedroomId(event.feedRoomId)
          ..page(event.offset))
        .build(),
  );
  if (!feedRoomResponse.success) {
    emit(
      LMFeedRoomErrorState(
        message: feedRoomResponse.errorMessage ?? 'An error occurred',
      ),
    );
  }

  // widgets.addAll(response.widgets.map((key, value) =>
  //         MapEntry(key, LMWidgetViewDataConvertor.fromWidgetModel(value)),),);

  emit(
    LMFeedRoomLoadedState(
      feedRoom: LMFeedRoomViewDataConvertor.fromFeedRoomModel(
          feedRoomModel: feedRoomResponse.chatroom!),
      topics: topics,
      posts: response.posts
              ?.map((e) => LMPostViewDataConvertor.fromPost(
                    post: e,
                    // widgets: response.widgets,
                    // repostedPosts: response.repostedPosts,
                    users: response.users.map((key, value) =>
                        MapEntry(key, LMUserViewDataConvertor.fromUser(value))),
                    topics: response.topics.map((key, value) => MapEntry(
                        key, LMTopicViewDataConvertor.fromTopic(value))),
                    // filteredComments: response.filteredComments,
                    // userTopics: response.userTopics,
                  ))
              .toList() ??
          [],
      users: users,
      widgets: widgets,
      pageKey: event.offset,
    ),
  );
}
