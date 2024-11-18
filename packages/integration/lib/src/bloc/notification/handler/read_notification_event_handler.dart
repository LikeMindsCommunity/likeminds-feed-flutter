part of '../notification_bloc.dart';

void markReadNotificationEventHandler(
    LMFeedMarkNotificationAsReadEvent event, emit) {
  // check if the user is a guest user
  if (LMFeedUserUtils.isGuestUser()) {
    LMFeedCore.instance.lmFeedCoreCallback?.loginRequired?.call();
    return;
  }
  MarkReadNotificationRequest request = (MarkReadNotificationRequestBuilder()
        ..activityId(event.activityId))
      .build();

  LMFeedCore.instance.lmFeedClient.markReadNotification(request);
}
