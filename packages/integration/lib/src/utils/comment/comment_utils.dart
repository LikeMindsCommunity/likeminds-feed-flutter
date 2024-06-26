import 'package:flutter/material.dart';
import 'package:likeminds_feed_flutter_core/likeminds_feed_core.dart';

class LMFeedCommentUtils {
  // Handles the tap on the profile picture or name of the user who commented
  // or replied to an alreay existing comment
  // If the entity is a reply then send that reply's commentViewData model
  // If the entity is a comment then send that commentViewData model
  static void handleCommentProfileTap(
      BuildContext context,
      LMPostViewData postViewData,
      LMCommentViewData commentViewData,
      String eventName,
      LMFeedWidgetSource widgetSource) {
    LMFeedCore.instance.lmFeedClient
        .routeToProfile(commentViewData.user.sdkClientInfo.uuid);

    // Handle profile tap callback
    LMFeedProfileBloc.instance.add(
      LMFeedRouteToUserProfileEvent(
        uuid: commentViewData.user.sdkClientInfo.uuid,
        context: context,
      ),
    );

    // Fire analytics event for profile picture or name tap

    // Raise an event for analytics
    Map<String, dynamic> eventProperties = {
      LMFeedAnalyticsKeys.postIdKey: postViewData.id,
      LMFeedAnalyticsKeys.createdByIdKey:
          commentViewData.user.sdkClientInfo.uuid,
      LMFeedAnalyticsKeys.topicsKey:
          postViewData.topics.map((e) => e.name).toList(),
      LMFeedAnalyticsKeys.postTypeKey:
          LMFeedPostUtils.getPostType(postViewData.attachments),
    };

    // If the entity is a comment then add comment id
    if (commentViewData.level == 0) {
      eventProperties[LMFeedAnalyticsKeys.commentIdKey] = commentViewData.id;
    }
    // If the entity is a reply then add reply id and comment id
    else {
      eventProperties[LMFeedAnalyticsKeys.commentIdKey] =
          commentViewData.parentComment?.id;
      eventProperties[LMFeedAnalyticsKeys.replyIdKey] = commentViewData.id;
    }
    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
        eventName: eventName,
        widgetSource: widgetSource,
        eventProperties: eventProperties));
  }

  // Handles the event callback when the user taps on the post menu
  // If the entity is a comment then send that commentViewData model
  // If the entity is a reply then send that reply's commentViewData model
  static void handleCommentMenuOpenTap(
      LMPostViewData postViewData,
      LMCommentViewData commentViewData,
      LMFeedWidgetSource widgetSource,
      String eventName) {
    // Raise an event for analytics
    Map<String, dynamic> eventProperties = {
      LMFeedAnalyticsKeys.postIdKey: postViewData.id,
      LMFeedAnalyticsKeys.createdByIdKey:
          commentViewData.user.sdkClientInfo.uuid,
      LMFeedAnalyticsKeys.topicsKey:
          postViewData.topics.map((e) => e.name).toList(),
      LMFeedAnalyticsKeys.postTypeKey:
          LMFeedPostUtils.getPostType(postViewData.attachments),

      // If the entity is a comment then add comment id
    };

    if (commentViewData.level == 0) {
      eventProperties[LMFeedAnalyticsKeys.commentIdKey] = commentViewData.id;
    }
    // If the entity is a reply then add reply id and comment id
    else {
      eventProperties[LMFeedAnalyticsKeys.commentIdKey] =
          commentViewData.parentComment?.id;
      eventProperties[LMFeedAnalyticsKeys.replyIdKey] = commentViewData.id;
    }

    LMFeedAnalyticsBloc.instance.add(LMFeedFireAnalyticsEvent(
        eventName: eventName,
        widgetSource: widgetSource,
        eventProperties: eventProperties));
  }

  //  Fire an analytics event when a user taps on the comment like button
  static void handleCommentLikeTapEvent(
      LMPostViewData postViewData,
      LMFeedWidgetSource widgetSource,
      LMCommentViewData commentViewData,
      bool isLiked) {
    Map<String, dynamic> eventProperties = {
      LMFeedAnalyticsKeys.postIdKey: postViewData.id,
      LMFeedAnalyticsKeys.postTypeKey:
          LMFeedPostUtils.getPostType(postViewData.attachments),
      LMFeedAnalyticsKeys.topicsKey:
          postViewData.topics.map((e) => e.name).toList(),
      LMFeedAnalyticsKeys.createdByIdKey:
          commentViewData.user.sdkClientInfo.uuid,
    };

    if (commentViewData.level == 0) {
      eventProperties[LMFeedAnalyticsKeys.commentIdKey] = commentViewData.id;
    } else {
      eventProperties[LMFeedAnalyticsKeys.commentIdKey] =
          commentViewData.parentComment?.id;
      eventProperties[LMFeedAnalyticsKeys.replyIdKey] = commentViewData.id;
    }

    LMFeedAnalyticsBloc.instance.add(
      LMFeedFireAnalyticsEvent(
        eventName: commentViewData.level == 0
            ? isLiked
                ? LMFeedAnalyticsKeys.commentLiked
                : LMFeedAnalyticsKeys.commentUnliked
            : isLiked
                ? LMFeedAnalyticsKeys.replyLiked
                : LMFeedAnalyticsKeys.replyUnliked,
        widgetSource: widgetSource,
        eventProperties: eventProperties,
      ),
    );
  }
}
