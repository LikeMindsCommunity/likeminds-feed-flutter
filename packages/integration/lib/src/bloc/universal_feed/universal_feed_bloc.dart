import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'universal_feed_event.dart';

part 'universal_feed_state.dart';

class LMFeedBloc extends Bloc<LMFeedEvent, LMFeedState> {
  // list of selected topics by the user
  List<LMTopicViewData> selectedTopics = [];
  // list of all the topics
  Map<String, LMTopicViewData> topics = {};
  // list of all the users
  Map<String, LMUserViewData> users = {};
  // list of all the widgets
  Map<String, LMWidgetViewData> widgets = {};

  static LMFeedBloc? _instance;

  static LMFeedBloc get instance => _instance ??= LMFeedBloc._();

  // final FeedApi feedApi;
  LMFeedBloc._() : super(LMFeedInitialState()) {
    on<LMFeedEvent>((event, emit) async {
      if (event is LMFeedGetUniversalFeedEvent) {
        await _mapLMGetUniversalFeedToState(event: event, emit: emit);
      }
    });
  }

  FutureOr<void> _mapLMGetUniversalFeedToState(
      {required LMFeedGetUniversalFeedEvent event,
      required Emitter<LMFeedState> emit}) async {
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
    List<Topic> selectedTopics = [];

    if (event.topics != null && event.topics!.isNotEmpty) {
      selectedTopics = event.topics!
          .map((e) => LMTopicViewDataConvertor.toTopic(e))
          .toList();
    }
    GetFeedResponse response =
        await LMFeedCore.instance.lmFeedClient.getUniversalFeed(
      (GetFeedRequestBuilder()
            ..page(event.offset)
            ..topics(selectedTopics.map((e) => e).toList())
            ..pageSize(10))
          .build(),
    );

    if (!response.success) {
      emit(LMFeedUniversalFeedErrorState(
          message: response.errorMessage ??
              "An error occurred, please check your network connection"));
    } else {
      users.addAll(response.users?.map((key, value) =>
              MapEntry(key, LMUserViewDataConvertor.fromUser(value))) ??
          {});

      topics.addAll(response.topics?.map((key, value) =>
              MapEntry(key, LMTopicViewDataConvertor.fromTopic(value))) ??
          {});

      widgets.addAll(response.widgets?.map((key, value) => MapEntry(
              key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
          {});

      emit(
        LMFeedUniversalFeedLoadedState(
          topics: topics,
          posts: response.posts
                  ?.map((e) => LMPostViewDataConvertor.fromPost(
                        post: e,
                        widgets: response.widgets,
                        repostedPosts: response.repostedPosts,
                        users: response.users,
                        topics: response.topics,
                        filteredComments: response.filteredComments,
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
