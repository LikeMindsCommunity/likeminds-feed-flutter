part of '../personalised_feed_bloc.dart';

void _refreshPersonalisedFeedHandler(
  LMFeedPersonalisedRefreshEvent event,
  Emitter<LMFeedPersonalisedState> emit,
) {
  emit(LMFeedPersonalisedRefreshState());
}
