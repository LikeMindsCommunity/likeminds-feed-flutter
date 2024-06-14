part of '../compose_bloc.dart';

addPollEventHandler(
  LMFeedComposeAddPollEvent event,
  Emitter<LMFeedComposeState> emitter,
) {
  LMFeedComposeBloc.instance.postMedia
      .removeWhere((element) => element.attachmentType == LMMediaType.link);

  // check if poll is already added to the post
  // if yes then remove the poll from the post and add the new poll to the post
  // useful when user edits the poll
  if (LMFeedComposeBloc.instance.isPollAdded) {
    LMFeedComposeBloc.instance.postMedia
        .removeWhere((element) => element.attachmentType == LMMediaType.poll);
  }
  LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
      eventName: LMFeedAnalyticsKeys.pollAdded, eventProperties: {}));

  LMFeedComposeBloc.instance.postMedia.add(
    LMAttachmentViewData.fromAttachmentMeta(
      attachmentType: LMMediaType.poll,
      attachmentMeta: event.attachmentMetaViewData,
    ),
  );
  LMFeedComposeBloc.instance.isPollAdded = true;
  emitter(LMFeedComposeAddedPollState());
}
