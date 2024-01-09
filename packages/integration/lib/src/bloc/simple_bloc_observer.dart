import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LMFeedBlocObserver extends BlocObserver {
  @override
  void onEvent(Bloc bloc, Object? event) {
    debugPrint("LMBlocObserver event - $event");
    super.onEvent(bloc, event);
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
  }

  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint("LMBlocObserver error - ${error.toString()}");
    super.onError(bloc, error, stackTrace);
  }
}
