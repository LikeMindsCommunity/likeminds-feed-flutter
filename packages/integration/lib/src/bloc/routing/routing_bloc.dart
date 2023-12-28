import 'package:equatable/equatable.dart';
import 'package:bloc/bloc.dart';

part 'routing_event.dart';

part 'routing_state.dart';

part 'handler/share_post_event_handler.dart';
part 'handler/post_notification_event_handler.dart';

class LMRoutingBloc extends Bloc<LMRoutingEvent, LMRoutingState> {
  static LMRoutingBloc? _lmRoutingBloc;

  static LMRoutingBloc get instance => _lmRoutingBloc ??= LMRoutingBloc._();

  LMRoutingBloc._() : super(LMRoutingStateInit()) {
    on<LMHandleSharedPostEvent>(sharePostEventHandler);
    on<LMHandlePostNotificationEvent>(postNotificationEventHandler);
  }
}
