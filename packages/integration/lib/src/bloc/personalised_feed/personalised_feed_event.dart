part of 'personalised_feed_bloc.dart';

sealed class LMFeedPersonalisedEvent extends Equatable {
  const LMFeedPersonalisedEvent();
  @override
  List<Object?> get props => [];
}

final class LMFeedPersonalisedGetEvent extends LMFeedPersonalisedEvent {
  final int pageKey;
  final int pageSize;

  const LMFeedPersonalisedGetEvent({
    required this.pageKey,
    required this.pageSize,
  });

  @override
  List<Object?> get props => [pageKey, pageSize];
}

final class LMFeedPersonalisedRefreshEvent extends LMFeedPersonalisedEvent {
  const LMFeedPersonalisedRefreshEvent();
}