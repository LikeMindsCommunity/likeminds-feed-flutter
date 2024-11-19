import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/model_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMAttachmentMetaViewDataConvertor {
  static LMAttachmentMetaViewData attachmentMeta({
    required AttachmentMeta attachmentMeta,
    required LMPostViewData? repost,
    required LMWidgetViewData? widget,
    required Map<String, LMUserViewData>? users,
  }) {
    LMAttachmentMetaViewDataBuilder attachmentMetaViewDataBuilder =
        LMAttachmentMetaViewData.builder();

    attachmentMetaViewDataBuilder.path(attachmentMeta.path);
    attachmentMetaViewDataBuilder.bytes(attachmentMeta.bytes);
    if (attachmentMeta.url != null) {
      attachmentMetaViewDataBuilder.url(attachmentMeta.url!);
    }

    if (attachmentMeta.format != null) {
      attachmentMetaViewDataBuilder.format(attachmentMeta.format!);
    }
    if (attachmentMeta.size != null) {
      attachmentMetaViewDataBuilder.size(attachmentMeta.size!);
    }
    if (attachmentMeta.duration != null) {
      attachmentMetaViewDataBuilder.duration(attachmentMeta.duration!);
    }
    if (attachmentMeta.pageCount != null) {
      attachmentMetaViewDataBuilder.pageCount(attachmentMeta.pageCount!);
    }
    if (attachmentMeta.ogTags != null) {
      attachmentMetaViewDataBuilder.ogTags(
          LMOgTagsViewDataConvertor.fromAttachmentsMetaOgTags(
              attachmentMeta.ogTags!));
    }
    if (attachmentMeta.aspectRatio != null) {
      attachmentMetaViewDataBuilder.aspectRatio(attachmentMeta.aspectRatio!);
    }
    if (attachmentMeta.thumbnailUrl != null) {
      attachmentMetaViewDataBuilder.thumbnailUrl(attachmentMeta.thumbnailUrl!);
    }
    if (attachmentMeta.width != null) {
      attachmentMetaViewDataBuilder.width(attachmentMeta.width!);
    }
    if (attachmentMeta.height != null) {
      attachmentMetaViewDataBuilder.height(attachmentMeta.height!);
    }
    if (attachmentMeta.meta != null) {
      attachmentMetaViewDataBuilder.meta(attachmentMeta.meta!);
    }
    if (repost != null) {
      attachmentMetaViewDataBuilder.repost(repost);
    }
    attachmentMetaViewDataBuilder.pollQuestion(attachmentMeta.pollQuestion);
    attachmentMetaViewDataBuilder.expiryTime(attachmentMeta.expiryTime);
    attachmentMetaViewDataBuilder.pollOptions(attachmentMeta.pollOptions);
    if (attachmentMeta.multiSelectState != null) {
      attachmentMetaViewDataBuilder.multiSelectState(
          pollMultiSelectStateFromString(attachmentMeta.multiSelectState!));
    }
    if (attachmentMeta.pollType != null) {
      attachmentMetaViewDataBuilder
          .pollType(pollTypeFromString(attachmentMeta.pollType!));
    }
    attachmentMetaViewDataBuilder.multiSelectNo(attachmentMeta.multiSelectNo);
    attachmentMetaViewDataBuilder.isAnonymous(attachmentMeta.isAnonymous);
    attachmentMetaViewDataBuilder.allowAddOption(attachmentMeta.allowAddOption);
    if (users != null && widget != null && widget.lmMeta != null) {
      attachmentMetaViewDataBuilder.id(widget.id);
      attachmentMetaViewDataBuilder.pollQuestion(widget.metadata['title']);
      attachmentMetaViewDataBuilder.expiryTime(widget.metadata['expiry_time']);
      attachmentMetaViewDataBuilder.multiSelectState(
          pollMultiSelectStateFromString(
              widget.metadata['multiple_select_state']));
      attachmentMetaViewDataBuilder
          .pollType(pollTypeFromString(widget.metadata['poll_type']));
      attachmentMetaViewDataBuilder
          .multiSelectNo(widget.metadata['multiple_select_number']);
      attachmentMetaViewDataBuilder
          .isAnonymous(widget.metadata['is_anonymous']);
      attachmentMetaViewDataBuilder
          .allowAddOption(widget.metadata['allow_add_option']);

      List<LMPollOptionViewData> options = [];
      for (Map<String, dynamic> option in widget.lmMeta?['options']) {
        final optionViewData = LMPollOptionViewDataConvertor.fromPollOption(
            option: option, users: users);
        options.add(optionViewData);
      }
      attachmentMetaViewDataBuilder.options(options);
      attachmentMetaViewDataBuilder
          .toShowResult(widget.lmMeta?['to_show_results']);
      attachmentMetaViewDataBuilder
          .pollAnswerText(widget.lmMeta?['poll_answer_text']);
    }

    return attachmentMetaViewDataBuilder.build();
  }

  static AttachmentMeta toAttachmentMeta(
      LMAttachmentMetaViewData attachmentMetaViewData) {
    return AttachmentMeta(
      url: attachmentMetaViewData.url,
      format: attachmentMetaViewData.format,
      size: attachmentMetaViewData.size,
      duration: attachmentMetaViewData.duration,
      pageCount: attachmentMetaViewData.pageCount,
      ogTags: attachmentMetaViewData.ogTags != null
          ? LMOgTagsViewDataConvertor.toAttachmentMetaOgTags(
              attachmentMetaViewData.ogTags!)
          : null,
      aspectRatio: attachmentMetaViewData.aspectRatio,
      width: attachmentMetaViewData.width,
      height: attachmentMetaViewData.height,
      meta: attachmentMetaViewData.meta,
      pollQuestion: attachmentMetaViewData.pollQuestion,
      expiryTime: attachmentMetaViewData.expiryTime,
      pollOptions: attachmentMetaViewData.pollOptions,
      multiSelectState: attachmentMetaViewData.multiSelectState?.value,
      pollType: attachmentMetaViewData.pollType?.value,
      multiSelectNo: attachmentMetaViewData.multiSelectNo,
      isAnonymous: attachmentMetaViewData.isAnonymous,
      allowAddOption: attachmentMetaViewData.allowAddOption,
      entityId: attachmentMetaViewData.id,
      thumbnailUrl: attachmentMetaViewData.thumbnailUrl,
    );
  }

  static LMAttachmentMetaViewData fromWidgetModel({
    required WidgetModel widget,
    required Map<String, LMUserViewData> users,
  }) {
    final LMAttachmentMetaViewDataBuilder attachmentMetaViewDataBuilder =
        LMAttachmentMetaViewData.builder();
    attachmentMetaViewDataBuilder.id(widget.id);
    attachmentMetaViewDataBuilder.pollQuestion(widget.metadata['title']);
    attachmentMetaViewDataBuilder.expiryTime(widget.metadata['expiry_time']);
    attachmentMetaViewDataBuilder.multiSelectState(
        pollMultiSelectStateFromString(
            widget.metadata['multiple_select_state']));
    attachmentMetaViewDataBuilder
        .pollType(pollTypeFromString(widget.metadata['poll_type']));
    attachmentMetaViewDataBuilder
        .multiSelectNo(widget.metadata['multiple_select_number']);
    attachmentMetaViewDataBuilder.isAnonymous(widget.metadata['is_anonymous']);
    attachmentMetaViewDataBuilder
        .allowAddOption(widget.metadata['allow_add_option']);

    List<LMPollOptionViewData> options = [];
    for (Map<String, dynamic> option in widget.lmMeta?['options']) {
      final optionViewData = LMPollOptionViewDataConvertor.fromPollOption(
          option: option, users: users);
      options.add(optionViewData);
    }
    attachmentMetaViewDataBuilder.options(options);
    attachmentMetaViewDataBuilder
        .toShowResult(widget.lmMeta?['to_show_results']);
    attachmentMetaViewDataBuilder
        .pollAnswerText(widget.lmMeta?['poll_answer_text']);
    return attachmentMetaViewDataBuilder.build();
  }
}
