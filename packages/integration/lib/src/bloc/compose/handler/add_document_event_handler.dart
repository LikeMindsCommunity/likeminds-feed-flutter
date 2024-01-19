import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/media/media_handler.dart';

addDocumentEventHandler(
  LMFeedComposeAddDocumentEvent event,
  Emitter<LMFeedComposeState> emitter,
  int mediaCount,
) async {
  if (mediaCount == 0) {
    emitter(LMFeedComposeMediaLoadingState());
  } else {
    LMFeedComposeBloc.instance.postMedia
        .removeWhere((element) => element.mediaType == LMMediaType.link);
  }
  debugPrint("Starting picking documents");
  LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.clickedOnAttachment,
    eventProperties: {'type': 'document'},
  ));
  final result = await LMFeedMediaHandler.handlePermissions(3);
  if (result) {
    try {
      final documents = await LMFeedMediaHandler.pickDocuments(mediaCount);
      if (documents != null && documents.isNotEmpty) {
        LMFeedComposeBloc.instance.postMedia.addAll(documents);
        emitter(LMFeedComposeAddedDocumentState());
      } else {
        emitter(LMFeedComposeInitialState());
      }
    } on Error catch (e) {
      emitter(LMFeedComposeMediaErrorState(e));
    }
  }
}
