part of 'routing_bloc.dart';

abstract class LMRoutingEvent extends Equatable {
  const LMRoutingEvent();

  @override
  List<Object> get props => [];
}

class LMRoutingEventInit extends LMRoutingEvent {}

class LMHandleSharedPostEvent extends LMRoutingEvent {
  final String postId;

  const LMHandleSharedPostEvent({required this.postId});

  @override
  List<Object> get props => [postId];
}

class LMHandlePostNotificationEvent extends LMRoutingEvent {
  final String postId;

  const LMHandlePostNotificationEvent({required this.postId});

  @override
  List<Object> get props => [postId];
}
