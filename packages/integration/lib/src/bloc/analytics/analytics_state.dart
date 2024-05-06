part of 'analytics_bloc.dart';

/// {@template lm_fire_analytic_state}
/// LMFeedAnalyticsState defines the states which are emitted by LMFeedAnalyticsBloc.
/// {@endtemplate}
abstract class LMFeedAnalyticsState extends Equatable {
  const LMFeedAnalyticsState();

  @override
  List<Object> get props => [];
}

/// {@template lm_analytics_initiated_state}
/// LMFeedAnalyticsInitiated defines the state when LMFeedAnalyticsBloc is initiated.
/// {@endtemplate}
class LMFeedAnalyticsInitiated extends LMFeedAnalyticsState {}

/// {@template lm_analytics_event_fired_state}
/// LMFeedAnalyticsEventFired defines the state when an analytics event is fired.
/// [eventName] of type String defines the name of the event fired.
/// [eventProperties] of type Map<String, dynamic> defines the properties
/// of the event fired.
/// {@endtemplate}
class LMFeedAnalyticsEventFired extends LMFeedAnalyticsState {
  // Name of the event fired
  final String eventName;
  // Properties of the event fired
  // i.e. likes count, post id, etc.
  final Map<String, dynamic> eventProperties;

  /// {@macro lm_feed_widget_source}
  final LMFeedWidgetSource? widgetSource;

  const LMFeedAnalyticsEventFired({
    required this.eventName,
    required this.eventProperties,
    this.widgetSource,
  });

  @override
  List<Object> get props => [
        eventName,
        eventProperties,
        identityHashCode(this),
      ];
}
