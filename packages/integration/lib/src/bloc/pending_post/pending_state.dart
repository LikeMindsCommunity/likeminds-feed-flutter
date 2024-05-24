part of 'pending_bloc.dart';

/// Abstract base class for all the states related to pending posts in the LMFeedPendingBloc.
///
/// This class extends the Equatable class to enable state comparison and equality checks.
abstract class LMFeedPendingState extends Equatable {
  @override
  List<Object> get props => [];
}

/// Initial state of the LMFeedPendingBloc.
class LMFeedPendingInitialState extends LMFeedPendingState {}

/// State indicating that the pending posts are being loaded.
class LMFeedPendingPostsLoadingState extends LMFeedPendingState {}

/// State indicating that the pending posts have been successfully loaded.
class LMFeedPendingPostsLoadedState extends LMFeedPendingState {
  final List<LMPostViewData> posts;
  final int totalCount;
  final int page;

  /// Constructs a [LMFeedPendingPostsLoadedState] with the given [posts], [totalCount], and [page].
  LMFeedPendingPostsLoadedState({
    required this.posts,
    required this.totalCount,
    required this.page,
  });

  @override
  List<Object> get props => [posts, totalCount, page];
}

/// State indicating that an error occurred while loading the pending posts.
class LMFeedPendingPostsErrorState extends LMFeedPendingState {
  final String errorMessage;

  /// Constructs a [LMFeedPendingPostsErrorState] with the given [errorMessage].
  LMFeedPendingPostsErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
