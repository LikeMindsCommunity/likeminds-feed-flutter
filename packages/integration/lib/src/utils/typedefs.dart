import 'package:flutter/material.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/routing/routing_bloc.dart';

/// {@template lm_analytics_bloc_listener}
/// State changes listener function for [LMAnalyticsBloc]
/// {@endtemplate}
typedef LMAnalyticsBlocListener = Widget Function(
    BuildContext context, LMAnalyticsState state);

/// {@template lm_routing_bloc_listener}
/// State changes listener function for [LMRoutingBloc]
/// {@endtemplate}
typedef LMRoutingBlocListener = Widget Function(
    BuildContext context, LMRoutingState state);

/// {@template lm_profile_bloc_listener}
/// State changes listener function for [LMProfileBloc]
/// {@endtemplate}
typedef LMProfileBlocListener = Widget Function(
    BuildContext context, LMProfileState state);
