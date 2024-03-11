part of 'moderation_bloc.dart';

abstract class LMFeedModerationState extends Equatable {
  const LMFeedModerationState();

  @override
  List<Object> get props => [];
}

class LMFeedModerationInitialState extends LMFeedModerationState {}

class LMFeedNotificationsLoadingState extends LMFeedModerationState {}

class LMFeedNotificationsPaginationLoadingState extends LMFeedModerationState {}

class LMFeedNotificationsLoadedState extends LMFeedModerationState {
  final List<LMNotificationFeedItemViewData> response;

  const LMFeedNotificationsLoadedState({required this.response});

  @override
  List<Object> get props => [response];
}

class LMFeedNotificationsErrorState extends LMFeedModerationState {
  final String message;
  const LMFeedNotificationsErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
