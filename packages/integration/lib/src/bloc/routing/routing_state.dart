part of 'routing_bloc.dart';

abstract class LMRoutingState extends Equatable {
  const LMRoutingState();

  @override
  List<Object> get props => [];
}

class LMRoutingStateInit extends LMRoutingState {}

class LMOpenSharedPost extends LMRoutingState {
  final String postId;

  const LMOpenSharedPost({required this.postId});

  @override
  List<Object> get props => [postId];
}

class LMOpenPostNotification extends LMRoutingState {
  final String postId;

  const LMOpenPostNotification({required this.postId});

  @override
  List<Object> get props => [postId];
}

class ErrorSharedPost extends LMRoutingState {
  final String message;
  final String postId;

  const ErrorSharedPost({required this.message, required this.postId});

  @override
  List<Object> get props => [message];
}

class ErrorPostNotification extends LMRoutingState {
  final String message;
  final String postId;

  const ErrorPostNotification({required this.message, required this.postId});

  @override
  List<Object> get props => [message];
}
