part of 'post_bloc.dart';

/// {@template lm_feed_post_events}
/// [LMFeedPostEvents] defines the events which are handled by [LMFeedPostBloc]
/// {@endtemplate}
abstract class LMFeedPostEvents extends Equatable {
  @override
  List<Object> get props => [];
}

/// {@template lm_feed_post_initiate_event}
/// Initial state of the bloc
/// {@endtemplate}
class LMFeedPostInitiateEvent extends LMFeedPostEvents {}

/// {@template lm_feed_get_post_event}
/// When a post is to be fetched from the server
/// [LMFeedGetPostEvent] is raised to fetch the post details
/// [postId] contains the id of the post to be fetched
/// {@endtemplate}
class LMFeedGetPostEvent extends LMFeedPostEvents {
  final String? postId;
  final String? pendingPostId;
  final int page;
  final int pageSize;

  ///{@macro lm_feed_get_post_event}
  LMFeedGetPostEvent(
      {this.postId,
      this.pendingPostId,
      required this.page,
      required this.pageSize})
      : assert(postId != null || pendingPostId != null);
}

/// {@template lm_feed_create_new_post_event}
/// When a new post is to be created
/// [LMFeedCreateNewPostEvent] is raised to create a new post
/// [postMedia] contains the media files to be uploaded
/// [postText] contains the text to be uploaded
/// [heading] contains the heading to be uploaded
/// One of [postMedia], [postText] or [heading] should not be
/// null to create a new post
/// [user] contains the user details and is of type [LMUserViewData]
/// [selectedTopics] contains the selected topics
/// and is of type [List<LMTopicViewData>]
/// {@endtemplate}
class LMFeedCreateNewPostEvent extends LMFeedPostEvents {
  final List<LMAttachmentViewData>? postMedia;
  final String? postText;
  final String? heading;
  final LMUserViewData user;
  final List<LMTopicViewData> selectedTopics;
  final int? feedroomId;
  final List<LMUserTagViewData>? userTagged;

  ///{@macro lm_feed_create_new_post_event}
  LMFeedCreateNewPostEvent({
    this.postMedia,
    required this.user,
    this.postText,
    required this.selectedTopics,
    this.heading,
    this.feedroomId,
    this.userTagged,
  }) : assert(postMedia != null || postText != null || heading != null);
}

/// {@template lm_feed_edit_post_event}
/// When an existing post is to be edited
/// [LMFeedEditPostEvent] is raised to edit an existing post
/// [attachments] contains the media files to be uploaded
/// [postText] contains the text to be uploaded
/// [heading] contains the heading to be uploaded
/// [postId] contains the id of the post to be edited
/// One of [attachments], [postText] or [heading] should not be
/// null to edit a post
/// [selectedTopics] contains the selected topics
/// and is of type [List<LMTopicViewData>]
/// {@endtemplate}
class LMFeedEditPostEvent extends LMFeedPostEvents {
  final String? postText;
  final String? postId;
  final String? pendingPostId;
  final String? heading;
  final List<LMTopicViewData> selectedTopics;

  ///{@macro lm_feed_edit_post_event}
  LMFeedEditPostEvent({
    this.postText,
    this.postId,
    this.pendingPostId,
    required this.selectedTopics,
    this.heading,
  }) : assert(postText != null ||
            heading != null && (pendingPostId != null || postId != null));
}

class LMFeedDeletePostEvent extends LMFeedPostEvents {
  final String? postId;
  final String? pendingPostId;
  final String reason;
  final int? feedRoomId;
  final bool isRepost;
  // The below keys are required for analytics
  final String? userState; // state of user who deletes the post
  final String? userId; // user who created the post
  final String? postType; // type of post i.e video, photo, text

  LMFeedDeletePostEvent({
    this.postId,
    this.pendingPostId,
    required this.reason,
    this.feedRoomId,
    this.isRepost = false,
    this.userState,
    this.userId,
    this.postType,
  }) : assert(pendingPostId != null || postId != null);

  @override
  List<Object> get props => [reason, isRepost, postId ?? pendingPostId ?? ''];
}

class LMFeedUpdatePostEvent extends LMFeedPostEvents {
  final LMPostViewData? post;
  final LMFeedPostActionType actionType;
  final String postId;
  final LMFeedWidgetSource? source;
  // This variable stores the id of comment
  // that is deleted
  final String? commentId;
  final List<LMPollOptionViewData>? pollOption;

  LMFeedUpdatePostEvent({
    this.post,
    required this.actionType,
    required this.postId,
    this.commentId,
    this.source,
    this.pollOption,
  });

  @override
  List<Object> get props => [identityHashCode(this)];
}
