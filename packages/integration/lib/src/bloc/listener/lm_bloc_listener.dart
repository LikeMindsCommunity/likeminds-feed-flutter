import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/routing/routing_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/simple_bloc_observer.dart';
import 'package:likeminds_feed_flutter_core/src/utils/typedefs.dart';

/// {@template lm_bloc_listener}
/// This is the main class that needs to be initialized before using the SDK.
/// LMBlocListener is a wrapper class that wraps the child widget with MultiBlocListener.
/// This class is responsible for listening to the following blocs:
/// 1. LMFeedAnalyticsBloc
/// 2. LMRoutingBloc
/// 3. LMProfileBloc
/// {@endtemplate}
class LMFeedBlocListener extends StatefulWidget {
  final Widget child;
  // {@macro lm_analytics_bloc_listener}
  final LMFeedAnalyticsBlocListener analyticsListener;
  // {@macro lm_routing_bloc_listener}
  final LMFeedRoutingBlocListener routingListener;
  // {@macro lm_profile_bloc_listener}
  final LMFeedProfileBlocListener profileListener;

  /// {@macro lm_bloc_listener}
  const LMFeedBlocListener({
    super.key,
    required this.child,
    required this.analyticsListener,
    required this.profileListener,
    required this.routingListener,
  });

  @override
  State<LMFeedBlocListener> createState() => _LMFeedBlocListenerState();
}

class _LMFeedBlocListenerState extends State<LMFeedBlocListener> {
  @override
  void initState() {
    super.initState();
    Bloc.observer = LMFeedBlocObserver();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener(
          listener: widget.profileListener,
          bloc: LMFeedProfileBloc.instance,
        ),
        BlocListener(
          listener: widget.analyticsListener,
          bloc: LMFeedAnalyticsBloc.instance,
        ),
        BlocListener(
          listener: widget.routingListener,
          bloc: LMFeedRoutingBloc.instance,
        ),
      ],
      child: widget.child,
    );
  }
}
