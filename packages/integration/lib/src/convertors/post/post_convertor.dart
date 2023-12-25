import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/comment/comment_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/common/popup_menu_convertor.dart';
import 'package:likeminds_feed_driver_fl/src/convertors/helper/attachment/attachment_convertor.dart';
import 'package:likeminds_feed_ui_fl/likeminds_feed_ui_fl.dart';

class PostViewDataConvertor {
  static PostViewData fromPost({required Post post}) {
    PostViewDataBuilder postViewDataBuilder = PostViewDataBuilder();

    postViewDataBuilder.id(post.id);

    postViewDataBuilder.text(post.text);

    postViewDataBuilder.topics(post.topics ?? []);

    if (post.attachments != null) {
      postViewDataBuilder.attachments(post.attachments!
          .map((e) => AttachmentViewDataConvertor.fromAttachment(attachment: e))
          .toList());
    }

    postViewDataBuilder.communityId(post.communityId);

    postViewDataBuilder.isPinned(post.isPinned);

    postViewDataBuilder.userId(post.userId);

    postViewDataBuilder.likeCount(post.likeCount);

    postViewDataBuilder.isSaved(post.isSaved);

    postViewDataBuilder.isLiked(post.isLiked);

    postViewDataBuilder.menuItems(post.menuItems
        .map((e) => PopupMenuItemConvertor.fromPopUpMenuItemModel(item: e))
        .toList());

    postViewDataBuilder.createdAt(post.createdAt);

    postViewDataBuilder.updatedAt(post.updatedAt);

    postViewDataBuilder.isEdited(post.isEdited);

    postViewDataBuilder.replies(post.replies
            ?.map((e) => CommentViewDataConvertor.fromComment(e))
            .toList() ??
        []);

    postViewDataBuilder.commentCount(post.commentCount);

    return postViewDataBuilder.build();
  }

  static Post toPost(PostViewData postViewData) {
    return Post(
      id: postViewData.id,
      isEdited: postViewData.isEdited,
      text: postViewData.text,
      attachments: postViewData.attachments
          ?.map((e) => AttachmentViewDataConvertor.toAttachment(e))
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
          .map((e) => PopupMenuItemConvertor.toPopUpMenuItemModel(e))
          .toList(),
      createdAt: postViewData.createdAt,
      updatedAt: postViewData.updatedAt,
      replies: postViewData.replies
          .map((e) => CommentViewDataConvertor.toComment(e))
          .toList(),
    );
  }
}
