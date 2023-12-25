import 'package:likeminds_feed_ui_fl/src/models/helper/attachment/attachment_meta_view_data.dart';

class LMAttachmentViewData {
  final int attachmentType;
  final LMAttachmentMetaViewData attachmentMeta;

  LMAttachmentViewData._({
    required this.attachmentType,
    required this.attachmentMeta,
  });
}

class LMAttachmentViewDataBuilder {
  int? _attachmentType;
  LMAttachmentMetaViewData? _attachmentMeta;

  void attachmentType(int attachmentType) {
    _attachmentType = attachmentType;
  }

  void attachmentMeta(LMAttachmentMetaViewData attachmentMeta) {
    _attachmentMeta = attachmentMeta;
  }

  LMAttachmentViewData build() {
    return LMAttachmentViewData._(
      attachmentType: _attachmentType!,
      attachmentMeta: _attachmentMeta!,
    );
  }
}
