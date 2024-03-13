part of '../moderation_bloc.dart';
 
  reportReasonSelectedEventHandler(
      LMFeedReportReasonSelectEvent event, Emitter<LMFeedModerationState> emit) {
    emit(LMFeedReportReasonSelectedState(reason: event.reason));
  }