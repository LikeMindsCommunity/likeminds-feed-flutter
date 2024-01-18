import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

addLinkPreviewEventHandler(
  LMFeedComposeAddLinkPreviewEvent event,
  Emitter<LMFeedComposeState> emitter,
  List<LMMediaModel> mediaList,
) async {
  mediaList.removeWhere((element) => element.mediaType == LMMediaType.link);

  for (LMMediaModel media in mediaList) {
    if (media.mediaType != LMMediaType.link ||
        media.mediaType != LMMediaType.widget) {
      if (media.mediaType == LMMediaType.document) {
        emitter(LMFeedComposeAddedDocumentState());
        return;
      }
      if (media.mediaType == LMMediaType.image) {
        emitter(LMFeedComposeAddedImageState());
        return;
      }
      if (media.mediaType == LMMediaType.video) {
        emitter(LMFeedComposeAddedVideoState());
        return;
      }
      return;
    }
  }

  String url = event.url;

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

    LMFeedComposeBloc.instance.postMedia.add(linkModel);

    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
      eventName: LMFeedAnalyticsKeys.linkAttachedInPost,
      eventProperties: {
        'link': event.url,
      },
    ));

    emitter(LMFeedComposeAddedLinkPreviewState(url: event.url));
  }
}
