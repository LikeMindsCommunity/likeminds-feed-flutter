part of 'moderation_bloc.dart';

abstract class LMFeedModerationState extends Equatable {
  const LMFeedModerationState();

  @override
  List<Object> get props => [];
}

final class LMFeedReportInitialState extends LMFeedModerationState {}

final class LMFeedReportLoadingState extends LMFeedModerationState {}

final class LMFeedReportSuccessState extends LMFeedModerationState {
  final List<LMDeleteReasonViewData> reasons;
  LMFeedReportSuccessState({required this.reasons});
  @override
  List<Object> get props => [reasons];
}

final class LMFeedReportFailureState extends LMFeedModerationState {
  final String error;

  const LMFeedReportFailureState({required this.error});

  @override
  List<Object> get props => [error];
}

final class LMFeedReportReasonSelectedState extends LMFeedModerationState {
  final LMDeleteReasonViewData reason;

  const LMFeedReportReasonSelectedState({required this.reason});

  @override
  List<Object> get props => [reason];
}

final class LMFeedReportSubmittedState extends LMFeedModerationState {}

final class LMFeedReportSubmitFailedState extends LMFeedModerationState {
  final String error;

  const LMFeedReportSubmitFailedState({required this.error});

  @override
  List<Object> get props => [error];
}
