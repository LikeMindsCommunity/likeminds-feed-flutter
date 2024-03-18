part of 'topic_bloc.dart';

abstract class LMFeedTopicState {}

class LMFeedTopicInitialState extends LMFeedTopicState {}

class LMFeedTopicLoadingState extends LMFeedTopicState {}

class LMFeedTopicErrorState extends LMFeedTopicState {
  final String errorMessage;

  LMFeedTopicErrorState(this.errorMessage);
}

class LMFeedTopicLoadedState extends LMFeedTopicState {
  final GetTopicsResponse getTopicFeedResponse;
  final int page;

  LMFeedTopicLoadedState(this.getTopicFeedResponse, this.page);
}
