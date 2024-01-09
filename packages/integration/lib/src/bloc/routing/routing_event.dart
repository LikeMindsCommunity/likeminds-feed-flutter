part of 'routing_bloc.dart';

abstract class LMFeedRoutingEvent extends Equatable {
  const LMFeedRoutingEvent();

  @override
  List<Object> get props => [];
}

class LMFeedRoutingEventInitState extends LMFeedRoutingEvent {}

class LMFeedHandleSharedPostEvent extends LMFeedRoutingEvent {
  final String postId;

  const LMFeedHandleSharedPostEvent({required this.postId});

  @override
  List<Object> get props => [postId];
}

class LMFeedHandlePostNotificationEvent extends LMFeedRoutingEvent {
  final String postId;

  const LMFeedHandlePostNotificationEvent({required this.postId});

  @override
  List<Object> get props => [postId];
}
