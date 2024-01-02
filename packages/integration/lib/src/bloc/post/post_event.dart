part of 'post_bloc.dart';

abstract class LMPostEvents extends Equatable {
  @override
  List<Object> get props => [];
}

class LMCreateNewPost extends LMPostEvents {
  final List<LMMediaModel>? postMedia;
  final String postText;
  final User user;
  final List<LMTopicViewData> selectedTopics;

  LMCreateNewPost({
    this.postMedia,
    required this.user,
    required this.postText,
    required this.selectedTopics,
  });
}

class LMEditPost extends LMPostEvents {
  final List<LMAttachmentViewData>? attachments;
  final String postText;
  final String postId;
  final List<LMTopicViewData> selectedTopics;

  LMEditPost({
    required this.postText,
    this.attachments,
    required this.postId,
    required this.selectedTopics,
  });
}

class LMDeletePost extends LMPostEvents {
  final String postId;
  final String reason;
  final int? feedRoomId;

  LMDeletePost({
    required this.postId,
    required this.reason,
    this.feedRoomId,
  });

  @override
  List<Object> get props => [postId, reason];
}

class LMUpdatePost extends LMPostEvents {
  final LMPostViewData post;

  LMUpdatePost({
    required this.post,
  });

  @override
  List<Object> get props => [post, DateTime.now().millisecondsSinceEpoch];
}

class LMTogglePinPost extends LMPostEvents {
  final String postId;
  final bool isPinned;

  LMTogglePinPost({
    required this.postId,
    required this.isPinned,
  });

  @override
  List<Object> get props => [postId, isPinned];
}
