part of '../moderation_bloc.dart';

void reportSubmitEventHandler(
    LMFeedReportSubmitEvent event, Emitter<LMFeedModerationState> emit) async {
  emit(LMFeedReportLoadingState());
  PostReportRequest postReportRequest = (PostReportRequestBuilder()
        ..entityCreatorId(event.entityCreatorId)
        ..entityId(event.entityId)
        ..entityType(event.entityType)
        ..reason(event.reason)
        ..tagId(event.tagId))
      .build();
  PostReportResponse response =
      await LMFeedCore.client.postReport(postReportRequest);
  if (response.success) {
    emit(LMFeedReportSubmittedState());
  } else {
    emit(LMFeedReportSubmitFailedState(
        error: response.errorMessage ?? 'An error occurred'));
  }
}
