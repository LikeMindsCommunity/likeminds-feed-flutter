part of 'notification_bloc.dart';

abstract class LMFeedNotificationsEvent extends Equatable {
  const LMFeedNotificationsEvent();

  @override
  List<Object> get props => [];
}

class LMFeedGetNotificationsEvent extends LMFeedNotificationsEvent {
  final int offset;
  final int pageSize;

  const LMFeedGetNotificationsEvent({
    required this.offset,
    required this.pageSize,
  });

  @override
  List<Object> get props => [offset, pageSize];
}

class LMFeedMarkNotificationAsReadEvent extends LMFeedNotificationsEvent {
  final String activityId;
  final BuildContext context;

  const LMFeedMarkNotificationAsReadEvent({
    required this.activityId,
    required this.context,
  });

  @override
  List<Object> get props => [activityId];
}
