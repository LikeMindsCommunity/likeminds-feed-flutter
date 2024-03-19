part of 'search_bloc.dart';

abstract class LMFeedSearchState extends Equatable {
  const LMFeedSearchState();

  @override
  List<Object> get props => [];
}

class LMFeedInitialSearchState extends LMFeedSearchState {}

// Add more state classes here as needed
class LMFeedSearchLoadedState extends LMFeedSearchState {
  final List<LMPostViewData> posts;

  LMFeedSearchLoadedState({
    required this.posts,
  });

  @override
  List<Object> get props => [posts];
}

class LMFeedSearchLoadingState extends LMFeedSearchState {}

class LMFeedSearchPaginationLoadingState extends LMFeedSearchState {}

class LMFeedSearchErrorState extends LMFeedSearchState {
  final String message;
  LMFeedSearchErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
