part of 'moderation_bloc.dart';

abstract class LMFeedModerationEvent extends Equatable {
  const LMFeedModerationEvent();

  @override
  List<Object> get props => [];
}

class LMFeedGetNotificationsEvent extends LMFeedModerationEvent {
  final int offset;
  final int pageSize;

  const LMFeedGetNotificationsEvent({
    required this.offset,
    required this.pageSize,
  });

  @override
  List<Object> get props => [offset, pageSize];
}

class LMFeedMarkNotificationAsReadEvent extends LMFeedModerationEvent {
  final String activityId;

  const LMFeedMarkNotificationAsReadEvent({
    required this.activityId,
  });

  @override
  List<Object> get props => [activityId];
}