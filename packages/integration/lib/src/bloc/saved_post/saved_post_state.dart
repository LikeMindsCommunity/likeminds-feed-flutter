part of 'saved_post_bloc.dart';

abstract class LMFeedSavedPostState extends Equatable {
  @override
  List<Object> get props => [];
}

final class LMFeedSavedPostInitialState extends LMFeedSavedPostState {}

final class LMFeedSavedPostLoadingState extends LMFeedSavedPostState {}

final class LMFeedSavedPostPaginationLoadingState extends LMFeedSavedPostState {}

final class LMFeedSavedPostLoadedState extends LMFeedSavedPostState {
  final List<LMPostViewData> posts;
  LMFeedSavedPostLoadedState({required this.posts});
  @override
  List<Object> get props => [posts];
}

final class LMFeedSavedPostErrorState extends LMFeedSavedPostState {
  final String errorMessage;
  LMFeedSavedPostErrorState({required this.errorMessage});
  @override
  List<Object> get props => [errorMessage];
}
