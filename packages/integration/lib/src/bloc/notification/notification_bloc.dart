import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'notification_event.dart';
part 'notification_state.dart';

part 'handler/read_notification_event_handler.dart';
part 'handler/get_notifications_event_handler.dart';

class LMFeedNotificationsBloc
    extends Bloc<LMFeedNotificationsEvent, LMFeedNotificationsState> {
  LMFeedNotificationsBloc() : super(LMFeedNotificationsInitialState()) {
    on<LMFeedGetNotificationsEvent>(getNotificationsEventHandler);
    on<LMFeedMarkNotificationAsReadEvent>(markReadNotificationEventHandler);
  }
}
