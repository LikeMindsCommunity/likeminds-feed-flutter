import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_driver.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/post/post_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/post/topic_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/user/user_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

part 'universal_feed_event.dart';

part 'universal_feed_state.dart';

class UniversalFeedBloc extends Bloc<UniversalFeedEvent, UniversalFeedState> {
  // final FeedApi feedApi;
  UniversalFeedBloc() : super(UniversalFeedInitial()) {
    on<UniversalFeedEvent>((event, emit) async {
      if (event is GetUniversalFeed) {
        await _mapGetUniversalFeedToState(
            event: event, offset: event.offset, emit: emit);
      }
    });
  }

  FutureOr<void> _mapGetUniversalFeedToState(
      {required GetUniversalFeed event,
      required int offset,
      required Emitter<UniversalFeedState> emit}) async {
    Map<String, UserViewData> users = {};
    Map<String, TopicViewData> topics = {};
    Map<String, WidgetViewData> widgets = {};

    if (state is UniversalFeedLoaded) {
      UniversalFeedLoaded prevState = state as UniversalFeedLoaded;
      users = prevState.users;
      topics = prevState.topics;
      widgets = prevState.widgets;
      emit(PaginatedUniversalFeedLoading(
        posts: prevState.posts,
        users: prevState.users,
        widgets: prevState.widgets,
        topics: prevState.topics,
      ));
    } else {
      emit(UniversalFeedLoading());
    }
    List<Topic> selectedTopics = [];

    if (event.topics != null && event.topics!.isNotEmpty) {
      selectedTopics =
          event.topics!.map((e) => TopicViewDataConvertor.toTopic(e)).toList();
    }
    GetFeedResponse? response =
        await LMFeedIntegration.instance.lmFeedClient.getFeed(
      (GetFeedRequestBuilder()
            ..page(offset)
            ..topics(selectedTopics)
            ..pageSize(10))
          .build(),
    );

    if (response == null) {
      emit(const UniversalFeedError(
          message: "An error occurred, please check your network connection"));
    } else {
      users.addAll(response.users.map((key, value) =>
          MapEntry(key, UserViewDataConvertor.fromUser(value))));
      topics.addAll(response.topics.map((key, value) =>
          MapEntry(key, TopicViewDataConvertor.fromTopic(value))));

      emit(
        UniversalFeedLoaded(
          topics: topics,
          posts: response.posts
              .map((e) => PostViewDataConvertor.fromPost(post: e))
              .toList(),
          users: users,
          widgets: widgets,
        ),
      );
    }
  }
}
