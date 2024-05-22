part of 'pending_bloc.dart';

abstract class LMFeedPendingState extends Equatable {}

class LMFeedPendingInitialState extends LMFeedPendingState {
  @override
  List<Object> get props => [];
}

class LMFeedPendingPostsLoadingState extends LMFeedPendingState {
  @override
  List<Object> get props => [];
}

class LMFeedPendingPostsLoadedState extends LMFeedPendingState {
  final List<LMPostViewData> posts;
  final int totalCount;
  final int page;

  LMFeedPendingPostsLoadedState(
      {required this.posts, required this.totalCount, required this.page});

  @override
  List<Object> get props => [posts, totalCount, page];
}

class LMFeedPendingPostsErrorState extends LMFeedPendingState {
  final String errorMessage;

  LMFeedPendingPostsErrorState({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
