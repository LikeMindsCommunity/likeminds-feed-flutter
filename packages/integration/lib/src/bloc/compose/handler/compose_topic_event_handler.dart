import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/post/topic_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

void composeFetchTopicHandler(
  LMComposeEvent event,
  Emitter<LMComposeState> emit,
) async {
  try {
    final GetTopicsResponse response =
        await LMFeedCore.client.getTopics((GetTopicsRequestBuilder()
              ..page(1)
              ..pageSize(20)
              ..isEnabled(true))
            .build());
    if (response.success) {
      final List<LMTopicViewData> topics = response.topics!
          .map((e) => LMTopicViewDataConvertor.fromTopic(e))
          .toList();
      emit(LMComposeFetchedTopics(topics: topics));
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}
