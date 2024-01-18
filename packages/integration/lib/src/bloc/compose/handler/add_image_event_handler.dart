import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/bloc.dart';
import 'package:likeminds_feed_flutter_core/src/bloc/compose/compose_bloc.dart';
import 'package:likeminds_feed_flutter_core/src/utils/constants/constants.dart';
import 'package:likeminds_feed_flutter_core/src/utils/media/media_handler.dart';

addImageEventHandler(
  LMFeedComposeAddImageEvent event,
  Emitter<LMFeedComposeState> emitter,
  int mediaCount,
) async {
  emitter(LMFeedComposeMediaLoadingState());
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
