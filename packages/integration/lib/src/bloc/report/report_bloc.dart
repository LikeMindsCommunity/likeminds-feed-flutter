import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'report_event.dart';
part 'report_state.dart';

class LMFeedReportBloc extends Bloc<LMFeedReportEvent, LMFeedReportState> {
  LMFeedReportBloc() : super(LMFeedReportInitialState()) {
    on<LMReportFetchEvent>((event, emit) => _mapReportFetchEventToState(emit));
    on<LMReportReasonSelectEvent>(
        (event, emit) => _mapReportReasonSelectEventToState(event, emit));
    on<LMReportSubmitEvent>(
        (event, emit) => _mapReportSubmitEventToState(event, emit));
  }

  _mapReportFetchEventToState(Emitter<LMFeedReportState> emit) async {
    emit(LMFeedReportLoadingState());
    GetDeleteReasonRequest request =
        (GetDeleteReasonRequestBuilder()..type(3)).build();
    final getReportTagsFuture = await LMFeedCore.client.getReportTags(request);
    if (getReportTagsFuture.success) {
      final reasonViewDataList = getReportTagsFuture.reportTags
          ?.map((e) => LMDeleteReasonConvertor.fromDeleteReason(e))
          .toList();
      emit(LMFeedReportSuccessState(reasons: reasonViewDataList ?? []));
    } else {
      emit(LMFeedReportFailureState(
          error: getReportTagsFuture.errorMessage ?? 'An error occurred'));
    }
  }

  _mapReportReasonSelectEventToState(
      LMReportReasonSelectEvent event, Emitter<LMFeedReportState> emit) {
    emit(LMFeedReportReasonSelectedState(reason: event.reason));
  }

  _mapReportSubmitEventToState(
      LMReportSubmitEvent event, Emitter<LMFeedReportState> emit) async {
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
}
