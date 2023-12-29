part of 'topic_bloc.dart';

abstract class LMTopicEvent extends Equatable {}

class LMInitTopicEvent extends LMTopicEvent {
  @override
  List<Object> get props => [];
}

class LMGetTopic extends LMTopicEvent {
  final GetTopicsRequest getTopicFeedRequest;

  LMGetTopic({required this.getTopicFeedRequest});

  @override
  List<Object> get props => [getTopicFeedRequest.toJson()];
}

class LMRefreshTopicEvent extends LMTopicEvent {
  @override
  List<Object> get props => [];
}
