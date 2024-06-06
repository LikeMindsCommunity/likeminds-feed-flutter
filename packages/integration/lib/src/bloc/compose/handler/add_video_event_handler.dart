// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

addVideoEventHandler(
  LMFeedComposeAddVideoEvent event,
  Emitter<LMFeedComposeState> emitter,
) async {
  int mediaCount = LMFeedComposeBloc.instance.postMedia.length;

  if (mediaCount == 0) {
    emitter(LMFeedComposeMediaLoadingState());
  }
  debugPrint("Starting picking videos");
  LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.clickedOnAttachment,
    widgetSource: LMFeedWidgetSource.createPostScreen,
    eventProperties: {'type': 'video'},
  ));
  final LMResponse<bool> result = await LMFeedMediaHandler.handlePermissions(2);
  if (result.success) {
    try {
      final LMResponse<List<LMAttachmentViewData>> videos =
          await LMFeedMediaHandler.pickVideos(mediaCount);
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

          emitter(LMFeedComposeAddedVideoState());
        } else {
          if (LMFeedComposeBloc.instance.postMedia.isEmpty) {
            emitter(LMFeedComposeInitialState());
          } else {
            emitter(LMFeedComposeAddedVideoState());
          }
        }
      } else {
        emitter(LMFeedComposeMediaErrorState(error: videos.errorMessage));
      }
    } on Exception catch (err, stacktrace) {
      LMFeedPersistence.instance.handleException(err, stacktrace);

      emitter(LMFeedComposeMediaErrorState());
    }
  } else {
    emitter(LMFeedComposeMediaErrorState(error: result.errorMessage));
  }
}
