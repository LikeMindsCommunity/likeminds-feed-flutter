import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/constants.dart';
import 'package:likeminds_feed_flutter_core/src/utils/media/media_handler.dart';

addVideoEventHandler(
  LMFeedComposeAddVideoEvent event,
  Emitter<LMFeedComposeState> emitter,
  int mediaCount,
) async {
  emitter(LMFeedComposeMediaLoadingState());
  debugPrint("Starting picking videos");
  LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.clickedOnAttachment,
    eventProperties: {'type': 'video'},
  ));
  final result = await LMFeedMediaHandler.handlePermissions(2);
  if (result) {
    try {
      final videos = await LMFeedMediaHandler.pickVideos(mediaCount);
      if (videos != null && videos.isNotEmpty) {
        LMFeedComposeBloc.instance.postMedia.addAll(videos);
        emitter(LMFeedComposeAddedVideoState());
      } else {
        emitter(LMFeedComposeInitialState());
      }
    } on Error catch (e) {
      emitter(LMFeedComposeMediaErrorState(e));
    }
  }
}
