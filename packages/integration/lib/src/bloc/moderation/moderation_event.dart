part of 'moderation_bloc.dart';

abstract class LMFeedModerationEvent extends Equatable {
  const LMFeedModerationEvent();

  @override
  List<Object> get props => [];
}

class LMFeedReportReasonFetchEvent extends LMFeedModerationEvent {
  LMFeedReportReasonFetchEvent();
}

class LMFeedReportReasonSelectEvent extends LMFeedModerationEvent {
  final LMDeleteReasonViewData reason;

  LMFeedReportReasonSelectEvent({required this.reason});

  @override
  List<Object> get props => [reason];
}

class LMFeedReportSubmitEvent extends LMFeedModerationEvent {
  final String entityCreatorId;
  final String entityId;
  final int entityType;
  final String reason;
  final int tagId;

  LMFeedReportSubmitEvent({
    required this.entityCreatorId,
    required this.entityId,
    required this.entityType,
    required this.reason,
    required this.tagId,
  });

  @override
  List<Object> get props =>
      [entityCreatorId, entityId, entityType, reason, tagId];
}
