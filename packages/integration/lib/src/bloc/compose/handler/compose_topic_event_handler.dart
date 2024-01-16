import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/post/topic_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

Future<void> composeFetchTopicHandler(
  LMFeedComposeFetchTopicsEvent event,
  Emitter<LMFeedComposeState> emit,
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
      emit(LMFeedComposeFetchedTopicsState(topics: topics));
    }
  } catch (e) {
    debugPrint(e.toString());
  }
}
