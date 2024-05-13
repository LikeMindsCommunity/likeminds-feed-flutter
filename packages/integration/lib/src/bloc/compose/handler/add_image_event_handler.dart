// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

addImageEventHandler(
  LMFeedComposeAddImageEvent event,
  Emitter<LMFeedComposeState> emitter,
) async {
  int mediaCount = LMFeedComposeBloc.instance.postMedia.length;

  if (mediaCount == 0) {
    emitter(LMFeedComposeMediaLoadingState());
  }
  debugPrint("Starting picking images");
  LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.clickedOnAttachment,
    widgetSource: LMFeedWidgetSource.createPostScreen,
    eventProperties: {'type': 'image'},
  ));
  final LMResponse<bool> result = await LMFeedMediaHandler.handlePermissions(1);
  if (result.success) {
    try {
      final LMResponse<List<LMMediaModel>> images =
          await LMFeedMediaHandler.pickImages(mediaCount);
      if (images.success) {
        if (images.data != null && images.data!.isNotEmpty) {
          LMFeedComposeBloc.instance.postMedia
              .removeWhere((element) => element.mediaType == LMMediaType.link);
          int countOfPickedImages = images.data!.length;
          LMFeedComposeBloc.instance.imageCount += countOfPickedImages;
          LMFeedComposeBloc.instance.postMedia.addAll(images.data!);

          LMFeedAnalyticsBloc.instance.add(
            LMFeedFireAnalyticsEvent(
              eventName: LMFeedAnalyticsKeys.imageAttachedToPost,
              widgetSource: LMFeedWidgetSource.createPostScreen,
              eventProperties: {
                'imageCount': countOfPickedImages,
              },
            ),
          );

          emitter(LMFeedComposeAddedImageState());
        } else {
          if (LMFeedComposeBloc.instance.postMedia.isEmpty) {
            emitter(LMFeedComposeInitialState());
          } else {
            emitter(LMFeedComposeAddedImageState());
          }
        }
      } else {
        emitter(LMFeedComposeMediaErrorState(error: images.errorMessage));
      }
    } on Exception catch (err, stacktrace) {
      LMFeedPersistence.instance.handleException(err, stacktrace);

      emitter(LMFeedComposeMediaErrorState());
    }
  } else {
    emitter(LMFeedComposeMediaErrorState(error: result.errorMessage));
  }
}
