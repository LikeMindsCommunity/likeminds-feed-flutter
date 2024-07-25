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
    widgetSource: LMFeedWidgetSource.createPostScreen,
    eventProperties: {'type': 'file'},
  ));
  try {
    final LMResponse<List<LMAttachmentViewData>> documents =
        await LMFeedMediaHandler.pickDocuments(mediaCount);
    if (documents.success) {
      if (documents.data != null && documents.data!.isNotEmpty) {
        int countOfPickedDocument = documents.data!.length;

        LMFeedComposeBloc.instance.documentCount += countOfPickedDocument;
        LMFeedComposeBloc.instance.postMedia.addAll(documents.data!);
        LMFeedComposeBloc.instance.postMedia.removeWhere(
            (element) => element.attachmentType == LMMediaType.link);

        LMFeedAnalyticsBloc.instance.add(
          LMFeedFireAnalyticsEvent(
            eventName: LMFeedAnalyticsKeys.documentAttachedInPost,
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
    LMFeedPersistence.instance.handleException(err, stacktrace);

    emitter(LMFeedComposeMediaErrorState());
  }
}
