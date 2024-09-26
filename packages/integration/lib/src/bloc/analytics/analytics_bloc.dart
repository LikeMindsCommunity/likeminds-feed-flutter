import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'analytics_event.dart';
part 'analytics_state.dart';
part 'handler/fire_analytics_event_handler.dart';

/// {@template lm_analytics_bloc}
/// LMFeedAnalyticsBloc handle all the analytics related actions
/// like fire analytics event.
/// LMFeedAnalyticsEvent defines the events which are handled by this bloc.
/// LMFeedAnalyticsState defines the states which are emitted by this bloc
/// {@endtemplate}
class LMFeedAnalyticsBloc
    extends Bloc<LMFeedAnalyticsEvent, LMFeedAnalyticsState> {
  /// {@macro lm_analytics_bloc}
  static LMFeedAnalyticsBloc? _lmAnalyticsBloc;

  /// {@macro lm_analytics_bloc}
  static LMFeedAnalyticsBloc get instance =>
      _lmAnalyticsBloc == null || _lmAnalyticsBloc!.isClosed
          ? _lmAnalyticsBloc = LMFeedAnalyticsBloc._()
          : _lmAnalyticsBloc!;

  LMFeedAnalyticsBloc._() : super(LMFeedAnalyticsInitiated()) {
    on<LMFeedFireAnalyticsEvent>(fireAnalyticsEventHandler);
  }
}
