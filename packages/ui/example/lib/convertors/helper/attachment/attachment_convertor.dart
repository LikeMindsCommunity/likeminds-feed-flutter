import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';
import 'package:lm_feed_ui_example/convertors/helper/attachment/attachment_meta_convertor.dart';
import 'package:lm_feed_ui_example/convertors/helper/og_tag_convertor.dart';

class AttachmentViewDataConvertor {
  static LMAttachmentViewData fromAttachment({
    required Attachment attachment,
  }) {
    LMAttachmentViewDataBuilder attachmentViewDataBuilder =
        LMAttachmentViewDataBuilder();

    attachmentViewDataBuilder.attachmentType(attachment.attachmentType);
    attachmentViewDataBuilder.attachmentMeta(
        AttachmentMetaViewDataConvertor.attachmentMeta(
            attachmentMeta: attachment.attachmentMeta));

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
            ? OgTagsViewDataConvertor.toOgTags(
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
