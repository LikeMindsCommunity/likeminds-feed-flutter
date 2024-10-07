import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/helper/attachment/attachment_meta_convertor.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/helper/og_tag_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMAttachmentViewDataConvertor {
  static LMAttachmentViewData fromAttachment({
    required Attachment attachment,
    LMWidgetViewData? widget,
    LMPostViewData? repost,
    required Map<String, LMUserViewData>? users,
  }) {
    LMAttachmentViewDataBuilder attachmentViewDataBuilder =
        LMAttachmentViewData.builder();

    attachmentViewDataBuilder
        .attachmentType(mapIntToMediaType(attachment.attachmentType));
    attachmentViewDataBuilder
        .attachmentMeta(LMAttachmentMetaViewDataConvertor.attachmentMeta(
      attachmentMeta: attachment.attachmentMeta,
      repost: repost,
      widget: widget,
      users: users,
    ));

    return attachmentViewDataBuilder.build();
  }

  static Attachment toAttachment(LMAttachmentViewData attachmentViewData) {
    return Attachment(
      attachmentType: attachmentViewData.mapMediaTypeToInt(),
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
        // send the id of the reposted post in case of repost else send the id of the attachment
        entityId: attachmentViewData.attachmentType == LMMediaType.repost
            ? attachmentViewData.attachmentMeta.repost?.id
            : attachmentViewData.attachmentMeta.id,
        pollQuestion: attachmentViewData.attachmentMeta.pollQuestion,
        expiryTime: attachmentViewData.attachmentMeta.expiryTime,
        pollType: attachmentViewData.attachmentMeta.pollType?.value,
        multiSelectState:
            attachmentViewData.attachmentMeta.multiSelectState?.value,
        multiSelectNo: attachmentViewData.attachmentMeta.multiSelectNo,
        pollOptions: attachmentViewData.attachmentMeta.options
            ?.map((e) => e.text)
            .toList(),
        isAnonymous: attachmentViewData.attachmentMeta.isAnonymous,
        allowAddOption: attachmentViewData.attachmentMeta.allowAddOption,
      ),
    );
  }
}
