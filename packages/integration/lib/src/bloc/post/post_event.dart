part of 'post_bloc.dart';

abstract class LMFeedPostEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class LMFeedCreateNewPostEvent extends LMFeedPostEvents {
  final List<LMMediaModel>? postMedia;
  final String postText;
  final User user;
  final List<LMTopicViewData> selectedTopics;

  LMFeedCreateNewPostEvent({
    this.postMedia,
    required this.user,
    required this.postText,
    required this.selectedTopics,
  });
}

class LMFeedEditPostEvent extends LMFeedPostEvents {
  final List<LMAttachmentViewData>? attachments;
  final String postText;
  final String postId;
  final List<LMTopicViewData> selectedTopics;

  LMFeedEditPostEvent({
    required this.postText,
    this.attachments,
    required this.postId,
    required this.selectedTopics,
  });
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
  final LMPostViewData post;

  LMFeedUpdatePostEvent({
    required this.post,
  });

  @override
  List<Object> get props => [post, DateTime.now().millisecondsSinceEpoch];
}

class LMFeedTogglePinPostEvent extends LMFeedPostEvents {
  final String postId;
  final bool isPinned;

  LMFeedTogglePinPostEvent({
    required this.postId,
    required this.isPinned,
  });

  @override
  List<Object> get props => [postId, isPinned];
}
