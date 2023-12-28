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

class LMUniversalFeedBloc
    extends Bloc<LMUniversalFeedEvent, LMUniversalFeedState> {
  // final FeedApi feedApi;
  LMUniversalFeedBloc() : super(LMUniversalFeedInitial()) {
    on<LMUniversalFeedEvent>((event, emit) async {
      if (event is LMGetUniversalFeed) {
        await _mapLMGetUniversalFeedToState(
            event: event, offset: event.offset, emit: emit);
      }
    });
  }

  FutureOr<void> _mapLMGetUniversalFeedToState(
      {required LMGetUniversalFeed event,
      required int offset,
      required Emitter<LMUniversalFeedState> emit}) async {
    Map<String, LMUserViewData> users = {};
    Map<String, LMTopicViewData> topics = {};
    Map<String, LMWidgetViewData> widgets = {};

    if (state is LMUniversalFeedLoaded) {
      LMUniversalFeedLoaded prevState = state as LMUniversalFeedLoaded;
      users = prevState.users;
      topics = prevState.topics;
      widgets = prevState.widgets;
      emit(LMPaginatedUniversalFeedLoading(
        posts: prevState.posts,
        users: prevState.users,
        widgets: prevState.widgets,
        topics: prevState.topics,
      ));
    } else {
      emit(LMUniversalFeedLoading());
    }
    List<Topic> selectedTopics = [];

    if (event.topics != null && event.topics!.isNotEmpty) {
      selectedTopics = event.topics!
          .map((e) => LMTopicViewDataConvertor.toTopic(e))
          .toList();
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
      emit(const LMUniversalFeedError(
          message: "An error occurred, please check your network connection"));
    } else {
      users.addAll(response.users.map((key, value) =>
          MapEntry(key, LMUserViewDataConvertor.fromUser(value))));
      topics.addAll(response.topics.map((key, value) =>
          MapEntry(key, LMTopicViewDataConvertor.fromTopic(value))));

      emit(
        LMUniversalFeedLoaded(
          topics: topics,
          posts: response.posts
              .map((e) => LMPostViewDataConvertor.fromPost(post: e))
              .toList(),
          users: users,
          widgets: widgets,
        ),
      );
    }
  }
}
