import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';
part 'handler/fire_analytics_event_handler.dart';

/// {@template lm_analytics_bloc}
/// LMAnalyticsBloc handle all the analytics related actions
/// like fire analytics event.
/// LMAnalyticsEvent defines the events which are handled by this bloc.
/// LMAnalyticsState defines the states which are emitted by this bloc
/// {@endtemplate}
class LMAnalyticsBloc extends Bloc<LMAnalyticsEvent, LMAnalyticsState> {
  /// {@macro lm_analytics_bloc}
  static LMAnalyticsBloc? _lmAnalyticsBloc;

  /// {@macro lm_analytics_bloc}
  static LMAnalyticsBloc get instance =>
      _lmAnalyticsBloc ??= LMAnalyticsBloc._();

  LMAnalyticsBloc._() : super(LMAnalyticsInitiated()) {
    on<LMFireAnalyticsEvent>(fireAnalyticsEventHandler);
  }
}
