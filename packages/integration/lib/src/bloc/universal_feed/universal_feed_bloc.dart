import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'universal_feed_event.dart';
part 'universal_feed_state.dart';
part 'handler/refresh_feed_handler.dart';

class LMFeedUniversalBloc
    extends Bloc<LMFeedUniversalEvent, LMFeedUniversalState> {
  // list of selected topics by the user
  List<LMTopicViewData> selectedTopics = [];
  // list of all the topics
  Map<String, LMTopicViewData> topics = {};
// list of all the users
  Map<String, LMUserViewData> users = {};
  // list of all the widgets
  Map<String, LMWidgetViewData> widgets = {};

  static LMFeedUniversalBloc? _instance;

  static LMFeedUniversalBloc get instance =>
      _instance == null || _instance!.isClosed
          ? _instance = LMFeedUniversalBloc._()
          : _instance!;

  // final FeedApi feedApi;
  LMFeedUniversalBloc._() : super(LMFeedInitialState()) {
    on<LMFeedGetUniversalFeedEvent>(_mapLMGetUniversalFeedToState);
    on<LMFeedUniversalRefreshEvent>(_refreshUniversalFeedHandler);
  }

  FutureOr<void> _mapLMGetUniversalFeedToState(
      LMFeedGetUniversalFeedEvent event,
      Emitter<LMFeedUniversalState> emit) async {
    Map<String, LMUserViewData> users = {};
    Map<String, LMTopicViewData> topics = {};
    Map<String, LMWidgetViewData> widgets = {};

    if (state is LMFeedUniversalFeedLoadedState) {
      LMFeedUniversalFeedLoadedState prevState =
          state as LMFeedUniversalFeedLoadedState;
      users = prevState.users;
      topics = prevState.topics;
      widgets = prevState.widgets;
      emit(LMFeedPaginatedUniversalFeedLoadingState(
        posts: prevState.posts,
        users: prevState.users,
        widgets: prevState.widgets,
        topics: prevState.topics,
      ));
    } else {
      emit(LMFeedUniversalFeedLoadingState());
    }
    final universalFeedRequestBuilder = GetFeedRequestBuilder()
      ..page(event.pageKey)
      ..topicIds(event.topicsIds)
      ..pageSize(event.pageSize)
      ..feedType(event.feedThemeType);
    if (event.widgetIds != null) {
      universalFeedRequestBuilder.widgetIds(event.widgetIds!);
    }
    if (event.startFeedWithPostIds != null) {
      universalFeedRequestBuilder.startFeedWithPostIds(
        event.startFeedWithPostIds!,
      );
    }
    GetFeedResponse response =
        await LMFeedCore.instance.lmFeedClient.getUniversalFeed(
      universalFeedRequestBuilder.build(),
    );

    if (!response.success) {
      emit(LMFeedUniversalFeedErrorState(
          message: response.errorMessage ??
              "An error occurred, please check your network connection"));
    } else {
      widgets.addAll(response.widgets?.map((key, value) => MapEntry(
              key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
          {});

      topics.addAll(response.topics?.map((key, value) => MapEntry(key,
              LMTopicViewDataConvertor.fromTopic(value, widgets: widgets))) ??
          {});

      users.addAll(response.users?.map((key, value) => MapEntry(
                key,
                LMUserViewDataConvertor.fromUser(value,
                    topics: topics,
                    userTopics: response.userTopics,
                    widgets: widgets),
              )) ??
          {});

      Map<String, LMCommentViewData> filteredComments =
          response.filteredComments?.map((key, value) => MapEntry(
                  key, LMCommentViewDataConvertor.fromComment(value, users))) ??
              {};

      Map<String, LMPostViewData> repostedPosts = response.repostedPosts?.map(
              (key, value) => MapEntry(
                  key,
                  LMPostViewDataConvertor.fromPost(
                      post: value,
                      users: users,
                      topics: topics,
                      widgets: widgets,
                      filteredComments: filteredComments,
                      userTopics: response.userTopics))) ??
          {};

      emit(
        LMFeedUniversalFeedLoadedState(
          pageKey: event.pageKey,
          topics: topics,
          posts: response.posts
                  ?.map((e) => LMPostViewDataConvertor.fromPost(
                        post: e,
                        widgets: widgets,
                        repostedPosts: repostedPosts,
                        users: users,
                        topics: topics,
                        filteredComments: filteredComments,
                        userTopics: response.userTopics,
                      ))
                  .toList() ??
              [],
          users: users,
          widgets: widgets,
        ),
      );
    }
  }
}
