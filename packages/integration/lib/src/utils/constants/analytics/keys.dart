class LMFeedAnalyticsKeys {
  // Events related to Post Creation
  static const String postCreationStarted = 'post_creation_started';
  static const String clickedOnAttachment = 'clicked_on_attachment';
  static const String userTaggedInPost = 'user_tagged_in_a_post';
  static const String linkAttachedInPost = 'link_attached_in_the_post';
  static const String imageAttachedToPost = 'image_attached_to_post';
  static const String videoAttachedToPost = 'video_attached_to_post';
  static const String documentAttachedInPost = 'document_attached_in_post';
  static const String postCreationCompleted = 'post_creation_completed';
  // Events related to Feed
  static const String feedOpened = 'feed_opened';
  static const String userFollowed = 'user_followed';
  // Events related to Post
  static const String postPinned = 'post_pinned';
  static const String postUnpinned = 'post_unpinned';
  static const String postLiked = 'post_liked';
  static const String postUnliked = 'post_unliked';
  static const String postSaved = 'post_saved';
  static const String postUnsaved = 'post_unsaved';
  static const String postShared = 'post_shared';
  static const String postEdited = 'post_edited';
  static const String postReported = 'post_reported';
  static const String postDeleted = 'post_deleted';
  static const String likeListOpen = 'like_list_open';
  static const String postProfilePicture = 'post_profile_pic';
  static const String postProfileName = 'post_profile_name';
  static const String postMenu = 'post_menu';
  static const String postResponseClick = 'post_response_click';
  static const String postTopicClick = 'post_topic_click';
  static const String postCommentClick = 'post_comment_click';
  // Events related to Poll in Feed
  static const String pollVoted = 'poll_voted';
  static const String pollVotingSkipped = 'poll_voting_skipped';
  static const String pollVotesEdited = 'poll_votes_edited';
  static const String pollAdded = 'poll_added';
  static const String pollOptionCreated = 'poll_option_created';
  static const String pollAnswersViewed = 'poll_answers_viewed';
  static const String pollAnswersToggled = 'poll_answers_toggled';
  // Events related to Comments
  static const String commentListOpen = 'comment_list_open';
  static const String commentPosted = 'comment_posted';
  static const String commentDeleted = 'comment_deleted';
  static const String commentReported = 'comment_reported';
  static const String commentProfilePicture = 'comment_profile_pic';
  static const String commentProfileName = 'comment_profile_name';
  static const String commentMenu = 'comment_menu';
  static const String commentLiked = 'comment_liked';
  static const String commentUnliked = 'comment_unliked';
  // Events related to Replies
  static const String replyPosted = 'reply_posted';
  static const String replyDeleted = 'reply_deleted';
  static const String replyReported = 'reply_reported';
  static const String replyProfilePicture = 'reply_profile_pic';
  static const String replyProfileName = 'reply_profile_name';
  static const String replyMenu = 'reply_menu';
  static const String replyLiked = 'reply_liked';
  static const String replyUnliked = 'reply_unliked';
  // Events related to Search
  static const String searchScreenOpened = 'search_screen_opened';
  // Events related to Hashtags
  static const String hashtagClicked = 'hashtag_clicked';
  static const String hashtagFeedOpened = 'hashtag_feed_opened';
  static const String hashtagFollowed = 'hashtag_followed';
  static const String hashtagUnfollowed = 'hashtag_unfollowed';
  static const String hashtagReported = 'hashtag_reported';
  // Events related to Notifications
  static const String notificationReceived = "notification_received";
  static const String notificationClicked = "notification_clicked";
  // Events related to Activity Feed
  static const String activityFeedOpened = "activity_feed_opened";
  static const String activityItemClicked = "activity_item_clicked";
  static const String entityTypeKey = 'entity_type';

  // Keys related to properties
  // Post Related Keys
  static const String postIdKey = 'post_id';
  static const String postTypeKey = 'post_type';
  // User Related Keys
  static const String createdByIdKey = 'created_by_id';
  static const String userIdKey = 'user_id';
  // Topic Related Keys
  static const String topicsKey = 'topics';
  static const String topicIdKey = 'topic_id';
  static const String topicClickedKey = 'topic_clicked';
  // Comment Related Keys
  static const String commentIdKey = 'comment_id';
  // Reply Related Keys
  static const String replyIdKey = 'reply_id';
  // video feed related keys
  static const String exploreReelOpened = 'explore_reel_opened';
  static const String reelViewed = 'reel_viewed';
  static const String reelSwiped = 'reel_swiped';
  static const String reelLiked = 'reel_liked';
  static const String reelUnliked = 'reel_unliked';
  static const String reelReported = 'reel_reported';
  static const String noMoreReelsShown = 'no_more_reels_shown';
}
