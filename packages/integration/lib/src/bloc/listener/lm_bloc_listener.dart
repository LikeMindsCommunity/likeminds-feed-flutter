import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/analytics_bloc/analytics_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/profile_bloc/profile_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/routing_bloc/routing_bloc.dart';
import 'package:likeminds_feed_driver_fl/src/bloc/simple_bloc_observer.dart';

class LMBlocListener extends StatefulWidget {
  final Widget child;
  final Function(BuildContext, LMAnalyticsState) analyticsListener;
  final Function(BuildContext, LMRoutingState) routingListener;
  final Function(BuildContext, LMProfileState) profileListener;

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
    Bloc.observer = SimpleBlocObserver();
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
