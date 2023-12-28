part of 'analytics_bloc.dart';

/// {@template lm_analytics_event}
/// LMAnalyticsEvent defines the events which are handled by LMAnalyticsBloc.
/// {@endtemplate}
abstract class LMAnalyticsEvent extends Equatable {
  /// {@macro lm_analytics_event}
  const LMAnalyticsEvent();

  @override
  List<Object> get props => [];
}

/// {@template lm_init_analytic_event}
/// LMInitAnalyticsEvent defines the event to initiate LMAnalyticsBloc.
/// {@endtemplate}
class LMInitAnalyticsEvent extends LMAnalyticsEvent {}

/// {@template lm_fire_analytic_event}
/// LMFireAnalyticsEvent defines the event to fire an analytics event.
/// [eventName] of type String defines the name of the event to be fired.
/// [eventProperties] of type Map<String, dynamic> defines the properties
/// of the event to be fired.
/// {@endtemplate}
class LMFireAnalyticsEvent extends LMAnalyticsEvent {
  // Name of the event to be fired
  // i.e. post_liked, etc.
  final String eventName;
  // Properties of the event to be fired
  // i.e. likes count, post id, etc.
  final Map<String, dynamic> eventProperties;

  /// {@macro lm_fire_analytic_event}
  const LMFireAnalyticsEvent({
    required this.eventName,
    required this.eventProperties,
  });

  @override
  List<Object> get props => [eventName, eventProperties];
}
