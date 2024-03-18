import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'topic_event.dart';
part 'topic_state.dart';

class LMFeedTopicBloc extends Bloc<LMFeedTopicEvent, LMFeedTopicState> {
  LMFeedTopicBloc() : super(LMFeedTopicInitialState()) {
    on<LMFeedTopicEvent>((event, emit) async {
      if (event is LMFeedInitTopicEvent) {
        emit(LMFeedTopicLoadingState());
      } else if (event is LMFeedGetTopicEvent) {
        emit(LMFeedTopicLoadingState());
        GetTopicsResponse response =
            await LMFeedCore.client.getTopics(event.getTopicFeedRequest);
        if (response.success) {
          emit(LMFeedTopicLoadedState(
            response,
            event.getTopicFeedRequest.page,
          ));
        } else {
          emit(LMFeedTopicErrorState(response.errorMessage!));
        }
      }
    });
  }
}
