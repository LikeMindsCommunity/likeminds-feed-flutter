import 'dart:io';
import 'dart:math';
import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedPostUtils {
  static const String notificationTagRoute =
      r'<<([^<>]+)\|route://([^<>]+)/([a-zA-Z-0-9_]+)>>';

  static String getFileSizeString({required int bytes, int decimals = 0}) {
    const suffixes = ["b", "kb", "mb", "gb", "tb"];
    var i = (log(bytes) / log(1024)).floor();
    return ((bytes / pow(1024, i)).toStringAsFixed(decimals)) + suffixes[i];
  }

// Returns file size in double in MBs
  static double getFileSizeInDouble(int bytes) {
    return (bytes / pow(1024, 2));
  }

  static String getPostType(List<LMAttachmentViewData>? attachments) {
    String postTypeString;
    if (attachments == null || attachments.isEmpty) return 'text';
    switch (attachments.first.attachmentType) {
      case 1: // Image
        postTypeString = "image";
        break;
      case 2: // Video
        postTypeString = "video";
        break;
      case 3: // Document
        postTypeString = "document";
        break;
      case 4: // Link
        postTypeString = "link";
        break;
      default:
        postTypeString = "text";
    }
    return postTypeString;
  }

  static Future<Map<String, int>> getImageFileDimensions(File image) async {
    Map<String, int> dimensions = {};
    final decodedImage = await decodeImageFromList(image.readAsBytesSync());
    dimensions.addAll({"width": decodedImage.width});
    dimensions.addAll({"height": decodedImage.height});
    return dimensions;
  }

  static Future<Map<String, int>> getNetworkImageDimensions(
      String image) async {
    Map<String, int> dimensions = {};
    final response = await http.get(Uri.parse(image));
    final bytes = response.bodyBytes;
    final decodedImage = await decodeImageFromList(bytes);
    dimensions.addAll({"width": decodedImage.width});
    dimensions.addAll({"height": decodedImage.height});
    return dimensions;
  }

  static String getLikeCountText(int likes) {
    if (likes == 1) {
      return 'Like';
    } else {
      return 'Likes';
    }
  }

  static String getLikeCountTextWithCount(int likes) {
    if (likes == 1) {
      return '$likes Like';
    } else {
      return '$likes Likes';
    }
  }

  static String getCommentCountText(int comment) {
    if (comment == 1) {
      return 'Comment';
    } else {
      return 'Comments';
    }
  }

  static String getCommentCountTextWithCount(int comment) {
    if (comment == 0) {
      return 'Add Comment';
    } else if (comment == 1) {
      return '1 Comment';
    } else {
      return '$comment Comments';
    }
  }

  static Map<String, String> decodeNotificationString(
      String string, String currentUserId) {
    Map<String, String> result = {};
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(string);
    for (final match in matches) {
      String tag = match.group(1)!;
      final String mid = match.group(2)!;
      final String id = match.group(3)!;
      if (id == currentUserId) {
        tag = 'You';
      }
      string = string.replaceAll('<<$tag|route://$mid/$id>>', '@$tag');
      result.addAll({tag: id});
    }
    return result;
  }

  static List<TextSpan> extractNotificationTags(
      String text, String currentUserId) {
    List<TextSpan> textSpans = [];
    final Iterable<RegExpMatch> matches =
        RegExp(notificationTagRoute).allMatches(text);
    int lastIndex = 0;
    for (Match match in matches) {
      int startIndex = match.start;
      int endIndex = match.end;
      String? link = match.group(0);

      if (lastIndex != startIndex) {
        // Add a TextSpan for the preceding text
        textSpans.add(
          TextSpan(
            text: text.substring(lastIndex, startIndex),
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              fontSize: 14,
              color: LikeMindsTheme.blackColor,
            ),
          ),
        );
      }
      // Add a TextSpan for the URL
      textSpans.add(
        TextSpan(
          text: decodeNotificationString(link!, currentUserId).keys.first,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: LikeMindsTheme.blackColor,
          ),
        ),
      );

      lastIndex = endIndex;
    }

    if (lastIndex != text.length) {
      // Add a TextSpan for the remaining text
      textSpans.add(TextSpan(
        text: text.substring(lastIndex),
        style: const TextStyle(
          fontWeight: FontWeight.w400,
          fontSize: 14,
          color: LikeMindsTheme.blackColor,
        ),
      ));
    }

    return textSpans;
  }

  static LMPostViewData postViewDataFromActivity(
    UserActivityItem activity,
    Map<String, WidgetModel>? widgets,
    Map<String, User> users,
    Map<String, Topic>? topics, {
    Map<String, Comment>? filteredComments,
    Map<String, Post>? repostedPosts,
  }) {
    List<LMTopicViewData> topicViewData = [];

    if (activity.activityEntityData.topics != null &&
        topics != null &&
        activity.activityEntityData.topics!.isNotEmpty) {
      for (var topicId in activity.activityEntityData.topics!) {
        if (topics[topicId] != null) {
          topicViewData
              .add(LMTopicViewDataConvertor.fromTopic(topics[topicId]!));
        }
      }
    }

    return activity.action == 7
        ? LMPostViewDataConvertor.fromPost(
            post: activity.activityEntityData.postData!,
            widgets: widgets,
            users: users,
            topics: topics ?? {},
            filteredComments: filteredComments ?? {},
            repostedPosts: repostedPosts ?? {},
          )
        : (LMPostViewDataBuilder()
              ..id(activity.activityEntityData.id)
              ..isEdited(activity.activityEntityData.isEdited!)
              ..text(activity.activityEntityData.text)
              ..attachments(activity.activityEntityData.attachments
                      ?.map((e) => LMAttachmentViewDataConvertor.fromAttachment(
                            attachment: e,
                          ))
                      .toList() ??
                  [])
              ..replies(activity.activityEntityData.replies
                      ?.map((e) => LMCommentViewDataConvertor.fromComment(
                          e,
                          users.map((key, value) => MapEntry(key,
                                  LMUserViewDataConvertor.fromUser(value))) ??
                              {}))
                      .toList() ??
                  [])
              ..communityId(activity.activityEntityData.communityId)
              ..isPinned(activity.activityEntityData.isPinned!)
              ..topics(topicViewData)
              ..uuid(activity.activityEntityData.uuid!)
              ..user(LMUserViewDataConvertor.fromUser(
                  users[activity.activityEntityData.uuid!]!))
              ..likeCount(activity.activityEntityData.likesCount!)
              ..commentCount(activity.activityEntityData.commentsCount!)
              ..isSaved(activity.activityEntityData.isSaved!)
              ..isLiked(activity.activityEntityData.isLiked!)
              ..menuItems(activity.activityEntityData.menuItems!
                  .map((e) =>
                      LMPopupMenuItemConvertor.fromPopUpMenuItemModel(item: e))
                  .toList())
              ..createdAt(DateTime.fromMillisecondsSinceEpoch(
                  activity.activityEntityData.createdAt))
              ..isReposted(activity.activityEntityData.isRepost ?? false)
              ..isRepostedByUser(
                  activity.activityEntityData.isRepostedByUser ?? false)
              ..repostCount(activity.activityEntityData.repostCount ?? 0)
              ..isDeleted(activity.activityEntityData.isDeleted ?? false)
              ..updatedAt(DateTime.fromMillisecondsSinceEpoch(
                  activity.activityEntityData.updatedAt!))
              ..widgets(widgets?.map((key, value) => MapEntry(
                      key, LMWidgetViewDataConvertor.fromWidgetModel(value))) ??
                  {}))
            .build();
  }

  static LMCommentViewData commentViewDataFromActivity(
      UserActivityEntityData commentData, Map<String, User> users) {
    LMCommentViewDataBuilder commentViewDataBuilder = LMCommentViewDataBuilder()
      ..uuid(commentData.uuid!)
      ..text(commentData.text)
      ..level(commentData.level!)
      ..likesCount(commentData.likesCount!)
      ..repliesCount(commentData.commentsCount ?? 0)
      ..menuItems(commentData.menuItems
              ?.map((e) =>
                  LMPopupMenuItemConvertor.fromPopUpMenuItemModel(item: e))
              .toList() ??
          [])
      ..createdAt(DateTime.fromMillisecondsSinceEpoch(commentData.createdAt))
      ..isLiked(commentData.isLiked!)
      ..id(commentData.id)
      ..replies(commentData.replies
              ?.map((e) => LMCommentViewDataConvertor.fromComment(
                  e,
                  users.map((key, value) =>
                      MapEntry(key, LMUserViewDataConvertor.fromUser(value)))))
              .toList() ??
          [])
      ..isEdited(commentData.isEdited);

    if (commentData.uuid != null) {
      commentViewDataBuilder.uuid(commentData.uuid!);

      LMUserViewData user =
          LMUserViewDataConvertor.fromUser(users[commentData.uuid]!);

      commentViewDataBuilder.user(user);
    }

    if (commentData.updatedAt != null) {
      commentViewDataBuilder.updatedAt(
          DateTime.fromMillisecondsSinceEpoch(commentData.updatedAt!));
    }

    LMCommentViewData commentViewData = commentViewDataBuilder.build();

    return commentViewData;
  }
}
