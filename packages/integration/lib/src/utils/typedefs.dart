import 'package:flutter/material.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/routing/routing_bloc.dart';

/// {@template lm_analytics_bloc_listener}
/// State changes listener function for [LMAnalyticsBloc]
/// takes [BuildContext] and [LMAnalyticsState] as parameters
/// and returns [Widget]
/// {@endtemplate}
typedef LMAnalyticsBlocListener = Widget Function(
    BuildContext context, LMAnalyticsState state);

/// {@template lm_routing_bloc_listener}
/// State changes listener function for [LMRoutingBloc]
/// takes [BuildContext] and [LMRoutingState] as parameters
/// and returns [Widget]
/// {@endtemplate}
typedef LMRoutingBlocListener = Widget Function(
    BuildContext context, LMRoutingState state);

/// {@template lm_profile_bloc_listener}
/// State changes listener function for [LMProfileBloc]
/// takes [BuildContext] and [LMProfileState] as parameters
/// and returns [Widget]
/// {@endtemplate}
typedef LMProfileBlocListener = Widget Function(
    BuildContext context, LMProfileState state);

/// {@template context_widget_builder}
/// Widget builder function for [BuildContext]
/// Takes [BuildContext] as parameter and returns [Widget]
/// {@endtemplate}
typedef LMContextWidgetBuilder = Widget Function(BuildContext context);
