part of 'personalised_feed_bloc.dart';

/// {@template lm_feed_personalised_event}
/// Events for LMFeedPersonalisedBloc
/// {@endtemplate}
sealed class LMFeedPersonalisedEvent extends Equatable {
  const LMFeedPersonalisedEvent();
  @override
  List<Object?> get props => [];
}

/// {@template lm_feed_personalised_get_event}
/// Event to get personalised feed
/// {@endtemplate}
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

/// {@template lm_feed_personalised_refresh_event}
/// Event to refresh personalised feed
/// {@endtemplate}
final class LMFeedPersonalisedRefreshEvent extends LMFeedPersonalisedEvent {
  const LMFeedPersonalisedRefreshEvent();
}

/// {@template lm_feed_personalised_seen_post_event}
/// Event to mark post as seen
/// {@endtemplate}
final class LMFeedPersonalisedSeenPostEvent extends LMFeedPersonalisedEvent {
  final List<String> seenPost;
  const LMFeedPersonalisedSeenPostEvent({
    required this.seenPost,
  });

  @override
  List<Object?> get props => [seenPost];
}
