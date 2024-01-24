import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/comment/comment_convertor.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/common/popup_menu_convertor.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/helper/attachment/attachment_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMPostViewDataConvertor {
  static LMPostViewData fromPost({required Post post}) {
    LMPostViewDataBuilder postViewDataBuilder = LMPostViewDataBuilder();

    postViewDataBuilder.id(post.id);

    postViewDataBuilder.text(post.text);

    postViewDataBuilder.topics(post.topics ?? []);

    if (post.attachments != null) {
      postViewDataBuilder.attachments(post.attachments!
          .map((e) =>
              LMAttachmentViewDataConvertor.fromAttachment(attachment: e))
          .toList());
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
