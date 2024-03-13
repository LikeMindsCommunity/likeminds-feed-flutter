part of 'post_bloc.dart';

/// {@template lm_feed_post_events}
/// [LMFeedPostEvents] defines the events which are handled by [LMFeedPostBloc]
/// {@endtemplate}
abstract class LMFeedPostEvents extends Equatable {
  @override
  List<Object> get props => [];
}

/// {@template lm_feed_get_post_event}
/// When a post is to be fetched from the server
/// [LMFeedGetPostEvent] is raised to fetch the post details
/// [postId] contains the id of the post to be fetched
/// {@endtemplate}
class LMFeedGetPostEvent extends LMFeedPostEvents {
  final String postId;

  ///{@macro lm_feed_get_post_event}
  LMFeedGetPostEvent({required this.postId});
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
  final List<LMMediaModel>? postMedia;
  final String? postText;
  final String? heading;
  final LMUserViewData user;
  final List<LMTopicViewData> selectedTopics;

  ///{@macro lm_feed_create_new_post_event}
  LMFeedCreateNewPostEvent({
    this.postMedia,
    required this.user,
    this.postText,
    required this.selectedTopics,
    this.heading,
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
  final String postId;
  final String? heading;
  final List<LMTopicViewData> selectedTopics;

  ///{@macro lm_feed_edit_post_event}
  LMFeedEditPostEvent({
    this.postText,
    required this.postId,
    required this.selectedTopics,
    this.heading,
  }) : assert(postText != null || heading != null);
}

class LMFeedDeletePostEvent extends LMFeedPostEvents {
  final String postId;
  final String reason;
  final int? feedRoomId;
  final bool isRepost;

  LMFeedDeletePostEvent({
    required this.postId,
    required this.reason,
    this.feedRoomId,
    this.isRepost = false,
  });

  @override
  List<Object> get props => [postId, reason, isRepost];
}

class LMFeedUpdatePostEvent extends LMFeedPostEvents {
  final LMPostViewData? post;
  final LMFeedPostActionType actionType;
  final String postId;

  LMFeedUpdatePostEvent({
    this.post,
    required this.actionType,
    required this.postId,
  });

  @override
  List<Object> get props => [identityHashCode(this)];
}
