import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMOgTagsViewDataConvertor {
  static LMOgTagsViewData fromAttachmentsMetaOgTags(OgTags ogTags) {
    LMOgTagsViewDataBuilder ogTagsViewDataBuilder = LMOgTagsViewDataBuilder();

    if (ogTags.title != null) {
      ogTagsViewDataBuilder.title(ogTags.title!);
    }

    if (ogTags.image != null) {
      ogTagsViewDataBuilder.image(ogTags.image!);
    }

    if (ogTags.description != null) {
      ogTagsViewDataBuilder.description(ogTags.description!);
    }

    if (ogTags.url != null) {
      ogTagsViewDataBuilder.url(ogTags.url!);
    }

    return ogTagsViewDataBuilder.build();
  }

  static OgTags toAttachmentMetaOgTags(LMOgTagsViewData ogTagsViewData) {
    return OgTags(
      title: ogTagsViewData.title,
      image: ogTagsViewData.image,
      description: ogTagsViewData.description,
      url: ogTagsViewData.url,
    );
  }
}
