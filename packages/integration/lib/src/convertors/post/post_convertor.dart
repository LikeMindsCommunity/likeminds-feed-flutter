import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMPostViewDataConvertor {
  static LMPostViewData fromPost({
    required Post post,
    required Map<String, WidgetModel>? widgets,
  }) {
    LMPostViewDataBuilder postViewDataBuilder = LMPostViewDataBuilder();
    Map<String, LMWidgetViewData> widgetMap = {};

    postViewDataBuilder.id(post.id);

    postViewDataBuilder.text(post.text);

    postViewDataBuilder.topics(post.topics ?? []);

    if (post.attachments != null) {
      postViewDataBuilder.attachments(post.attachments!.map((e) {
        debugPrint('Attachment type: $widgets');
        if (e.attachmentType == 5 && widgets != null) {
          String? key = e.attachmentMeta.meta?['entity_id'];
          if (key != null) {
            widgetMap[key] =
                LMWidgetViewDataConvertor.fromWidgetModel(widgets[key]!);
          }
        }
        return LMAttachmentViewDataConvertor.fromAttachment(attachment: e);
      }).toList());
    }

    postViewDataBuilder.communityId(post.communityId);

    postViewDataBuilder.isPinned(post.isPinned);

    postViewDataBuilder.userId(post.userId);

    postViewDataBuilder.likeCount(post.likeCount);

    postViewDataBuilder.isSaved(post.isSaved);

    postViewDataBuilder.isLiked(post.isLiked);

    postViewDataBuilder.menuItems(post.menuItems
        .map((e) => LMPopupMenuItemConvertor.fromPopUpMenuItemModel(item: e))
        .toList());

    postViewDataBuilder.createdAt(post.createdAt);

    postViewDataBuilder.updatedAt(post.updatedAt);

    postViewDataBuilder.isEdited(post.isEdited);

    postViewDataBuilder.replies(post.replies
            ?.map((e) => LMCommentViewDataConvertor.fromComment(e))
            .toList() ??
        []);

    postViewDataBuilder.commentCount(post.commentCount);

    postViewDataBuilder.isReposted(post.isRepost);

    postViewDataBuilder.isRepostedByUser(post.isRepostedByUser);

    postViewDataBuilder.repostCount(post.repostCount);

    postViewDataBuilder.isDeleted(post.isDeleted ?? false);

    postViewDataBuilder.widgets(widgetMap);

    return postViewDataBuilder.build();
  }

  static Post toPost(LMPostViewData postViewData) {
    return Post(
      id: postViewData.id,
      isEdited: postViewData.isEdited,
      text: postViewData.text,
      attachments: postViewData.attachments
          ?.map((e) => LMAttachmentViewDataConvertor.toAttachment(e))
          .toList(),
      communityId: postViewData.communityId,
      isPinned: postViewData.isPinned,
      topics: postViewData.topics,
      userId: postViewData.userId,
      likeCount: postViewData.likeCount,
      commentCount: postViewData.commentCount,
      isSaved: postViewData.isSaved,
      isLiked: postViewData.isLiked,
      menuItems: postViewData.menuItems
          .map((e) => LMPopupMenuItemConvertor.toPopUpMenuItemModel(e))
          .toList(),
      createdAt: postViewData.createdAt,
      updatedAt: postViewData.updatedAt,
      replies: postViewData.replies
          .map((e) => LMCommentViewDataConvertor.toComment(e))
          .toList(),
      isRepost: postViewData.isRepost,
      isRepostedByUser: postViewData.isRepostedByUser,
      repostCount: postViewData.repostCount,
      isDeleted: postViewData.isDeleted,
    );
  }
}
