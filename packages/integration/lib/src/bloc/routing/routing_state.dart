part of 'routing_bloc.dart';

abstract class LMFeedRoutingState extends Equatable {
  const LMFeedRoutingState();

  @override
  List<Object> get props => [];
}

class LMFeedRoutingStateInitState extends LMFeedRoutingState {}

class LMFeedOpenSharedPostState extends LMFeedRoutingState {
  final String postId;

  const LMFeedOpenSharedPostState({required this.postId});

  @override
  List<Object> get props => [postId];
}

class LMFeedOpenPostNotificationState extends LMFeedRoutingState {
  final String postId;

  const LMFeedOpenPostNotificationState({required this.postId});

  @override
  List<Object> get props => [postId];
}

class LMFeedErrorSharedPostState extends LMFeedRoutingState {
  final String message;
  final String postId;

  const LMFeedErrorSharedPostState(
      {required this.message, required this.postId});

  @override
  List<Object> get props => [message];
}

class LMFeedErrorPostNotificationState extends LMFeedRoutingState {
  final String message;
  final String postId;

  const LMFeedErrorPostNotificationState(
      {required this.message, required this.postId});

  @override
  List<Object> get props => [message];
}
