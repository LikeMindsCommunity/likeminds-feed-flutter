part of 'report_bloc.dart';

abstract class LMFeedReportState extends Equatable {
  const LMFeedReportState();

  @override
  List<Object> get props => [];
}

final class LMFeedReportInitialState extends LMFeedReportState {}

final class LMFeedReportLoadingState extends LMFeedReportState {}

final class LMFeedReportSuccessState extends LMFeedReportState {
  final List<LMDeleteReasonViewData> reasons;
  LMFeedReportSuccessState({required this.reasons});
  @override
  List<Object> get props => [reasons];
}

final class LMFeedReportFailureState extends LMFeedReportState {

  final String error;

  const LMFeedReportFailureState({required this.error});

  @override
  List<Object> get props => [error];
}

final class LMFeedReportReasonSelectedState extends LMFeedReportState {
  final LMDeleteReasonViewData reason;

  const LMFeedReportReasonSelectedState({required this.reason});

  @override
  List<Object> get props => [reason];
}

final class LMFeedReportSubmittedState extends LMFeedReportState {}

final class LMFeedReportSubmitFailedState extends LMFeedReportState {
  final String error;

  const LMFeedReportSubmitFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
