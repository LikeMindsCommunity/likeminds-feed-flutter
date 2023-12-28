part of 'analytics_bloc.dart';

/// {@template lm_fire_analytic_state}
/// LMAnalyticsState defines the states which are emitted by LMAnalyticsBloc.
abstract class LMAnalyticsState extends Equatable {
  const LMAnalyticsState();

  @override
  List<Object> get props => [];
}

/// {@template lm_analytics_initiated_state}
/// LMAnalyticsInitiated defines the state when LMAnalyticsBloc is initiated.
/// {@endtemplate}
class LMAnalyticsInitiated extends LMAnalyticsState {}

/// {@template lm_analytics_event_fired_state}
/// LMAnalyticsEventFired defines the state when an analytics event is fired.
/// [eventName] of type String defines the name of the event fired.
/// [eventProperties] of type Map<String, dynamic> defines the properties
/// of the event fired.
/// {@endtemplate}
class LMAnalyticsEventFired extends LMAnalyticsState {
  // Name of the event fired
  final String eventName;
  // Properties of the event fired
  // i.e. likes count, post id, etc.
  final Map<String, dynamic> eventProperties;

  const LMAnalyticsEventFired({
    required this.eventName,
    required this.eventProperties,
  });

  @override
  List<Object> get props => [eventName, eventProperties];
}
