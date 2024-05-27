import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'pending_event.dart';
part 'pending_state.dart';
part 'handler/get_pending_post_event_handler.dart';

class LMFeedPendingBloc extends Bloc<LMFeedPendingEvents, LMFeedPendingState> {
  static LMFeedPendingBloc? _instance;

  static LMFeedPendingBloc get instance => _instance ??= LMFeedPendingBloc._();

  // final FeedApi feedApi;
  LMFeedPendingBloc._() : super(LMFeedPendingInitialState()) {
    on<LMFeedGetPendingPostsEvent>(getPendingPostsEventHandler);
  }
}
