part of 'universal_feed_bloc.dart';

abstract class LMFeedUniversalEvent extends Equatable {
  const LMFeedUniversalEvent();
  @override
  List<Object?> get props => [];
}

class LMFeedGetUniversalFeedEvent extends LMFeedUniversalEvent {
  final int pageKey;
  final List<String> topicsIds;

  const LMFeedGetUniversalFeedEvent(
      {required this.pageKey, required this.topicsIds});
  @override
  List<Object?> get props => [pageKey, topicsIds];
}

class LMFeedUniversalRefreshEvent extends LMFeedUniversalEvent {}