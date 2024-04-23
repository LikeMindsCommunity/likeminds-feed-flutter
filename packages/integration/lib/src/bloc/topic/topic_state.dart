part of 'topic_bloc.dart';

abstract class LMFeedTopicState extends Equatable {
  @override
  List<Object> get props => [];
}

class LMFeedTopicInitialState extends LMFeedTopicState {}

class LMFeedTopicLoadingState extends LMFeedTopicState {}

class LMFeedTopicPaginationLoadingState extends LMFeedTopicState {}

class LMFeedTopicErrorState extends LMFeedTopicState {
  final String errorMessage;

  LMFeedTopicErrorState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

class LMFeedTopicLoadedState extends LMFeedTopicState {
  final GetTopicsResponse getTopicFeedResponse;
  final int page;

  LMFeedTopicLoadedState(this.getTopicFeedResponse, this.page);

  @override
  List<Object> get props => [page, getTopicFeedResponse];
}
