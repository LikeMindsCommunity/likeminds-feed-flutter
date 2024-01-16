import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/routing/routing_bloc.dart';

/// {@template lm_analytics_bloc_listener}
/// State changes listener function for [LMFeedAnalyticsBloc]
/// takes [BuildContext] and [LMFeedAnalyticsState] as parameters
/// and returns [Widget]
/// {@endtemplate}
typedef LMFeedAnalyticsBlocListener = Widget Function(
    BuildContext context, LMFeedAnalyticsState state);

/// {@template lm_routing_bloc_listener}
/// State changes listener function for [LMFeedRoutingBloc]
/// takes [BuildContext] and [LMFeedRoutingState] as parameters
/// and returns [Widget]
/// {@endtemplate}
typedef LMFeedRoutingBlocListener = Widget Function(
    BuildContext context, LMFeedRoutingState state);

/// {@template lm_profile_bloc_listener}
/// State changes listener function for [LMFeedProfileBloc]
/// takes [BuildContext] and [LMFeedProfileState] as parameters
/// and returns [Widget]
/// {@endtemplate}
typedef LMFeedProfileBlocListener = Widget Function(
    BuildContext context, LMFeedProfileState state);

/// {@template context_widget_builder}
/// Widget builder function for [BuildContext]
/// Takes [BuildContext] as parameter and returns [Widget]
/// {@endtemplate}
typedef LMFeedContextWidgetBuilder = Widget Function(BuildContext context);
