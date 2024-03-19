// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

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
    eventProperties: {'type': 'file'},
  ));
  final result = await LMFeedMediaHandler.handlePermissions(3);
  if (result) {
    try {
      final documents = await LMFeedMediaHandler.pickDocuments(mediaCount);
      if (documents != null && documents.isNotEmpty) {
        int countOfPickedDocument = documents.length;

        LMFeedComposeBloc.instance.documentCount += countOfPickedDocument;
        LMFeedComposeBloc.instance.postMedia.addAll(documents);
        LMFeedComposeBloc.instance.postMedia
            .removeWhere((element) => element.mediaType == LMMediaType.link);

        LMFeedAnalyticsBloc.instance.add(
          LMFeedFireAnalyticsEvent(
            eventName: LMFeedAnalyticsKeys.documentAttachedInPost,
            deprecatedEventName: LMFeedAnalyticsKeysDep.documentAttachedInPost,
            eventProperties: {
              'imageCount': countOfPickedDocument,
            },
          ),
        );

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
