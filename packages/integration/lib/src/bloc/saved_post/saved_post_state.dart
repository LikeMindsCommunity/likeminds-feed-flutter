part of 'saved_post_bloc.dart';

abstract class LMFeedSavedPostState extends Equatable {
  @override
  List<Object> get props => [];
}

final class LMFeedSavedPostInitialState extends LMFeedSavedPostState {}

final class LMFeedSavedPostLoadingState extends LMFeedSavedPostState {}

final class LMFeedSavedPostLoadedState extends LMFeedSavedPostState {
  final int page;
  final List<LMPostViewData> posts;
  LMFeedSavedPostLoadedState({required this.posts, required this.page});
  @override
  List<Object> get props => [posts, page];
}

final class LMFeedSavedPostErrorState extends LMFeedSavedPostState {
  final String errorMessage;
  final StackTrace stackTrace;
  LMFeedSavedPostErrorState({
    required this.errorMessage,
    required this.stackTrace,
  });
  @override
  List<Object> get props => [errorMessage, stackTrace];
}
