import 'package:likeminds_feed/likeminds_feed.dart';
import 'package:likeminds_feed_flutter_core/src/convertors/model_convertor.dart';
import 'package:likeminds_feed_flutter_ui/likeminds_feed_flutter_ui.dart';

class LMPostViewDataConvertor {
  static LMPostViewData fromPost({
    required Post post,
    Map<String, WidgetModel>? widgets,
    Map<String, Post>? repostedPosts,
    required Map<String, User> users,
    Map<String, Topic>? topics,
    Map<String, Comment>? filteredComments,
  }) {
    LMPostViewDataBuilder postViewDataBuilder = LMPostViewDataBuilder();
    Map<String, LMWidgetViewData> widgetMap = {};

    postViewDataBuilder.id(post.id);

    postViewDataBuilder.text(post.text);

    List<LMTopicViewData> topicViewData = [];
    if (topics != null) {
      post.topics?.forEach((element) {
        if (topics[element] != null) {
          topicViewData
              .add(LMTopicViewDataConvertor.fromTopic(topics[element]!));
        }
      });
    }
    postViewDataBuilder.topics(topicViewData);

    if (post.attachments != null) {
      postViewDataBuilder.attachments(post.attachments!.map((e) {
        LMPostViewData? repost;

        if (e.attachmentType == 5 && widgets != null) {
          String? key = e.attachmentMeta.meta?['entity_id'];
          if (key != null && widgets[key] != null) {
            widgetMap[key] =
                LMWidgetViewDataConvertor.fromWidgetModel(widgets[key]!);
          }
        } else if (e.attachmentType == 8 &&
            repostedPosts != null &&
            repostedPosts[e.attachmentMeta.entityId] != null) {
          repost = LMPostViewDataConvertor.fromPost(
            post: repostedPosts[e.attachmentMeta.entityId]!,
            widgets: widgets,
            users: users,
            topics: topics,
          );
        }

        return LMAttachmentViewDataConvertor.fromAttachment(
            attachment: e, repost: repost);
      }).toList());
    }

    postViewDataBuilder.communityId(post.communityId);

    postViewDataBuilder.isPinned(post.isPinned);

    postViewDataBuilder.uuid(post.uuid);

    if (users[post.uuid] != null) {
      postViewDataBuilder
          .user(LMUserViewDataConvertor.fromUser(users[post.uuid]!));
    }

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
            ?.map((e) => LMCommentViewDataConvertor.fromComment(
                e,
                users.map((key, value) =>
                    MapEntry(key, LMUserViewDataConvertor.fromUser(value)))))
            .toList() ??
        []);

    postViewDataBuilder.commentCount(post.commentCount);

    postViewDataBuilder.isReposted(post.isRepost);

    postViewDataBuilder.isRepostedByUser(post.isRepostedByUser);

    postViewDataBuilder.repostCount(post.repostCount);

    postViewDataBuilder.isDeleted(post.isDeleted ?? false);

    postViewDataBuilder.widgets(widgetMap);

    if (post.heading != null) postViewDataBuilder.heading(post.heading!);

    if (post.commentIds != null && post.commentIds!.isNotEmpty) {
      postViewDataBuilder.commentIds(post.commentIds!);

      List<LMCommentViewData> topComments = [];
      if (filteredComments != null && filteredComments.isNotEmpty) {
        post.commentIds?.forEach((element) {
          if (filteredComments[element] != null)
            topComments.add(LMCommentViewDataConvertor.fromComment(
                filteredComments[element]!,
                users.map((key, value) =>
                    MapEntry(key, LMUserViewDataConvertor.fromUser(value)))));
        });
      }

      postViewDataBuilder.topComments(topComments);
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
      topics: postViewData.topics.map((e) => e.id).toList(),
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
    );
  }
}
