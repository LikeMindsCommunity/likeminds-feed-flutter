part of 'universal_feed_bloc.dart';

abstract class LMFeedEvent extends Equatable {
  const LMFeedEvent();
}

class LMFeedGetUniversalFeedEvent extends LMFeedEvent {
  final int pageKey;
  final List<String> topicsIds;

  const LMFeedGetUniversalFeedEvent(
      {required this.pageKey, required this.topicsIds});
  @override
  List<Object?> get props => [pageKey, topicsIds];
}
