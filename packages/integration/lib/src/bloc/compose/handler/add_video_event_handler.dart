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
    deprecatedEventName: LMFeedAnalyticsKeysDep.clickedOnAttachment,
    eventProperties: {'type': 'video'},
  ));
  final result = await LMFeedMediaHandler.handlePermissions(2);
  if (result) {
    try {
      final videos = await LMFeedMediaHandler.pickVideos(mediaCount);
      if (videos != null && videos.isNotEmpty) {
        int countOfPickedVideos = videos.length;

        LMFeedComposeBloc.instance.videoCount += videos.length;
        LMFeedComposeBloc.instance.postMedia.addAll(videos);
        LMFeedComposeBloc.instance.postMedia
            .removeWhere((element) => element.mediaType == LMMediaType.link);

        LMFeedAnalyticsBloc.instance.add(
          LMFeedFireAnalyticsEvent(
            eventName: LMFeedAnalyticsKeys.videoAttachedToPost,
            deprecatedEventName: LMFeedAnalyticsKeysDep.videoAttachedToPost,
            eventProperties: {
              'videoCount': countOfPickedVideos,
            },
          ),
        );

        emitter(LMFeedComposeAddedVideoState());
      } else {
        emitter(LMFeedComposeInitialState());
      }
    } on Exception catch (err, stacktrace) {
      LMFeedLogger.instance.handleException(err, stacktrace);

      emitter(LMFeedComposeMediaErrorState(err));
    }
  }
}
