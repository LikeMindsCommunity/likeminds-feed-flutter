import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/helper/attachment/attachment_meta_convertor.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/helper/og_tag_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMAttachmentViewDataConvertor {
  static LMAttachmentViewData fromAttachment({
    required Attachment attachment,
    LMPostViewData? repost,
  }) {
    LMAttachmentViewDataBuilder attachmentViewDataBuilder =
        LMAttachmentViewDataBuilder();

    attachmentViewDataBuilder.attachmentType(attachment.attachmentType);
    attachmentViewDataBuilder
        .attachmentMeta(LMAttachmentMetaViewDataConvertor.attachmentMeta(
      attachmentMeta: attachment.attachmentMeta,
      repost: repost,
    ));

    return attachmentViewDataBuilder.build();
  }

  static Attachment toAttachment(LMAttachmentViewData attachmentViewData) {
    return Attachment(
      attachmentType: attachmentViewData.attachmentType,
      attachmentMeta: AttachmentMeta(
        url: attachmentViewData.attachmentMeta.url,
        format: attachmentViewData.attachmentMeta.format,
        size: attachmentViewData.attachmentMeta.size,
        duration: attachmentViewData.attachmentMeta.duration,
        pageCount: attachmentViewData.attachmentMeta.pageCount,
        ogTags: attachmentViewData.attachmentMeta.ogTags != null
            ? LMOgTagsViewDataConvertor.toAttachmentMetaOgTags(
                attachmentViewData.attachmentMeta.ogTags!)
            : null,
        aspectRatio: attachmentViewData.attachmentMeta.aspectRatio,
        width: attachmentViewData.attachmentMeta.width,
        height: attachmentViewData.attachmentMeta.height,
        meta: attachmentViewData.attachmentMeta.meta,
      ),
    );
  }
}
