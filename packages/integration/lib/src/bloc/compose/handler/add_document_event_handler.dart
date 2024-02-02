import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/utils/media/media_handler.dart';

addDocumentEventHandler(
  LMFeedComposeAddDocumentEvent event,
  Emitter<LMFeedComposeState> emitter,
) async {
  int mediaCount = LMFeedComposeBloc.instance.postMedia.length;

  if (mediaCount == 0) {
    emitter(LMFeedComposeMediaLoadingState());
  }
  debugPrint("Starting picking documents");
  LMFeedAnalyticsBloc.instance.add(const LMFeedFireAnalyticsEvent(
    eventName: LMFeedAnalyticsKeys.clickedOnAttachment,
    deprecatedEventName: LMFeedAnalyticsKeysDep.clickedOnAttachment,
    eventProperties: {'type': 'document'},
  ));
  final result = await LMFeedMediaHandler.handlePermissions(3);
  if (result) {
    try {
      final documents = await LMFeedMediaHandler.pickDocuments(mediaCount);
      if (documents != null && documents.isNotEmpty) {
        LMFeedComposeBloc.instance.documentCount += documents.length;
        LMFeedComposeBloc.instance.postMedia.addAll(documents);
        LMFeedComposeBloc.instance.postMedia
            .removeWhere((element) => element.mediaType == LMMediaType.link);
        emitter(LMFeedComposeAddedDocumentState());
      } else {
        emitter(LMFeedComposeInitialState());
      }
    } on Exception catch (err, stacktrace) {
      LMFeedLogger.instance.handleException(err, stacktrace);

      emitter(LMFeedComposeMediaErrorState(err));
    }
  }
}
