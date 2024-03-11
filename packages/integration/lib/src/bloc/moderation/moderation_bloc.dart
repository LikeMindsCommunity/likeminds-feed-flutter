import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

part 'moderation_event.dart';
part 'moderation_state.dart';

class LMFeedModerationBloc
    extends Bloc<LMFeedModerationEvent, LMFeedModerationState> {
  LMFeedModerationBloc() : super(LMFeedModerationInitialState()) {
    on<LMFeedGetNotificationsEvent>(_mapGetNotificationsToState);
    on<LMFeedMarkNotificationAsReadEvent>(_mapMarkReadNotificationToState);
  }
  _mapMarkReadNotificationToState(LMFeedMarkNotificationAsReadEvent event, emit) {
    MarkReadNotificationRequest request = (MarkReadNotificationRequestBuilder()
          ..activityId(event.activityId))
        .build();

    LMFeedCore.instance.lmFeedClient.markReadNotification(request);
  }

  _mapGetNotificationsToState(LMFeedGetNotificationsEvent event,
      Emitter<LMFeedModerationState> emit) async {
    if (event.offset > 1) {
      emit(LMFeedNotificationsPaginationLoadingState());
    } else {
      emit(LMFeedNotificationsLoadingState());
    }
    try {
      GetNotificationFeedResponse? response =
          await LMFeedCore.instance.lmFeedClient.getNotificationFeed(
        (GetNotificationFeedRequestBuilder()
              ..page(event.offset)
              ..pageSize(event.pageSize))
            .build(),
      );

      if (response.success) {
        final notificationFeedItems = response.items
                ?.map((e) => LMNotificationFeedItemViewDataConvertor
                    .fromNotificationFeedItem(e, response.users ?? {}))
                .toList() ??
            [];
        emit(
          LMFeedNotificationsLoadedState(response: notificationFeedItems),
        );
      } else {
        emit(
          const LMFeedNotificationsErrorState(
              message: "An error occurred, Please try again"),
        );
      }
    } catch (e) {
      emit(
        LMFeedNotificationsErrorState(message: "${e.toString()} No data found"),
      );
    }
  }
}
