part of 'personalised_feed_bloc.dart';

sealed class LMFeedPersonalisedState extends Equatable {
  const LMFeedPersonalisedState();
  @override
  List<Object?> get props => [];
}

final class LMFeedPersonalisedInitialState extends LMFeedPersonalisedState {}

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

class LMFeedPersonalisedFeedLoadingState extends LMFeedPersonalisedState {
  @override
  List<Object?> get props => [];
}

class LMFeedPersonalisedErrorState extends LMFeedPersonalisedState {
  final String message;

  const LMFeedPersonalisedErrorState({
    required this.message,
  });

  @override
  List<Object?> get props => [message];
}

final class LMFeedPersonalisedRefreshState extends LMFeedPersonalisedState {}
