part of '../search_bloc.dart';

Future<void> clearSearchEventHandler(
    LMFeedClearSearchEvent event, Emitter<LMFeedSearchState> emit) async {
  emit(LMFeedInitialSearchState());
}