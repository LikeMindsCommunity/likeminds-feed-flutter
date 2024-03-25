part of '../moderation_bloc.dart';

void fetchReportReasonEventHandler(
    LMFeedModerationEvent event, Emitter<LMFeedModerationState> emit) async {
  final request = (GetDeleteReasonRequestBuilder()..type(3)).build();
  GetDeleteReasonResponse response =
      await LMFeedCore.client.getReportTags(request);
  if (response.success) {
    List<LMDeleteReasonViewData> reasons = response.reportTags
            ?.map((reason) => LMDeleteReasonConvertor.fromDeleteReason(reason))
            .toList() ??
        [];
    emit(LMFeedReportSuccessState(reasons: reasons));
  } else {
    emit(LMFeedReportFailureState(
        error: response.errorMessage ?? 'An error occurred'));
  }
}
