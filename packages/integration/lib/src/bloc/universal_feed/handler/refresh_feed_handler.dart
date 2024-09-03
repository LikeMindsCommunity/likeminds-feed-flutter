part of '../universal_feed_bloc.dart';

void _refreshUniversalFeedHandler(
  LMFeedUniversalRefreshEvent event,
  Emitter<LMFeedUniversalState> emit,
) {
  emit(LMFeedUniversalRefreshState());
}
