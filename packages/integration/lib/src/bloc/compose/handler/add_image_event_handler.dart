import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/media/media_handler.dart';

addImageEventHandler(
  LMFeedComposeAddImageEvent event,
  Emitter<LMFeedComposeState> emitter,
) async {
  int mediaCount = LMFeedComposeBloc.instance.postMedia.length;

  if (mediaCount == 0) {
    emitter(LMFeedComposeMediaLoadingState());
  } else {
    LMFeedComposeBloc.instance.postMedia
        .removeWhere((element) => element.mediaType == LMMediaType.link);
  }
  debugPrint("Starting picking images");
  LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.clickedOnAttachment,
    eventProperties: {'type': 'image'},
  ));
  final result = await LMFeedMediaHandler.handlePermissions(1);
  if (result) {
    try {
      final images = await LMFeedMediaHandler.pickImages(mediaCount);
      if (images != null && images.isNotEmpty) {
        LMFeedComposeBloc.instance.imageCount += images.length;
        LMFeedComposeBloc.instance.postMedia.addAll(images);
        emitter(LMFeedComposeAddedImageState());
      } else {
        if (LMFeedComposeBloc.instance.postMedia.isEmpty) {
          emitter(LMFeedComposeInitialState());
        } else {
          emitter(LMFeedComposeAddedImageState());
        }
      }
    } on Error catch (e) {
      emitter(LMFeedComposeMediaErrorState(e));
    }
  }
}
