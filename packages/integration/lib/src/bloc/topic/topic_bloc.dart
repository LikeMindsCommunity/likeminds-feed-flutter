import 'package:equatable/equatable.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/likeminds_feed_core.dart';

part 'topic_event.dart';
part 'topic_state.dart';

class LMTopicBloc extends Bloc<LMTopicEvent, LMTopicState> {
  LMTopicBloc() : super(LMTopicInitial()) {
    on<LMTopicEvent>((event, emit) async {
      if (event is LMInitTopicEvent) {
        emit(LMTopicLoading());
      } else if (event is LMGetTopic) {
        emit(LMTopicLoading());
        GetTopicsResponse response =
            await LMFeedCore.client.getTopics(event.getTopicFeedRequest);
        if (response.success) {
          emit(LMTopicLoaded(response));
        } else {
          emit(LMTopicError(response.errorMessage!));
        }
      }
    });
  }
}
