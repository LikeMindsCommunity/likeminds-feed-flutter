part of 'universal_feed_bloc.dart';

abstract class LMFeedUniversalEvent extends Equatable {
  const LMFeedUniversalEvent();
  @override
  List<Object?> get props => [];
}

class LMFeedGetUniversalFeedEvent extends LMFeedUniversalEvent {
  final int pageKey;
  final int pageSize;
  final List<String> topicsIds;
  final List<String>? widgetIds;

  const LMFeedGetUniversalFeedEvent({
    required this.pageKey,
    required this.pageSize,
    required this.topicsIds,
    this.widgetIds,
  });
  @override
  List<Object?> get props => [pageKey, pageSize, topicsIds, widgetIds];
}

class LMFeedUniversalRefreshEvent extends LMFeedUniversalEvent {}
