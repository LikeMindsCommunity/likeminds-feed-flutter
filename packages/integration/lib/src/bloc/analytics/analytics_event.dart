part of 'analytics_bloc.dart';

/// {@template lm_analytics_event}
/// LMFeedAnalyticsEvent defines the events which are handled by LMFeedAnalyticsBloc.
/// {@endtemplate}
abstract class LMFeedAnalyticsEvent extends Equatable {
  /// {@macro lm_analytics_event}
  const LMFeedAnalyticsEvent();

  @override
  List<Object> get props => [];
}

/// {@template lm_init_analytic_event}
/// LMFeedInitAnalyticsEvent defines the event to initiate LMFeedAnalyticsBloc.
/// {@endtemplate}
class LMFeedInitAnalyticsEvent extends LMFeedAnalyticsEvent {}

/// {@template lm_fire_analytic_event}
/// LMFeedFireAnalyticsEvent defines the event to fire an analytics event.
/// [eventName] of type String defines the name of the event to be fired.
/// [eventProperties] of type Map<String, dynamic> defines the properties
/// of the event to be fired.
/// {@endtemplate}
class LMFeedFireAnalyticsEvent extends LMFeedAnalyticsEvent {
  // Name of the event to be fired
  // i.e. post_liked, etc.
  final String eventName;
  // Properties of the event to be fired
  // i.e. likes count, post id, etc.
  final Map<String, dynamic> eventProperties;

  /// {@macro lm_fire_analytic_event}
  const LMFeedFireAnalyticsEvent({
    required this.eventName,
    required this.eventProperties,
  });

  @override
  List<Object> get props => [eventName, eventProperties];
}
