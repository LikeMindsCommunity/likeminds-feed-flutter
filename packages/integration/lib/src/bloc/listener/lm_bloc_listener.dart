import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/profile/profile_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/routing/routing_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/simple_bloc_observer.dart';
import 'package:likeminds_feed_driver_fl/src/utils/typedefs.dart';

/// {@template lm_bloc_listener}
/// This is the main class that needs to be initialized before using the SDK.
/// LMBlocListener is a wrapper class that wraps the child widget with MultiBlocListener.
/// This class is responsible for listening to the following blocs:
/// 1. LMAnalyticsBloc
/// 2. LMRoutingBloc
/// 3. LMProfileBloc
/// {@endtemplate}
class LMBlocListener extends StatefulWidget {
  final Widget child;
  // {@macro lm_analytics_bloc_listener}
  final LMAnalyticsBlocListener analyticsListener;
  // {@macro lm_routing_bloc_listener}
  final LMRoutingBlocListener routingListener;
  // {@macro lm_profile_bloc_listener}
  final LMProfileBlocListener profileListener;

  /// {@macro lm_bloc_listener}
  const LMBlocListener({
    super.key,
    required this.child,
    required this.analyticsListener,
    required this.profileListener,
    required this.routingListener,
  });

  @override
  State<LMBlocListener> createState() => _LMBlocListenerState();
}

class _LMBlocListenerState extends State<LMBlocListener> {
  @override
  void initState() {
    super.initState();
    Bloc.observer = LMSimpleBlocObserver();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener(
          listener: widget.profileListener,
          bloc: LMProfileBloc.instance,
        ),
        BlocListener(
          listener: widget.analyticsListener,
          bloc: LMAnalyticsBloc.instance,
        ),
        BlocListener(
          listener: widget.routingListener,
          bloc: LMRoutingBloc.instance,
        ),
      ],
      child: widget.child,
    );
  }
}
