import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/model_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMPostViewDataConvertor {
  static LMPostViewData fromPost({
    required Post post,
    Map<String, LMWidgetViewData>? widgets,
    Map<String, LMPostViewData>? repostedPosts,
    required Map<String, LMUserViewData> users,
    Map<String, LMTopicViewData>? topics,
    Map<String, List<String>>? userTopics,
    Map<String, LMCommentViewData>? filteredComments,
  }) {
    LMPostViewDataBuilder postViewDataBuilder = LMPostViewDataBuilder();
    Map<String, LMWidgetViewData> postWidget = {};

    postViewDataBuilder.id(post.id);

    postViewDataBuilder.text(post.text);

    List<LMTopicViewData> topicViewData = [];
    if (topics != null && post.topicIds != null) {
      for (String topicId in post.topicIds!) {
        if (topics[topicId] != null) {
          topicViewData.add(topics[topicId]!);
        }
      }
    }
    postViewDataBuilder.topics(topicViewData);

    if (post.attachments != null) {
      postViewDataBuilder.attachments(post.attachments!.map((e) {
        LMPostViewData? repost;

        if (e.attachmentType == LMAttachmentViewData.widgetMediaType &&
            widgets != null) {
          String? key = e.attachmentMeta.meta?['entity_id'];
          if (key != null && widgets[key] != null) {
            postWidget[key] = widgets[key]!;
          }
        } else if (e.attachmentType == LMAttachmentViewData.repostMediaType &&
            repostedPosts != null &&
            repostedPosts[e.attachmentMeta.entityId] != null) {
          repost = repostedPosts[e.attachmentMeta.entityId]!;
        } else if (e.attachmentType == LMAttachmentViewData.pollMediaType) {
          String? key = e.attachmentMeta.entityId;
          if (key != null && widgets?[key] != null) {
            postWidget[key] = widgets![key]!;
          }
        }

        return LMAttachmentViewDataConvertor.fromAttachment(
          attachment: e,
          repost: repost,
          widget: postWidget[e.attachmentMeta.entityId],
          users: users,
        );
      }).toList());
    }

    postViewDataBuilder.communityId(post.communityId);

    postViewDataBuilder.isPinned(post.isPinned);

    postViewDataBuilder.uuid(post.uuid);

    if (users[post.uuid] != null) {
      postViewDataBuilder.user(users[post.uuid]!);
    }

    postViewDataBuilder.likeCount(post.likeCount);

    postViewDataBuilder.isSaved(post.isSaved);

    postViewDataBuilder.isLiked(post.isLiked);

    postViewDataBuilder.isPendingPost(post.isPendingPost);

    postViewDataBuilder.postStatus(
        LMFeedPostUtils.postReviewStatusFromString(post.postStatus));

    postViewDataBuilder.menuItems(post.menuItems
        .map((e) => LMPopupMenuItemConvertor.fromPopUpMenuItemModel(item: e))
        .toList());

    postViewDataBuilder.createdAt(post.createdAt);

    postViewDataBuilder.updatedAt(post.updatedAt);

    postViewDataBuilder.isEdited(post.isEdited);

    postViewDataBuilder.replies(post.replies
            ?.map((e) => LMCommentViewDataConvertor.fromComment(e, users))
            .toList() ??
        []);

    postViewDataBuilder.commentCount(post.commentCount);

    postViewDataBuilder.isReposted(post.isRepost);

    postViewDataBuilder.isRepostedByUser(post.isRepostedByUser);

    postViewDataBuilder.repostCount(post.repostCount);

    postViewDataBuilder.isDeleted(post.isDeleted ?? false);

    if (widgets != null) {
      postViewDataBuilder.widgets(widgets);
    }

    if (post.heading != null) postViewDataBuilder.heading(post.heading!);

    if (post.commentIds != null && post.commentIds!.isNotEmpty) {
      postViewDataBuilder.commentIds(
        post.commentIds!,
      );

      List<LMCommentViewData> topComments = [];
      if (filteredComments != null && filteredComments.isNotEmpty) {
        post.commentIds?.forEach((element) {
          if (filteredComments[element] != null)
            topComments.add(filteredComments[element]!);
        });
      }

      postViewDataBuilder.topComments(topComments);
    }
    if (post.tempId != null) {
      postViewDataBuilder.tempId(post.tempId!);
    }

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
      topicIds: postViewData.topics.map((e) => e.id).toList(),
      uuid: postViewData.uuid,
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
      heading: postViewData.heading,
      tempId: postViewData.tempId,
      isPendingPost: postViewData.isPendingPost,
      postStatus: postViewData.postStatus.toString(),
      commentIds: postViewData.commentIds,
    );
  }
}
