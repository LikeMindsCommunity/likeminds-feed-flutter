import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'personalised_feed_event.dart';
part 'personalised_feed_state.dart';
part 'handler/get_feed_handler.dart';
part 'handler/refresh_feed_handler.dart';
part 'handler/seen_post_handler.dart';

/// {@template lm_feed_personalised_bloc}
/// Bloc for handling personalised feed
/// {@endtemplate}
class LMFeedPersonalisedBloc
    extends Bloc<LMFeedPersonalisedEvent, LMFeedPersonalisedState> {
  static LMFeedPersonalisedBloc? _instance;
  static LMFeedPersonalisedBloc get instance =>
      _instance == null || _instance!.isClosed
          ? _instance = LMFeedPersonalisedBloc._()
          : _instance!;

  final HashSet<String> seenPost = HashSet<String>();
  LMFeedPersonalisedBloc._() : super(LMFeedPersonalisedInitialState()) {
    on<LMFeedPersonalisedGetEvent>(_getPersonalisedFeedHandler);
    on<LMFeedPersonalisedRefreshEvent>(_refreshPersonalisedFeedHandler);
    on<LMFeedPersonalisedSeenPostEvent>(_seenPostHandler);
  }
}
