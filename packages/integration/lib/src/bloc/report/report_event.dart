part of 'report_bloc.dart';

abstract class LMFeedReportEvent extends Equatable {
  const LMFeedReportEvent();

  @override
  List<Object> get props => [];
}

class LMReportFetchEvent extends LMFeedReportEvent {
  LMReportFetchEvent();
}

class LMReportReasonSelectEvent extends LMFeedReportEvent {
  final LMDeleteReasonViewData reason;

  LMReportReasonSelectEvent({required this.reason});

  @override
  List<Object> get props => [reason];
}

class LMReportSubmitEvent extends LMFeedReportEvent {
  final String entityCreatorId;
  final String entityId;
  final int entityType;
  final String reason;
  final int tagId;

  LMReportSubmitEvent({
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
