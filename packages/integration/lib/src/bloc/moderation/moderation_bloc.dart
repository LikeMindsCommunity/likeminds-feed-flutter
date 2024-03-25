import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'moderation_event.dart';
part 'moderation_state.dart';

part 'handler/fetch_report_reason_event_handler.dart';
part 'handler/report_submit_event_handler.dart';
part 'handler/report_reason_selected_event_handler.dart';

class LMFeedModerationBloc
    extends Bloc<LMFeedModerationEvent, LMFeedModerationState> {
  LMFeedModerationBloc() : super(LMFeedReportInitialState()) {
    on<LMFeedReportReasonFetchEvent>(fetchReportReasonEventHandler);
    on<LMFeedReportReasonSelectEvent>(reportReasonSelectedEventHandler);
    on<LMFeedReportSubmitEvent>(reportSubmitEventHandler);
  }
}
