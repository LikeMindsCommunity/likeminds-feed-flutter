part of 'notification_bloc.dart';

abstract class LMFeedNotificationsState extends Equatable {
  const LMFeedNotificationsState();

  @override
  List<Object> get props => [];
}

class LMFeedNotificationsInitialState extends LMFeedNotificationsState {}

class LMFeedNotificationsLoadingState extends LMFeedNotificationsState {}

class LMFeedNotificationsPaginationLoadingState extends LMFeedNotificationsState {}

class LMFeedNotificationsLoadedState extends LMFeedNotificationsState {
  final List<LMNotificationFeedItemViewData> response;

  const LMFeedNotificationsLoadedState({required this.response});

  @override
  List<Object> get props => [response];
}

class LMFeedNotificationsErrorState extends LMFeedNotificationsState {
  final String message;
  const LMFeedNotificationsErrorState({required this.message});

  @override
  List<Object> get props => [message];
}
