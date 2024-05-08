// ignore_for_file: deprecated_member_use_from_same_package

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

addLinkPreviewEventHandler(
  LMFeedComposeAddLinkPreviewEvent event,
  Emitter<LMFeedComposeState> emitter,
) async {
  try {
    LMFeedComposeBloc composeBloc = LMFeedComposeBloc.instance;

    if (composeBloc.imageCount +
            composeBloc.videoCount +
            composeBloc.documentCount >
        0 || composeBloc.isPollAdded) {
      return;
    }

    String url = getFirstValidLinkFromString(event.url);

    if (url.isEmpty) {
      emitter(LMFeedComposeInitialState());
      return;
    }

    DecodeUrlRequest request = (DecodeUrlRequestBuilder()..url(url)).build();

    DecodeUrlResponse response = await LMFeedCore.client.decodeUrl(request);

    if (response.success == true) {
      OgTags responseTags = response.ogTags!;

      LMMediaModel linkModel = LMMediaModel(
        mediaType: LMMediaType.link,
        link: url,
        ogTags: LMOgTagsViewDataConvertor.fromAttachmentsMetaOgTags(
          responseTags,
        ),
      );

      LMFeedComposeBloc.instance.postMedia = [linkModel];

      LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
        eventName: LMFeedAnalyticsKeys.linkAttachedInPost,
        widgetSource: LMFeedWidgetSource.createPostScreen,
        eventProperties: {
          'link': event.url,
        },
      ));

      emitter(LMFeedComposeAddedLinkPreviewState(url: event.url));
    } else {
      emitter(LMFeedComposeInitialState());
    }
  } on Exception catch (err, stacktrace) {
    LMFeedLogger.instance.handleException(err, stacktrace);
  }
}
