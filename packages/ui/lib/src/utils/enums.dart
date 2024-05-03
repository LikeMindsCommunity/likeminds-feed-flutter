/// enum to describe placement of icon inside of LMFeedButton
enum LMFeedIconButtonPlacement { start, end }

/// enum to describe actions possible on a post
enum LMFeedPostActions { like, comment, share, save }

/// enum to describe alignment in context to LM widgets
enum LMFeedAlignment { left, centre, right }

/// enum to describe type of icon for any LMFeedIcon
enum LMFeedIconType { icon, svg, png }

/// enum to describe type of list for LMFeedPostLikesList
enum LMFeedPostLikesListViewType { screen, bottomSheet }

enum LMFeedPostDeleteViewType { dialog, bottomSheet }

/// enum to describe type of menu for LMFeedPostMenu
enum LMFeedPostMenuType { popUp, bottomSheet }

/// {@template lm_feed_widget_source}
/// enum to describe the source of widget
/// {@endtemplate}
enum LMFeedWidgetSource {
  universalFeed,
  feedroom,
  postDetailScreen,
  userFeed,
  activityScreen,
  createPostScreen,
  editPostScreen,
  notificationScreen,
  topicSelectScreen,
  likesScreen,
  mediaPreviewScreen,
  reportScreen,
  searchScreen,
  savedPostScreen,
  userCreatedCommentScreen,
}

/// {@macro lm_feed_post_action_type}
/// enum to describe the type of action on a post
enum LMFeedPostActionType {
  like,
  unlike,
  commentAdded,
  commentEdited,
  commentDeleted,
  replyAdded,
  replyEdited,
  replyDeleted,
  saved,
  unsaved,
  pinned,
  unpinned,
  edited,
  pollSubmit,
  pollSubmitError,
  addPollOption,
  addPollOptionError,
}
