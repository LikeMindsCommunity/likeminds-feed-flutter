part of '../notification_bloc.dart';

void getNotificationsEventHandler(LMFeedGetNotificationsEvent event,
      Emitter<LMFeedNotificationsState> emit) async {
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
