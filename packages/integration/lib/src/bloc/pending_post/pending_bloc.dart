import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'pending_event.dart';
part 'pending_state.dart';
part 'handler/get_pending_post_event_handler.dart';

/// The bloc responsible for managing pending posts in the LMFeed package.
class LMFeedPendingBloc extends Bloc<LMFeedPendingEvents, LMFeedPendingState> {
  static LMFeedPendingBloc? _instance;

  /// Returns the singleton instance of [LMFeedPendingBloc].
  static LMFeedPendingBloc get instance =>
      _instance == null || _instance!.isClosed
          ? LMFeedPendingBloc._()
          : _instance!;

  /// Private constructor for [LMFeedPendingBloc].
  /// Initializes the bloc with [LMFeedPendingInitialState] as the initial state.
  LMFeedPendingBloc._() : super(LMFeedPendingInitialState()) {
    on<LMFeedGetPendingPostsEvent>(getPendingPostsEventHandler);
  }
}
