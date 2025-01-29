part of '../compose_bloc.dart';

_addReelEventHandler(
  LMFeedComposeAddReelEvent event,
  Emitter<LMFeedComposeState> emitter,
) async {
  int mediaCount = LMFeedComposeBloc.instance.postMedia.length;

  if (mediaCount == 0) {
    emitter(LMFeedComposeMediaLoadingState());
  }
  LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.clickedOnAttachment,
    widgetSource: LMFeedWidgetSource.createPostScreen,
    eventProperties: {'type': 'reel'},
  ));
  try {
    final LMResponse<List<LMAttachmentViewData>> videos =
        await LMFeedMediaHandler.pickVideos(
      currentMediaLength: mediaCount,
      allowMultiple: false,
      isReelVideo: true,
    );
    if (videos.success) {
      if (videos.data != null && videos.data!.isNotEmpty) {
        int countOfPickedVideos = videos.data!.length;

        LMFeedComposeBloc.instance.videoCount += countOfPickedVideos;
        LMFeedComposeBloc.instance.postMedia.addAll(videos.data!);
        LMFeedComposeBloc.instance.postMedia.removeWhere(
            (element) => element.attachmentType == LMMediaType.link);

        LMFeedAnalyticsBloc.instance.add(
          LMFeedFireAnalyticsEvent(
            eventName: LMFeedAnalyticsKeys.videoAttachedToPost,
            widgetSource: LMFeedWidgetSource.createPostScreen,
            eventProperties: {
              'video_count': countOfPickedVideos,
            },
          ),
        );

        emitter(LMFeedComposeAddedReelState());
      } else {
        if (LMFeedComposeBloc.instance.postMedia.isEmpty) {
          emitter(LMFeedComposeInitialState());
        } else {
          emitter(LMFeedComposeAddedReelState());
        }
      }
    } else {
      emitter(LMFeedComposeMediaErrorState(error: videos.errorMessage));
    }
  } on Exception catch (err, stacktrace) {
    LMFeedPersistence.instance.handleException(err, stacktrace);

    emitter(LMFeedComposeMediaErrorState());
  }
}
