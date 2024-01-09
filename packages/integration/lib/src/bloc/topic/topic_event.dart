part of 'topic_bloc.dart';

abstract class LMFeedTopicEvent extends Equatable {}

class LMFeedInitTopicEvent extends LMFeedTopicEvent {
  @override
  List<Object> get props => [];
}

class LMFeedGetTopicEvent extends LMFeedTopicEvent {
  final GetTopicsRequest getTopicFeedRequest;

  LMFeedGetTopicEvent({required this.getTopicFeedRequest});

  @override
  List<Object> get props => [getTopicFeedRequest.toJson()];
}

class LMFeedRefreshTopicEvent extends LMFeedTopicEvent {
  @override
  List<Object> get props => [];
}
