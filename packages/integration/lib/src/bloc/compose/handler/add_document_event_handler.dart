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
    widgetSource: LMFeedWidgetSource.createPostScreen,
    eventProperties: {'type': 'file'},
  ));
  final LMResponse<bool> result = await LMFeedMediaHandler.handlePermissions(3);
  if (result.success) {
    try {
      final LMResponse<List<LMMediaModel>> documents =
          await LMFeedMediaHandler.pickDocuments(mediaCount);
      if (documents.success) {
        if (documents.data != null && documents.data!.isNotEmpty) {
          int countOfPickedDocument = documents.data!.length;

          LMFeedComposeBloc.instance.documentCount += countOfPickedDocument;
          LMFeedComposeBloc.instance.postMedia.addAll(documents.data!);
          LMFeedComposeBloc.instance.postMedia
              .removeWhere((element) => element.mediaType == LMMediaType.link);

          LMFeedAnalyticsBloc.instance.add(
            LMFeedFireAnalyticsEvent(
              eventName: LMFeedAnalyticsKeys.documentAttachedInPost,
              deprecatedEventName:
                  LMFeedAnalyticsKeysDep.documentAttachedInPost,
              widgetSource: LMFeedWidgetSource.createPostScreen,
              eventProperties: {
                'imageCount': countOfPickedDocument,
              },
            ),
          );

          emitter(LMFeedComposeAddedDocumentState());
        } else {
          if (LMFeedComposeBloc.instance.postMedia.isEmpty) {
            emitter(LMFeedComposeInitialState());
          } else {
            emitter(LMFeedComposeAddedDocumentState());
          }
        }
      } else {
        emitter(LMFeedComposeMediaErrorState(error: documents.errorMessage));
      }
    } on Exception catch (err, stacktrace) {
      LMFeedLogger.instance.handleException(err, stacktrace);

      emitter(LMFeedComposeMediaErrorState());
    }
  } else {
    emitter(LMFeedComposeMediaErrorState(error: result.errorMessage));
  }
}
