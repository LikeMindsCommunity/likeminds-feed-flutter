part of 'topic_bloc.dart';

abstract class LMTopicState {}

class LMTopicInitial extends LMTopicState {}

class LMTopicLoading extends LMTopicState {}

class LMTopicError extends LMTopicState {
  final String errorMessage;

  LMTopicError(this.errorMessage);
}

class LMTopicLoaded extends LMTopicState {
  final GetTopicsResponse getTopicFeedResponse;

  LMTopicLoaded(this.getTopicFeedResponse);
}
