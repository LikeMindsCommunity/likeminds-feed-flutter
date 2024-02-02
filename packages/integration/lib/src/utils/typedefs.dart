import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

/// {@template lm_analytics_bloc_listener}
/// State changes listener function for [LMFeedAnalyticsBloc]
/// takes [BuildContext] and [LMFeedAnalyticsState] as parameters
/// and returns [Widget]
/// {@endtemplate}
typedef LMFeedAnalyticsBlocListener = Function(
    BuildContext context, LMFeedAnalyticsState state);

/// {@template lm_routing_bloc_listener}
/// State changes listener function for [LMFeedRoutingBloc]
/// takes [BuildContext] and [LMFeedRoutingState] as parameters
/// and returns [Widget]
/// {@endtemplate}
typedef LMFeedRoutingBlocListener = Function(
    BuildContext context, LMFeedRoutingState state);

/// {@template lm_profile_bloc_listener}
/// State changes listener function for [LMFeedProfileBloc]
/// takes [BuildContext] and [LMFeedProfileState] as parameters
/// and returns [Widget]
/// {@endtemplate}
typedef LMFeedProfileBlocListener = Function(
    BuildContext context, LMFeedProfileState state);

/// {@template context_widget_builder}
/// Widget builder function for [BuildContext]
/// Takes [BuildContext] as parameter and returns [Widget]
/// {@endtemplate}
typedef LMFeedContextWidgetBuilder = Widget Function(BuildContext context);
