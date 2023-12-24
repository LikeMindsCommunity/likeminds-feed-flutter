import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';
part 'handler/fire_analytics_event_handler.dart';

class LMAnalyticsBloc extends Bloc<LMAnalyticsEvent, LMAnalyticsState> {
  static LMAnalyticsBloc? _lmAnalyticsBloc;

  static LMAnalyticsBloc get instance =>
      _lmAnalyticsBloc ??= LMAnalyticsBloc._();

  LMAnalyticsBloc._() : super(AnalyticsInitiated()) {
    on<FireAnalyticEvent>(fireAnalyticsEventHandler);
  }
}
