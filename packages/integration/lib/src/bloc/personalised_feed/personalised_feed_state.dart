part of 'personalised_feed_bloc.dart';

/// {@template lm_feed_personalised_state}
/// States for LMFeedPersonalisedBloc
/// {@endtemplate}
sealed class LMFeedPersonalisedState extends Equatable {
  const LMFeedPersonalisedState();
  @override
  List<Object?> get props => [];
}

/// {@template lm_feed_personalised_initial_state}
/// Initial state for LMFeedPersonalisedBloc
/// {@endtemplate}
final class LMFeedPersonalisedInitialState extends LMFeedPersonalisedState {}

/// {@template lm_feed_personalised_feed_loaded_state}
/// State when feed is loaded
/// {@endtemplate}
class LMFeedPersonalisedFeedLoadedState extends LMFeedPersonalisedState {
  final List<LMPostViewData> posts;

  final int pageKey;

  const LMFeedPersonalisedFeedLoadedState({
    required this.posts,
    required this.pageKey,
  });

  @override
  List<Object?> get props => [posts, pageKey];
}

/// {@template lm_feed_personalised_feed_loading_state}
/// State when feed is loading
/// {@endtemplate}
class LMFeedPersonalisedFeedLoadingState extends LMFeedPersonalisedState {
  @override
  List<Object?> get props => [];
}

/// {@template lm_feed_personalised_error_state}
/// State when error occurs during feed loading
/// {@endtemplate}
class LMFeedPersonalisedErrorState extends LMFeedPersonalisedState {
  final String message;

  const LMFeedPersonalisedErrorState({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

/// {@template lm_feed_personalised_refresh_state}
/// State when feed is refreshed
/// {@endtemplate}
final class LMFeedPersonalisedRefreshState extends LMFeedPersonalisedState {}

/// {@template lm_feed_personalised_seen_post_success_state}
/// State when post is marked as seen
/// {@endtemplate}
final class LMFeedPersonalisedSeenPostSuccessState
    extends LMFeedPersonalisedState {}

/// {@template lm_feed_personalised_seen_post_error_state}
/// State when error occurs during marking post as seen
/// {@endtemplate}
final class LMFeedPersonalisedSeenPostErrorState
    extends LMFeedPersonalisedState {
  final String message;

  const LMFeedPersonalisedSeenPostErrorState({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}
