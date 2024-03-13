part of '../notification_bloc.dart';

void markReadNotificationEventHandler(
    LMFeedMarkNotificationAsReadEvent event, emit) {
  MarkReadNotificationRequest request = (MarkReadNotificationRequestBuilder()
        ..activityId(event.activityId))
      .build();

  LMFeedCore.instance.lmFeedClient.markReadNotification(request);
}
