import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'routing_event.dart';

part 'routing_state.dart';

part 'handler/share_post_event_handler.dart';
part 'handler/post_notification_event_handler.dart';

class LMFeedRoutingBloc extends Bloc<LMFeedRoutingEvent, LMFeedRoutingState> {
  static LMFeedRoutingBloc? _lmRoutingBloc;

  static LMFeedRoutingBloc get instance =>
      _lmRoutingBloc ??= LMFeedRoutingBloc._();

  LMFeedRoutingBloc._() : super(LMFeedRoutingStateInitState()) {
    on<LMFeedHandleSharedPostEvent>(sharePostEventHandler);
    on<LMFeedHandlePostNotificationEvent>(postNotificationEventHandler);
  }
}
