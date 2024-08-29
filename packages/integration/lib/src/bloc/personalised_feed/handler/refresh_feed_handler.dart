part of '../personalised_feed_bloc.dart';

/// Handler for refreshing personalised feed
void _refreshPersonalisedFeedHandler(
  LMFeedPersonalisedRefreshEvent event,
  Emitter<LMFeedPersonalisedState> emit,
) {
  emit(LMFeedPersonalisedRefreshState());
}
