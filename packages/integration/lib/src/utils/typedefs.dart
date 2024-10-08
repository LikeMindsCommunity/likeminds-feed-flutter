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

/// {@template context_button_builder}
/// Button builder function for [BuildContext]
/// Takes [BuildContext] and [LMFeedButton] as parameters and returns [Widget]
/// {@endtemplate}
typedef LMFeedContextButtonBuilder = Widget Function(
    BuildContext, LMFeedButton);

/// {@template lm_feed_tile_builder}
/// Tile builder function for [LMFeedTile]
/// Takes [BuildContext] and [LMFeedTile] as parameters and returns [Widget]
/// {@endtemplate}
typedef LMFeedTileBuilder = Widget Function(BuildContext, LMFeedTile);

/// {@template lm_feed_custom_widget_builder}
/// Custom widget builder function for [LMFeedPostSomething]
/// Takes [BuildContext] and [LMFeedPostSomething] as parameters and returns [Widget]
/// {@endtemplate}
typedef LMFeedCustomWidgetBuilder = Widget Function(
    BuildContext context, LMFeedPostSomething postSomethingWidget);

/// {@template lm_feed_reply_widget_builder}
/// Reply widget builder function for [LMFeedCommentReplyWidget]
/// Takes [BuildContext] and [LMFeedCommentReplyWidget] as parameters and returns [Widget]
/// {@endtemplate}
typedef LMFeedReplyWidgetBuilder = Widget Function(
    BuildContext context, LMFeedCommentReplyWidget replyWidget);

/// {@template lm_feed_comment_list_builder}
/// Comment list builder function for [LMFeedCommentList]
/// Takes [BuildContext] and [LMFeedCommentList] as parameters and returns [Widget]
/// {@endtemplate}
typedef LMFeedCommentListBuilder = Widget Function(
    BuildContext context, LMFeedCommentList commentListWidget);
